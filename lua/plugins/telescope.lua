return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
        local actions = require('telescope.actions')
        local fb_actions = require('telescope._extensions.file_browser.actions')
        local telescope = require('telescope')

        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-c>"] = actions.close,
                        ["<CR>"] = actions.select_default,
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,
                    },
                    n = {
                        ["q"] = actions.close,
                    },
                },
            },
            extensions = {
                file_browser = {
                    theme = "dropdown",
                    hijack_netrw = true,
                    hidden = true,
                    mappings = {
                        i = {
                            ["<C-n>"] = fb_actions.create,
                            ["<C-d>"] = fb_actions.remove,
                            ["<C-r>"] = fb_actions.rename,
                        },
                    },
                },
            },
        }

        telescope.load_extension('file_browser')

        local builtin = require('telescope.builtin')

        -- Wrap these in functions so they execute when the key is pressed
        vim.keymap.set('n', '<leader>ff', function()
            builtin.find_files({ hidden = true })
        end, { desc = "Telescope Find Files" })

        vim.keymap.set('n', '<leader>fg', function()
            builtin.live_grep({ hidden = true })
        end, { desc = "Telescope Live Grep" })

        vim.keymap.set('n', '<leader>fb', function()
            require('telescope').extensions.file_browser.file_browser({ hidden = true })
        end, { desc = "Telescope File Browser" })
    end
}
