return {
  {
    "Shatur/neovim-ayu",
    name = "ayu",
    opts = function(_, opts)
      opts.overrides = function()
        local colors = require("ayu.colors")
        local bg = vim.g.neovide and colors.bg or "None"

        return {
          Normal = { bg = bg },
          NormalFloat = { bg = bg },
          ColorColumn = { bg = bg },
          SignColumn = { bg = bg },
          Folded = { bg = bg },
          FoldColumn = { bg = bg },
          CursorColumn = { bg = bg },
          VertSplit = { bg = bg },
          SnacksNormalNC = { bg = bg },
          SnacksPicker = { bg = bg },
        }
      end
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "ayu-mirage"
    end,
  },
}
