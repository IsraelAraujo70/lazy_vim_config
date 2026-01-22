-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Indentacao com 4 espacos
opt.tabstop = 4        -- Numero de espacos que um <Tab> representa
opt.shiftwidth = 4     -- Numero de espacos para autoindent
opt.softtabstop = 4    -- Numero de espacos ao apertar <Tab>
opt.expandtab = true   -- Converte tabs em espacos
