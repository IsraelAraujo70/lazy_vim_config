-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ============================================================================
-- Atalhos estilo VSCode
-- ============================================================================

-- Ctrl+C - Copiar para clipboard
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "Copiar para clipboard" })

-- Ctrl+V - Colar do clipboard
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Colar do clipboard" })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Colar do clipboard" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Colar do clipboard (insert)" })
vim.keymap.set("c", "<C-v>", "<C-r>+", { desc = "Colar do clipboard (command)" })

-- Ctrl+Z - Undo
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo (insert)" })

-- Ctrl+Shift+Z - Redo
vim.keymap.set("n", "<C-S-z>", "<C-r>", { desc = "Redo" })
vim.keymap.set("i", "<C-S-z>", "<C-o><C-r>", { desc = "Redo (insert)" })

-- Ctrl+Y - Redo alternativo (alguns teclados)
vim.keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo" })
vim.keymap.set("i", "<C-y>", "<C-o><C-r>", { desc = "Redo (insert)" })

-- Ctrl+S - Salvar (ja vem no LazyVim, mas garantindo)
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar arquivo" })

-- Ctrl+A - Selecionar tudo
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Selecionar tudo" })

-- Lumen diff (abre em tmux split horizontal)
local function open_lumen_tmux(cmd)
  local tmux_cmd = string.format("tmux split-window -h '%s'", cmd)
  vim.fn.system(tmux_cmd)
end

vim.keymap.set("n", "<leader>gd", function() open_lumen_tmux("lumen diff") end, { desc = "Lumen Diff (Open)" })
vim.keymap.set("n", "<leader>gD", function() open_lumen_tmux("lumen diff HEAD~1") end, { desc = "Lumen Diff vs Last Commit" })
vim.keymap.set("n", "<leader>gw", function() open_lumen_tmux("lumen diff --watch") end, { desc = "Lumen Diff (Watch)" })
vim.keymap.set("n", "<leader>gs", function() open_lumen_tmux("lumen diff --stacked") end, { desc = "Lumen Diff (Stacked)" })
