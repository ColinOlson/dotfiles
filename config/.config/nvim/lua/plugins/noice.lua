-- return {
--   "folke/noice.nvim",
--   config = function(_, opts)
--     opts.hover = {
--       border = {
--         style = "rounded",
--       },
--     }
--   end,
-- }
--
return {
  "folke/noice.nvim",
  opts = {
    views = {
      hover = {
        border = { style = "rounded" },
        position = {
          row = 2,
          col = 2,
        },
      },
    },
  },
}
