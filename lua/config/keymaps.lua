-- VS Code Style Keymaps for Neovim
-- Configuração otimizada para parecer com VS Code

local map = vim.keymap.set

-- ========================================
-- 🎯 KEYBINDINGS IDÊNTICOS AO VSCODE
-- ========================================

-- FILE OPERATIONS
map("n", "<C-n>", "<cmd>enew<cr>", { desc = "📄 New File" })
-- map("n", "<C-o>", "<cmd>Telescope find_files<cr>", { desc = "📂 Open File" }) -- Removido - não funcionava
map("n", "<C-s>", "<cmd>w<cr>", { desc = "💾 Save File" })
map("i", "<C-s>", "<cmd>w<cr>", { desc = "💾 Save File" })
map("n", "<C-S-s>", "<cmd>w ", { desc = "💾 Save As..." })
map("i", "<C-S-s>", "<cmd>w ", { desc = "💾 Save As..." })
map("n", "<C-w>", "<cmd>bd<cr>", { desc = "❌ Close File" })

-- NAVIGATION - Atalhos para navegação entre arquivos e buffers
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "🔍 Quick Open" })
map("n", "<C-S-p>", ":", { desc = "⚡ Command Mode" })
map("n", "<leader>E", "<cmd>Neotree toggle<cr>", { desc = "🌳 Toggle Explorer" })
map("n", "<C-`>", "<cmd>ToggleTerm<cr>", { desc = "💻 Toggle Terminal" })

-- SEARCH & REPLACE - Ferramentas de busca e substituição
map("n", "<C-h>", "<cmd>lua require('spectre').toggle()<cr>", { desc = "🔄 Find & Replace" })
map("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "🔍 Find in Files" })

-- MGREP - Semantic grep (usar mgrep como padrão)
local function parse_mgrep_results(query, path)
  local cmd = { "mgrep", query }
  if path and path ~= "" then
    table.insert(cmd, path)
  end

  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("mgrep falhou: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return {}
  end

  local output = vim.split(result.stdout or "", "\n", { trimempty = true })
  local items = {}
  for _, line in ipairs(output) do
    if line ~= "" and not line:match("%[Process exited") then
      local file, start_line, end_line, score = line:match("^%.?/?(.+):(%d+)%-(%d+)%s+%(([%d%.]+)%%")
      if file and start_line and end_line then
        table.insert(items, {
          file = vim.fn.fnamemodify(file, ":p"),
          start_line = tonumber(start_line),
          end_line = tonumber(end_line),
          score = score,
        })
      end
    end
  end

  return items
end

local function open_mgrep_results(query, items)
  if #items == 0 then
    vim.notify("mgrep não encontrou resultados", vim.log.levels.INFO)
    return
  end

  local qf_items = {}
  for _, item in ipairs(items) do
    table.insert(qf_items, {
      filename = item.file,
      lnum = item.start_line,
      col = 1,
      text = string.format("%d-%d (%s%%)", item.start_line, item.end_line, item.score or "?"),
    })
  end
  vim.fn.setqflist({}, " ", { title = "mgrep: " .. query, items = qf_items })

  vim.ui.select(items, {
    prompt = "mgrep resultados",
    format_item = function(item)
      return string.format("%s:%d-%d (%s%%)", item.file, item.start_line, item.end_line, item.score or "?")
    end,
  }, function(choice)
    if not choice then
      return
    end
    vim.cmd("edit " .. vim.fn.fnameescape(choice.file))
    vim.api.nvim_win_set_cursor(0, { choice.start_line, 0 })
  end)
end

local function run_mgrep(query, path)
  if query == "" then
    return
  end

  vim.notify("mgrep: buscando...", vim.log.levels.INFO, { title = "mgrep", timeout = 800 })
  local items = parse_mgrep_results(query, path)

  if #items > 0 then
    vim.notify(string.format("mgrep: %d resultados", #items), vim.log.levels.INFO, { title = "mgrep", timeout = 1500 })
  end

  open_mgrep_results(query, items)
end

map("n", "<leader>sg", function()
  local query = vim.fn.input("mgrep: ")
  run_mgrep(query)
end, { desc = "🔍 Semantic Grep (mgrep)" })

map("n", "<leader>sG", function()
  local query = vim.fn.input("mgrep: ")
  local path = vim.fn.input("Path (default: .): ")
  run_mgrep(query, path)
end, { desc = "🔍 Semantic Grep with Path" })

map("n", "<C-f>", function()
  local query = vim.fn.input("mgrep: ")
  run_mgrep(query)
end, { desc = "🔍 mgrep rápido" })

-- EDIT OPERATIONS - Operações de edição e manipulação de texto
map("v", "<C-c>", '"+y', { desc = "📋 Copy" })
map({ "n", "v", "i" }, "<C-v>", '"+p', { desc = "📋 Paste" })
map("v", "<C-x>", '"+d', { desc = "✂️ Cut" })
map("n", "<C-z>", "u", { desc = "↩️ Undo" })
map("n", "<C-y>", "<C-r>", { desc = "↪️ Redo" })
map("n", "<C-a>", "ggVG", { desc = "🎯 Select All" })

-- DUPLICATE & DELETE - Duplicar e deletar linhas e seleções
-- map("n", "<C-S-d>", "yyp", { desc = "📄 Duplicate Line" }) -- Removido - usuário não usa
-- map("v", "<C-S-d>", "y'>p", { desc = "📄 Duplicate Selection" }) -- Removido - usuário não usa
-- map("n", "<C-S-k>", "dd", { desc = "🗑️ Delete Line" }) -- Removido - usuário não usa

-- MOVE LINES - Mover linhas para cima e para baixo
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "⬆️ Move Line Up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "⬇️ Move Line Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "⬆️ Move Lines Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "⬇️ Move Lines Down" })

-- COMMENTS - Toggle de comentários em linha e bloco
-- Precisa verificar se funciona corretamente
map("n", "<C-_>", "gcc", { desc = "💬 Toggle Comment", remap = true })
map("v", "<C-_>", "gc", { desc = "💬 Toggle Comment", remap = true })

-- TAB NAVIGATION - Removido conforme solicitado pelo usuário
-- map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "➡️ Next Tab" })
-- map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "⬅️ Previous Tab" })
-- map("n", "<C-1>", "<cmd>BufferLineGoToBuffer 1<cr>", { desc = "1️⃣ Go to Tab 1" })
-- map("n", "<C-2>", "<cmd>BufferLineGoToBuffer 2<cr>", { desc = "2️⃣ Go to Tab 2" })
-- map("n", "<C-3>", "<cmd>BufferLineGoToBuffer 3<cr>", { desc = "3️⃣ Go to Tab 3" })
-- map("n", "<C-4>", "<cmd>BufferLineGoToBuffer 4<cr>", { desc = "4️⃣ Go to Tab 4" })
-- map("n", "<C-5>", "<cmd>BufferLineGoToBuffer 5<cr>", { desc = "5️⃣ Go to Tab 5" })

-- ========================================
-- 🛠️ DEVELOPMENT TOOLS - Ferramentas de desenvolvimento
-- ========================================

-- DEBUG - Ferramentas de depuração e breakpoints
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "▶️ Debug: Start/Continue" })
map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "🔴 Toggle Breakpoint" })
map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "⏭️ Step Over" })
map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "⏬ Step Into" })
map("n", "<F12>", function()
  require("dap").step_out()
end, { desc = "⏫ Step Out" })

-- LSP - Language Server Protocol e funcionalidades
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

-- Window navigation - Removido conforme solicitado
-- map("n", "<C-h>", "<C-w>h", { desc = "⬅️ Go to Left Window", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "⬇️ Go to Lower Window", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "⬆️ Go to Upper Window", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "➡️ Go to Right Window", remap = true })

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
    "NEOVIM CHEAT SHEET                              :Ch | <leader>ch",
    "================================================================",
    "",
    "COPILOT (AI)              |  ARQUIVOS",
    "  Ctrl+G  Aceitar         |    Ctrl+S  Salvar",
    "  Ctrl+]  Proxima         |    Ctrl+P  Buscar arquivo",
    "  Ctrl+[  Anterior        |    Ctrl+W  Fechar buffer",
    "  Ctrl+E  Dispensar       |    <leader>E  File Explorer",
    "",
    "NAVEGACAO                 |  BUSCA",
    "  w/b     Palavra +/-     |    /texto   Buscar no arquivo",
    "  0/$     Inicio/Fim      |    n/N      Proximo/Anterior",
    "  gg/G    Topo/Final      |    *        Buscar palavra cursor",
    "  %       Par correspondente   Ctrl+H  Find & Replace",
    "",
    "EDICAO                    |  LSP/CODE",
    "  i/a     Insert antes/depois  gd      Go to Definition",
    "  o/O     Nova linha +/-  |    gr      References",
    "  yy/dd   Copiar/Cortar linha  K       Documentacao",
    "  p/P     Colar depois/antes   F2      Rename",
    "  u       Undo            |    Ctrl+.  Code Actions",
    "  Ctrl+R  Redo            |    S-A-F   Format",
    "",
    "VISUAL MODE               |  MOVIMENTACAO",
    "  v       Selecao caractere    Alt+Up/Down  Mover linha",
    "  V       Selecao linha   |    </> (visual) Indent",
    "  Ctrl+V  Selecao bloco   |    Ctrl+/  Comentar",
    "",
    "TEXT OBJECTS (usar com d/c/y)",
    '  ciw     Change inner word    ci"     Change inner quotes',
    "  di(     Delete inner ()  |    da{     Delete around {}",
    "  yip     Yank inner paragraph",
    "",
    "COMANDOS                  |  SPLITS",
    "  :w :q :wq :q!           |    :sp/:vsp  Horizontal/Vertical",
    "  .       Repetir comando |    Ctrl+W + h/j/k/l  Navegar",
    "",
    "                                           [q] ou [Esc] p/ fechar",
  }

  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, cheat_content)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"

  -- Calculate window size
  local width = math.min(66, vim.o.columns - 4)
  local height = math.min(#cheat_content, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " Cheat Sheet ",
    title_pos = "center",
  })

  -- Set window options
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  -- Close with 'q'
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { silent = true })
end

-- Create the :ch command
vim.api.nvim_create_user_command("Ch", show_cheat_sheet, { desc = "Show cheat sheet" })
map("n", "<leader>ch", show_cheat_sheet, { desc = "📋 Show Cheat Sheet" })

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
