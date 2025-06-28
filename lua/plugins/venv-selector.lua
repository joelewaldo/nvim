return {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp", -- use the new regexp branch
    lazy = false,      -- load at startup so :VenvSelect is available
    dependencies = {
        "neovim/nvim-lspconfig",
        { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", -- optional if you use dap
    },
    keys = {
        { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
    },
    opts = {
        options = {
            on_venv_activate_callback = function()
                local python = require("venv-selector").python()
                if not (python and vim.fn.executable(python) == 1) then
                    vim.notify("Invalid python path: " .. tostring(python), vim.log.levels.ERROR)
                    return
                end

                vim.g.python3_host_prog = python

                -- loop through active Pyright clients and reconfigure them
                for _, client in ipairs(vim.lsp.get_active_clients()) do
                    if client.name == "pyright" then
                        local cfg = client.config
                        cfg.settings.python = cfg.settings.python or {}
                        cfg.settings.python.analysis = cfg.settings.python.analysis or {}
                        cfg.settings.python.analysis.pythonPath = python
                        -- let the server know its settings changed
                        client.notify("workspace/didChangeConfiguration", { settings = cfg.settings })
                        -- if you really want to be safe, restart Pyright
                        -- vim.cmd("LspRestart")
                    end
                end
            end,
        },
    },
}
