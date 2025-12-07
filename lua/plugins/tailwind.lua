return {
  {
    'luckasRanarison/tailwind-tools.nvim',
    name = 'tailwind-tools',
    build = ':UpdateRemotePlugins',
    lazy = true,
    ft = 'ts,tsx',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {},
    },
}
