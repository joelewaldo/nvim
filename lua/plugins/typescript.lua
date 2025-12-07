return {
  {
    {
      'folke/ts-comments.nvim',
      opts = {},
      event = 'VeryLazy',
    },
  },
  {
    'pmizio/typescript-tools.nvim',
    enabled = false,
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    config = {
      settings = {
        jsx_close_tag = {
          enable = true,
          filetypes = { 'javascriptreact', 'typescriptreact' },
        },
      },
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    },
    keys = {
      { '<leader>ts', '<cmd>TailwindSort<cr>', desc = '[T]ailwind [s]ort' },
    },
  },
}
