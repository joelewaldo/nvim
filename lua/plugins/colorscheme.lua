return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            transparent_background = true,
            flavour = "mocha",
        },
    },
    {
        "arzg/vim-colors-xcode",
        name = "xcode",
        priority = 1000,
    },
    {
        "neanias/everforest-nvim",
        version = false,
        lazy = false,
        priority = 1000,
    },
    {
        'tiagovla/tokyodark.nvim',
        priority = 1000,
        opts = {
            transparent_background = false,
        },
        config = function(_, opts)
            require('tokyodark').setup(opts)
            vim.cmd [[colorscheme tokyodark]]
        end,
    },
}
