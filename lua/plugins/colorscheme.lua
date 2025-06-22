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
    config = function()
	    require("everforest").setup({
		transparent_background_level = 2,
		vim.cmd("colorscheme everforest")
	    })
	end,
  }
}
