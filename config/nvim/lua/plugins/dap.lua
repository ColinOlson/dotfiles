return {
  {
    "mfussenegger/nvim-dap",
          -- stylua: ignore
    keys = {
        { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
        { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
        { "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
        { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },

        { "<C-F5>", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
        { "<F5>", function() require("dap").continue() end, desc = "Run/Continue" },
        { "<F8>", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },

        { "<S-F5>", function() require("dap").terminate() end, desc = "Terminate" },
    },
  },
}
