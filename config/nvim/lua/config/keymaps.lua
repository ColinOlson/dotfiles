-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { silent = true, noremap = true }
local map = function(mode, keys, cmd, desc)
  opts.desc = desc
  vim.keymap.set(mode, keys, cmd, opts)
end

map("n", "<Tab>", ":bnext<CR>", "Next buffer")
map("n", "<BS>", ":bprev<CR>", "Previous buffer")

map("n", "Q", "<nop>")

map("n", "<leader>gv", ":!git v<CR>", "Gitk")
map("n", "<leader>ga", ":!git fap<CR>", "Git fap")
