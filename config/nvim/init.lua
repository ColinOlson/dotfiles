if vim.g.neovide then
  vim.o.columns = 160
  vim.o.lines = 48
  vim.g.neovide_opacity = 0.88
  vim.g.neovide_normal_opacity = 0.88
  vim.g.neovide_window_blurred = true
end

require("vim._core.ui2").enable({})

require("config.lazy")

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "ayu",
  callback = function()
    local colors = require("ayu.colors")

    vim.api.nvim_set_hl(0, "NoicePopup", { bg = colors.line })
    -- vim.api.nvim_set_hl(0, "NoicePopupBorder", { bg = "None" })
  end,
})
