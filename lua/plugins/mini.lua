return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        require("mini.pairs").setup()
        require("mini.indentscope").setup()
        require('mini.comment').setup({
            options = {
                custom_commentstring = nil,
                ignore_blank_line = false,
                start_of_line = false,
                pad_comment_parts = true,
            },
            mappings = {
                comment = 'gc',
                comment_line = 'gcc',
                comment_visual = 'gc',
                textobject = 'gc',
            },
            hooks = {
                pre = function() end,
                post = function() end,
            },
        })
    end,
}
