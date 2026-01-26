return {
  {
    "Shatur/neovim-ayu",
    name = "ayu",
    opts = function(_, opts)
      local colors = require("ayu.colors")

      opts.overrides = {
        Normal = { bg = "None" },
        NormalFloat = { bg = "None" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
        SnacksNormalNC = { bg = "None" },
        SnacksPicker = { bg = "None" },
      }
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "ayu-mirage"
    end,
  },
}
