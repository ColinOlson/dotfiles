local function swift_executable()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

local function codelldb_path()
  local codelldb = vim.fn.exepath("codelldb")
  if codelldb ~= "" then
    return codelldb
  end

  local mason_codelldb = LazyVim.get_pkg_path("codelldb", "codelldb", { warn = false })
  if vim.uv.fs_stat(mason_codelldb) then
    return mason_codelldb
  end

  return "codelldb"
end

return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "swiftlint", "xcode-build-server", "codelldb" } },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          filetypes = { "swift" },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        swift = { "swift" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = "mason-org/mason.nvim",
    opts = function()
      local dap = require("dap")

      if not dap.adapters.codelldb then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path(),
            args = { "--port", "${port}" },
          },
        }
      end

      dap.configurations.swift = dap.configurations.swift
        or {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch executable",
            program = swift_executable,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      ensure_installed = { "codelldb" },
    },
  },
}
