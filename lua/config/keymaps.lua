-- VS Code Style Keymaps for Neovim
-- Configuração otimizada para parecer com VS Code

local map = vim.keymap.set

-- ========================================
-- 🎯 KEYBINDINGS IDÊNTICOS AO VSCODE
-- ========================================

-- FILE OPERATIONS
map("n", "<C-n>", "<cmd>enew<cr>", { desc = "📄 New File" })
map("n", "<C-o>", "<cmd>Telescope find_files<cr>", { desc = "📂 Open File" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "💾 Save File" })
map("i", "<C-s>", "<cmd>w<cr>", { desc = "💾 Save File" })
map("n", "<C-w>", "<cmd>bd<cr>", { desc = "❌ Close File" })

-- NAVIGATION
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "🔍 Quick Open" })
map("n", "<C-S-p>", "<cmd>Telescope commands<cr>", { desc = "⚡ Command Palette" })
map("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "🌳 Toggle Explorer" })
map("n", "<C-`>", "<cmd>ToggleTerm<cr>", { desc = "💻 Toggle Terminal" })

-- SEARCH & REPLACE
map("n", "<C-f>", "/", { desc = "🔍 Find" })
map("n", "<C-h>", "<cmd>lua require('spectre').toggle()<cr>", { desc = "🔄 Find & Replace" })
map("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "🔍 Find in Files" })

-- EDIT OPERATIONS
map("v", "<C-c>", '"+y', { desc = "📋 Copy" })
map({ "n", "v", "i" }, "<C-v>", '"+p', { desc = "📋 Paste" })
map("v", "<C-x>", '"+d', { desc = "✂️ Cut" })
map("n", "<C-z>", "u", { desc = "↩️ Undo" })
map("n", "<C-S-z>", "<C-r>", { desc = "↪️ Redo" })
map("n", "<C-a>", "ggVG", { desc = "🎯 Select All" })

-- DUPLICATE & DELETE
map("n", "<C-S-d>", "yyp", { desc = "📄 Duplicate Line" })
map("v", "<C-S-d>", "y'>p", { desc = "📄 Duplicate Selection" })
map("n", "<C-S-k>", "dd", { desc = "🗑️ Delete Line" })

-- MOVE LINES
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "⬆️ Move Line Up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "⬇️ Move Line Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "⬆️ Move Lines Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "⬇️ Move Lines Down" })

-- COMMENTS
map("n", "<C-/>", "gcc", { desc = "💬 Toggle Comment", remap = true })
map("v", "<C-/>", "gc", { desc = "💬 Toggle Comment", remap = true })

-- TAB NAVIGATION
map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "➡️ Next Tab" })
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "⬅️ Previous Tab" })
map("n", "<C-1>", "<cmd>BufferLineGoToBuffer 1<cr>", { desc = "1️⃣ Go to Tab 1" })
map("n", "<C-2>", "<cmd>BufferLineGoToBuffer 2<cr>", { desc = "2️⃣ Go to Tab 2" })
map("n", "<C-3>", "<cmd>BufferLineGoToBuffer 3<cr>", { desc = "3️⃣ Go to Tab 3" })
map("n", "<C-4>", "<cmd>BufferLineGoToBuffer 4<cr>", { desc = "4️⃣ Go to Tab 4" })
map("n", "<C-5>", "<cmd>BufferLineGoToBuffer 5<cr>", { desc = "5️⃣ Go to Tab 5" })

-- ========================================
-- 🛠️ DEVELOPMENT TOOLS
-- ========================================

-- DEBUG
map("n", "<F5>", function() require("dap").continue() end, { desc = "▶️ Debug: Start/Continue" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "🔴 Toggle Breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "⏭️ Step Over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "⏬ Step Into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "⏫ Step Out" })

-- LSP
map("n", "<C-.>", vim.lsp.buf.code_action, { desc = "💡 Code Action" })
map("v", "<C-.>", vim.lsp.buf.code_action, { desc = "💡 Code Action" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "✏️ Rename" })
map("n", "gd", vim.lsp.buf.definition, { desc = "🎯 Go to Definition" })
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "🔗 References" })
map("n", "K", vim.lsp.buf.hover, { desc = "📖 Hover Documentation" })

-- FORMAT
map({ "n", "v" }, "<S-A-f>", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "🎨 Format Document" })

-- ========================================
-- 🧭 NAVIGATION & WINDOW MANAGEMENT
-- ========================================

-- Better up/down (wrap lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "⬅️ Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "⬇️ Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "⬆️ Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "➡️ Go to Right Window", remap = true })

-- Better indenting
map("v", "<", "<gv", { desc = "⬅️ Indent Left" })
map("v", ">", ">gv", { desc = "➡️ Indent Right" })

-- Clear search highlighting
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "🚫 Clear Search" })

-- ========================================
-- 📋 CHEAT SHEET COMMAND
-- ========================================

-- Função para mostrar cheat sheet
local function show_cheat_sheet()
  local cheat_content = {
    "🎯 NEOVIM CHEAT SHEET (VS Code Style)",
    "======================================",
    "",
    "📁 FILE OPERATIONS:",
    "  Ctrl+N          → New File",
    "  Ctrl+O          → Open File",
    "  Ctrl+S          → Save File",
    "  Ctrl+W          → Close File",
    "",
    "🔍 SEARCH & NAVIGATION:",
    "  Ctrl+P          → Quick Open (Find Files)",
    "  Ctrl+Shift+P    → Command Palette",
    "  Ctrl+B          → Toggle File Explorer",
    "  Ctrl+F          → Find in Current File",
    "  Ctrl+H          → Find & Replace",
    "  Ctrl+Shift+F    → Find in All Files",
    "  Ctrl+`          → Toggle Terminal",
    "",
    "✂️ EDIT OPERATIONS:",
    "  Ctrl+C          → Copy (Visual mode)",
    "  Ctrl+V          → Paste",
    "  Ctrl+X          → Cut (Visual mode)",
    "  Ctrl+Z          → Undo",
    "  Ctrl+Shift+Z    → Redo",
    "  Ctrl+A          → Select All",
    "  Ctrl+Shift+D    → Duplicate Line/Selection",
    "  Ctrl+Shift+K    → Delete Line",
    "",
    "🔄 MOVE & ORGANIZE:",
    "  Alt+Up/Down     → Move Line Up/Down",
    "  Ctrl+/          → Toggle Comment",
    "  < / >           → Indent Left/Right (Visual)",
    "",
    "📑 TAB NAVIGATION:",
    "  Ctrl+Tab        → Next Tab",
    "  Ctrl+Shift+Tab  → Previous Tab",
    "  Ctrl+1-5        → Go to Tab 1-5",
    "",
    "🛠️ DEVELOPMENT:",
    "  F5              → Start/Continue Debug",
    "  F9              → Toggle Breakpoint",
    "  F10/F11/F12     → Step Over/Into/Out",
    "  F2              → Rename Symbol",
    "  Ctrl+.          → Code Actions",
    "  gd              → Go to Definition",
    "  gr              → Find References",
    "  K               → Show Documentation",
    "  Shift+Alt+F     → Format Document",
    "",
    "🧭 WINDOW NAVIGATION:",
    "  Ctrl+H/J/K/L    → Move Between Windows",
    "  j/k             → Move by Visual Lines",
    "",
    "💡 SPECIAL COMMANDS:",
    "  :ch             → Show This Cheat Sheet",
    "  <Esc>           → Clear Search Highlight",
    "",
    "Press 'q' to close this cheat sheet"
  }
  
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, cheat_content)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'markdown'
  
  -- Calculate window size
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#cheat_content + 2, vim.o.lines - 6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    title = ' 📋 Neovim Cheat Sheet ',
    title_pos = 'center'
  })
  
  -- Set window options
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  
  -- Close with 'q'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { silent = true })
end

-- Create the :ch command
vim.api.nvim_create_user_command('Ch', show_cheat_sheet, { desc = 'Show cheat sheet' })
map('n', '<leader>ch', show_cheat_sheet, { desc = '📋 Show Cheat Sheet' })

-- ========================================
-- 🔧 ADDITIONAL USEFUL MAPPINGS
-- ========================================

-- Quick fix/location list
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "📋 Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "🔧 Quickfix List" })

-- Terminal mode mappings
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal: Go Left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal: Go Down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal: Go Up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal: Go Right" })
