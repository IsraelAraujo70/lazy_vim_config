-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Indentation
opt.tabstop = 2          -- Number of spaces tabs count for
opt.shiftwidth = 2       -- Size of an indent
opt.expandtab = true     -- Use spaces instead of tabs
opt.smartindent = true   -- Insert indents automatically

-- UI
opt.number = true         -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.wrap = false         -- Disable line wrap
opt.scrolloff = 8        -- Lines of context
opt.sidescrolloff = 8    -- Columns of context
opt.signcolumn = "yes"   -- Always show the signcolumn

-- Search
opt.ignorecase = true    -- Ignore case
opt.smartcase = true     -- Don't ignore case with capitals
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- File handling
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Mouse
opt.mouse = "a"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Show invisible characters
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
