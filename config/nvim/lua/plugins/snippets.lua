return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "mlaursen/vim-react-snippets",
    },
    opts = function()
      require("vim-react-snippets").lazy_load()
    end,
  },
}
