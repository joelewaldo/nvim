return {
    {
        -- Main LSP Configuration
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', opts = {} },
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim',       opts = {} },
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

                    -- Organize imports
                    map('<leader>co', '<cmd>TSToolsOrganizeImports<cr>', '[C]ode [O]rganize Imports')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    -- This may be unwanted, since they displace some of your code
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                    -- Format on save
                    if client and client.supports_method("textDocument/formatting") then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = vim.api.nvim_create_augroup("LspFormat." .. event.buf, { clear = true }),
                            buffer = event.buf,
                            callback = function()
                                vim.lsp.buf.format { bufnr = event.buf }
                            end,
                        })
                    end
                end,
            })

            -- Change diagnostic symbols in the sign column (gutter)
            if vim.g.have_nerd_font then
                local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local diagnostic_signs = {}
                for type, icon in pairs(signs) do
                    diagnostic_signs[vim.diagnostic.severity[type]] = icon
                end
                vim.diagnostic.config { signs = { text = diagnostic_signs } }
            end

            local servers = {
                pyright = {},
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
                -- tsserver = {
                --     settings = {
                --         typescript = {
                --             tsserver = {
                --                 useSyntaxServer = false,
                --             },
                --             inlayHints = {
                --                 includeInlayParameterNameHints = 'all',
                --                 includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                --                 includeInlayFunctionParameterTypeHints = true,
                --                 includeInlayVariableTypeHints = true,
                --                 includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                --                 includeInlayPropertyDeclarationTypeHints = true,
                --                 includeInlayFunctionLikeReturnTypeHints = true,
                --                 includeInlayEnumMemberValueHints = true,
                --             },
                --         },
                --
                --         javascript = {
                --             inlayHints = {
                --                 includeInlayParameterNameHints = 'all',
                --                 includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                --                 includeInlayFunctionParameterTypeHints = true,
                --                 includeInlayVariableTypeHints = true,
                --                 includeInlayVariableTypeHIntsWhenTypeMatchesName = true,
                --                 includeInlayPropertyDeclarationTypeHints = true,
                --                 includeInlayFunctionLikeReturnTypeHints = true,
                --                 includeInlayEnumMemberValueHints = true,
                --             },
                --         },
                --     },
                -- },

                tailwindcss = {
                    settings = {
                        tailwindCSS = {
                            includeLanguages = {
                                -- If you want Tailwind support in additional filetypes like Vue, Svelte, etc.
                                -- For example:
                                -- svelte = "html",
                                -- vue = "html",
                            },
                            experimental = {
                                classRegex = {
                                    -- Example: support for some frameworks that use custom class strings
                                    -- "tw`([^`]*)`",
                                    -- "classnames\\(([^)]*)\\)",
                                },
                            },
                            lint = {
                                cssConflict = "warning", -- or "error"
                                invalidApply = "error",
                                invalidScreen = "error",
                                invalidVariant = "error",
                                recommendedVariantOrder = "warning",
                            },
                        },
                    },
                },

                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
                cssls = {},
                terraformls = {},
                dockerls = {},
            }

            local lsp_servers = vim.tbl_keys(servers)

            local tools = {
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
                -- Add any other non-LSP tools here
            }

            require('mason-tool-installer').setup {
                ensure_installed = tools,
            }

            require('mason-lspconfig').setup {
                ensure_installed = lsp_servers,
                automatic_installation = true,
            }

            local lspconfig = require('lspconfig')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            for server, config in pairs(servers) do
                config.capabilities = capabilities
                lspconfig[server].setup(config)
            end
        end,
    },

    -- LSP Plugins
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
}
