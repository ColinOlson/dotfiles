return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {},
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          cmd = "pyright",
        },
        rust_analyzer = {
          cmd = "rust-analyzer",
        },
        nil_ls = {
          enabled = vim.fn.executable("nil") == 1,
          mason = false,
        },
      },
    },
  },
}
