vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)
