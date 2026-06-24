return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gclog",
      "Gdiffsplit",
      "Gvdiffsplit",
    },
    keys = {
      { "<leader>G", "", desc = "+fugitive" },
      { "<leader>Gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>Gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
      { "<leader>Ga", "<cmd>Git add %<cr>", desc = "Git Add Current File" },
      { "<leader>Gu", "<cmd>Git restore --staged %<cr>", desc = "Git Unstage Current File" },
      { "<leader>Gd", "<cmd>Gvdiffsplit<cr>", desc = "Git Diff Current File" },
      { "<leader>Gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
      { "<leader>Gl", "<cmd>Gclog -- %<cr>", desc = "Git Log Current File" },
      { "<leader>Gp", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>GP", "<cmd>Git pull<cr>", desc = "Git Pull" },
    },
  },
}
