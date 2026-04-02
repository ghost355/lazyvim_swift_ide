-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Exit Terminal Mode with single Esc press
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { noremap = true })
-- Shift-U as Redo
vim.keymap.set("n", "U", "<C-r>", { noremap = true })
