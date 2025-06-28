return {
    {
        'neovim/nvim-lspconfig',
        -- only load the LSP machinery once you actually open a file
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            -- mason.nvim itself only when you call :Mason
            {
                'williamboman/mason.nvim',
                cmd = 'Mason',
                opts = {},
            },
            -- bridge between mason and lspconfig
            'williamboman/mason-lspconfig.nvim',
            -- install non-LSP tools once, at plugin install/update time
            {
                'WhoIsSethDaniel/mason-tool-installer.nvim',
                build = function()
                    require('mason-tool-installer').setup {
                        ensure_installed = {
                            'stylua',        -- Lua formatter
                            'gofumpt',       -- Go formatter
                            'goimports',     -- Go import organizer
                            'golangci-lint', -- Go linter
                            'rustfmt',       -- Rust formatter
                            'codelldb',      -- Rust debugger
                            'black',         -- Python formatter
                            'flake8',        -- Python linter
                            'tflint',        -- Terraform linter
                            'hadolint',      -- Dockerfile linter
                        },
                    }
                end,
            },
            -- fidget for LSP status, only when an LSP actually attaches
            {
                'j-hui/fidget.nvim',
                event = 'LspAttach',
                opts = {},
            },
        },
        config = function()
            -- Whenever an LSP attaches to a buffer, set up your keymaps, inlay hints, highlights, format-on-save, etc.
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local buf = event.buf
                    local client = vim.lsp.get_client_by_id(event.data.client_id)

                    -- helper for buffer-local mappings
                    local function map(keys, fn, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, fn, { buffer = buf, desc = 'LSP: ' .. desc })
                    end

                    -- basic LSP mappings via telescope
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                    map('<leader>co', '<cmd>TSToolsOrganizeImports<cr>', '[C]ode [O]rganize Imports')

                    -- inlay hints toggle
                    if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled { bufnr = buf },
                                buf
                            )
                        end, '[T]oggle [H]ints')
                    end

                    -- documentHighlight on CursorHold
                    if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local hl_grp = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer   = buf,
                            group    = hl_grp,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer   = buf,
                            group    = hl_grp,
                            callback = vim.lsp.buf.clear_references,
                        })
                        -- clear highlights on detach
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            buffer = buf,
                            callback = function()
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = buf }
                            end,
                        })
                    end

                    -- format on save
                    if client.supports_method('textDocument/formatting') then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = vim.api.nvim_create_augroup('LspFormat.' .. buf, { clear = true }),
                            buffer = buf,
                            callback = function() vim.lsp.buf.format { bufnr = buf } end,
                        })
                    end
                end,
            })

            -- optionally customize diagnostic signs if you have a nerd font
            if vim.g.have_nerd_font then
                local icons = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local signs = {}
                for sev, icon in pairs(icons) do
                    signs[vim.diagnostic.severity[sev]] = icon
                end
                vim.diagnostic.config { signs = { text = signs } }
            end

            -- LSP server definitions
            local util = require('lspconfig/util')
            local servers = {
                pyright = {
                    before_init = function(_, cfg)
                        cfg.settings = cfg.settings or {}
                        cfg.settings.python = cfg.settings.python or {}
                        cfg.settings.python.pythonPath = util.path.join(
                            vim.env.HOME, 'virtualenvs', 'nvim-venv', 'bin', 'python'
                        )
                    end,
                    settings = {
                        python = {
                            analysis = {
                                diagnosticMode = 'workspace',
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticSeverityOverrides = {
                                    reportUnusedImport   = 'warning',
                                    reportUnusedVariable = 'warning',
                                },
                            },
                        },
                    },
                },
                eslint = {},
                gopls = {
                    settings = {
                        gopls = {
                            completeUnimported = true,
                            analyses = { unusedparams = true },
                            usePlaceholders = true,
                            staticcheck = true,
                        },
                    },
                },
                rust_analyzer = {},
                ts_ls = {
                    settings = {
                        typescript = {
                            tsserver = { useSyntaxServer = false },
                            inlayHints = {
                                includeInlayParameterNameHints = 'all',
                                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = 'all',
                                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },
                tailwindcss = {
                    settings = {
                        tailwindCSS = {
                            includeLanguages = {},
                            experimental = { classRegex = {} },
                            lint = {
                                cssConflict = 'warning',
                                invalidApply = 'error',
                                invalidScreen = 'error',
                                invalidVariant = 'error',
                                recommendedVariantOrder = 'warning',
                            },
                        },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = 'Replace' },
                            diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
                cssls = {},
                terraformls = {},
                dockerls = {},
            }

            local server_names = vim.tbl_keys(servers)

            -- ensure mason-lspconfig installs these
            require('mason-lspconfig').setup {
                ensure_installed = server_names,
                automatic_installation = true,
            }

            -- attach nvim-cmp capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- finally, loop and .setup()
            local lspconfig = require('lspconfig')
            for name, cfg in pairs(servers) do
                cfg.capabilities = capabilities
                lspconfig[name].setup(cfg)
            end
        end,
    },

    -- helper for improving lua development inside Neovim itself
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
}
