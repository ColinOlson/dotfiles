-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = function(mode, keys, cmd, desc)
	vim.keymap.set(mode, keys, cmd, { silent = true, noremap = true, desc = desc })
end

map("n", "<Tab>", ":bnext<CR>", "Next buffer")
map("n", "<BS>", ":bprev<CR>", "Previous buffer")

map("n", "<D-c>", '"+yy', "Copy line to clipboard")
map("x", "<D-c>", '"+y', "Copy selection to clipboard")
map({ "n", "x" }, "<D-v>", '"+p', "Paste from clipboard")
map("i", "<D-v>", "<C-r>+", "Paste from clipboard")

map("n", "Q", "<nop>")

map("n", "<leader>gv", ":!git v<CR>", "Gitk")
map("n", "<leader>ga", ":!git fap<CR>", "Git fap")
