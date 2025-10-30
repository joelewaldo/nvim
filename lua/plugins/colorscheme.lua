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
        'folke/tokyonight.nvim',
        priority = 1000,
        lazy = false,
        opts = {
            transparent_background = false,
            style = "night"
        },
        -- config = function()
        --     vim.cmd[[colorscheme tokyonight]]
        -- end,
    },
    {
      "navarasu/onedark.nvim",
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
        require('onedark').setup {
          style = 'deep'
        }
        -- Enable theme
        require('onedark').load()
      end
    }
}
