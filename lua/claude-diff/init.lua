-- Claude Code Diff Integration
-- Receives diffs from Claude Code via HTTP and shows them in Neovim

local M = {}
local api = vim.api
local uv = vim.loop

-- Plugin state
local state = {
  config = {},
  server = nil,
  current_diff = nil,
  diff_buffer = nil,
  diff_buffer_new = nil,
  original_content = {},
}

-- Default configuration 
local default_config = {
  server_port_base = 38500,  -- Base port, will find available port
  auto_setup_hooks = true,
  keymaps = {
    accept = "<leader>ca",
    reject = "<leader>cr", 
    show_diff = "<leader>cd",
  },
  diff_options = {
    algorithm = "myers",
    context = 3,
    ignore_whitespace = false,
  },
}

-- Forward declarations
local handle_http_request, show_diff_view, generate_diff_content, find_change_blocks

-- Find available port starting from base port
local function find_available_port(base_port)
  for port = base_port, base_port + 100 do
    local server = uv.new_tcp()
    local ok = pcall(function()
      server:bind("127.0.0.1", port)
      server:close()
    end)
    if ok then
      return port
    end
  end
  return nil
end

-- HTTP server implementation
local function create_http_server()
  -- Find available port
  local port = find_available_port(state.config.server_port_base)
  if not port then
    vim.notify("Claude Diff: Could not find available port", vim.log.levels.ERROR)
    return nil
  end
  
  state.config.server_port = port
  
  local server = uv.new_tcp()
  
  server:bind("127.0.0.1", port)
  server:listen(128, function(err)
    if err then
      vim.notify("Claude Diff: Error starting server: " .. err, vim.log.levels.ERROR)
      return
    end
    
    local client = uv.new_tcp()
    server:accept(client)
    
    client:read_start(function(read_err, data)
      if read_err then
        return
      end
      
      if data then
        vim.schedule(function()
          handle_http_request(client, data)
        end)
      else
        client:close()
      end
    end)
  end)
  
  return server
end

-- Parse HTTP request and handle diff data
function handle_http_request(client, data)
  local response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
  
  pcall(function()
    -- Parse HTTP POST data
    local body = data:match("\r\n\r\n(.*)$")
    if not body then
      return
    end
    
    -- Parse JSON payload
    local ok, diff_data = pcall(vim.json.decode, body)
    if not ok or not diff_data then
      vim.notify("Claude Diff: Invalid diff data received", vim.log.levels.ERROR)
      return
    end
    
    -- Store diff and show it
    state.current_diff = diff_data
    
    -- Call show_diff_view in a protected way
    local show_ok, show_err = pcall(show_diff_view, diff_data)
    if not show_ok then
      vim.notify("Claude Diff: Error showing diff: " .. tostring(show_err), vim.log.levels.ERROR)
    end
  end)
  
  -- Always send response and close connection
  pcall(function()
    client:write(response)
    client:close()
  end)
end

-- Find change blocks like GitHub diff viewer
function find_change_blocks(original_lines, new_lines)
  local blocks = {}
  
  -- Create a more precise diff using Myers algorithm approach
  local function create_line_map(lines)
    local map = {}
    for i, line in ipairs(lines) do
      if not map[line] then
        map[line] = {}
      end
      table.insert(map[line], i)
    end
    return map
  end
  
  -- Find longest common subsequence
  local function find_lcs()
    local orig_map = create_line_map(original_lines)
    local matches = {}
    
    -- Find matching lines
    for j, new_line in ipairs(new_lines) do
      if orig_map[new_line] then
        for _, i in ipairs(orig_map[new_line]) do
          table.insert(matches, {orig = i, new = j, line = new_line})
        end
      end
    end
    
    -- Sort by original line number
    table.sort(matches, function(a, b) return a.orig < b.orig end)
    
    -- Find LCS (longest increasing subsequence in new indices)
    local lcs = {}
    for _, match in ipairs(matches) do
      local best_prev = 0
      for k, prev_match in ipairs(lcs) do
        if prev_match.new < match.new and k > best_prev then
          best_prev = k
        end
      end
      
      -- Insert at the right position
      table.insert(lcs, best_prev + 1, match)
      
      -- Remove elements that are no longer valid
      for k = #lcs, best_prev + 2, -1 do
        if lcs[k].new >= match.new then
          table.remove(lcs, k)
        end
      end
    end
    
    return lcs
  end
  
  local lcs = find_lcs()
  
  -- Create diff blocks based on LCS
  local orig_idx, new_idx = 1, 1
  
  for _, match in ipairs(lcs) do
    -- Check if there are differences before this match
    if orig_idx < match.orig or new_idx < match.new then
      local block = {
        removed = {},
        added = {}
      }
      
      -- Add removed lines
      while orig_idx < match.orig do
        table.insert(block.removed, {
          line_num = orig_idx,
          content = " " .. original_lines[orig_idx]
        })
        orig_idx = orig_idx + 1
      end
      
      -- Add added lines
      while new_idx < match.new do
        table.insert(block.added, {
          line_num = new_idx,
          content = " " .. new_lines[new_idx]
        })
        new_idx = new_idx + 1
      end
      
      if #block.removed > 0 or #block.added > 0 then
        table.insert(blocks, block)
      end
    end
    
    -- Skip the matching line
    orig_idx = match.orig + 1
    new_idx = match.new + 1
  end
  
  -- Handle remaining lines after last match
  if orig_idx <= #original_lines or new_idx <= #new_lines then
    local block = {
      removed = {},
      added = {}
    }
    
    while orig_idx <= #original_lines do
      table.insert(block.removed, {
        line_num = orig_idx,
        content = " " .. original_lines[orig_idx]
      })
      orig_idx = orig_idx + 1
    end
    
    while new_idx <= #new_lines do
      table.insert(block.added, {
        line_num = new_idx,
        content = " " .. new_lines[new_idx]
      })
      new_idx = new_idx + 1
    end
    
    if #block.removed > 0 or #block.added > 0 then
      table.insert(blocks, block)
    end
  end
  
  return blocks
end

-- Create diff buffer and show visual diff side-by-side
function show_diff_view(diff_data)
  vim.notify("Debug: show_diff_view called with filename: " .. (diff_data.filename or "nil"), vim.log.levels.INFO)
  
  -- Close existing diff buffers
  if state.diff_buffer and api.nvim_buf_is_valid(state.diff_buffer) then
    api.nvim_buf_delete(state.diff_buffer, { force = true })
  end
  if state.diff_buffer_new and api.nvim_buf_is_valid(state.diff_buffer_new) then
    api.nvim_buf_delete(state.diff_buffer_new, { force = true })
  end
  
  -- Create two buffers: original (left) and new (right)
  state.diff_buffer = api.nvim_create_buf(false, true)     -- Original buffer
  state.diff_buffer_new = api.nvim_create_buf(false, true) -- New buffer
  
  local filename = vim.fn.fnamemodify(diff_data.filename or "unknown", ":t")
  
  -- Open in new tab
  vim.cmd("tabnew")
  
  -- Get the new tab's window
  local left_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(left_win, state.diff_buffer)
  
  -- Create vertical split for right side
  vim.cmd("vsplit")
  vim.cmd("wincmd l")  -- Move to the new split
  
  local right_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(right_win, state.diff_buffer_new)
  
  -- Adjust window widths (50% each)
  local total_width = vim.o.columns
  local left_width = math.floor(total_width * 0.5)
  local right_width = total_width - left_width
  
  api.nvim_win_set_width(left_win, left_width)
  api.nvim_win_set_width(right_win, right_width)
  
  -- Set buffer options for both buffers
  local buffers = {state.diff_buffer, state.diff_buffer_new}
  for _, buf in ipairs(buffers) do
    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "swapfile", false)
    api.nvim_buf_set_option(buf, "filetype", "diff")
    api.nvim_buf_set_option(buf, "wrap", false)
    api.nvim_buf_set_option(buf, "modifiable", true)
  end
  
  -- Set window options for both windows
  for _, win in ipairs({left_win, right_win}) do
    api.nvim_win_set_option(win, "number", true)
    api.nvim_win_set_option(win, "relativenumber", false)
    api.nvim_win_set_option(win, "signcolumn", "no")
    api.nvim_win_set_option(win, "wrap", false)
  end
  
  -- Split content into lines properly
  local original_lines = {}
  local new_lines = {}
  
  if diff_data.original_content then
    original_lines = vim.split(diff_data.original_content, "\n")
  end
  
  if diff_data.new_content then
    new_lines = vim.split(diff_data.new_content, "\n")
  end
  
  -- Create side-by-side content
  local left_lines = {}  -- Original content
  local right_lines = {} -- New content
  
  -- Header for both sides
  local header = {
    "┌─────────────────────────────────────────────┐",
    "│  🤖 Claude Code - " .. filename .. string.rep(" ", math.max(0, 22 - #filename)) .. "│",
    "└─────────────────────────────────────────────┘",
    "",
    "ORIGINAL CODE",
    string.rep("─", 45),
    ""
  }
  
  local header_new = {
    "┌─────────────────────────────────────────────┐", 
    "│  🤖 Claude Code - " .. filename .. string.rep(" ", math.max(0, 22 - #filename)) .. "│",
    "└─────────────────────────────────────────────┘",
    "",
    "NEW CODE", 
    string.rep("─", 45),
    ""
  }
  
  -- Add headers
  for _, line in ipairs(header) do
    table.insert(left_lines, line)
  end
  for _, line in ipairs(header_new) do
    table.insert(right_lines, line)
  end
  
  -- Find changed blocks
  local blocks = find_change_blocks(original_lines, new_lines)
  
  if #blocks == 0 then
    table.insert(left_lines, "ℹ️  No differences detected")
    table.insert(right_lines, "ℹ️  File is identical")
  else
    -- Show files side by side with synchronized diff view
    -- Left: original file complete
    -- Right: new file complete
    
    -- Add all original lines to left
    for i, line in ipairs(original_lines) do
      table.insert(left_lines, string.format("%3d │ %s", i, line))
    end
    
    -- Add all new lines to right
    for i, line in ipairs(new_lines) do
      table.insert(right_lines, string.format("%3d │ %s", i, line))
    end
    
    -- Pad shorter side to match length
    local max_lines = math.max(#left_lines, #right_lines)
    while #left_lines < max_lines do
      table.insert(left_lines, "")
    end
    while #right_lines < max_lines do
      table.insert(right_lines, "")
    end
  end
  
  -- Add footer
  table.insert(left_lines, "")
  table.insert(right_lines, "")
  table.insert(left_lines, "Press [q] to close")
  table.insert(right_lines, "✅ Changes applied!")
  
  -- Set content to buffers
  api.nvim_buf_set_lines(state.diff_buffer, 0, -1, false, left_lines)
  api.nvim_buf_set_lines(state.diff_buffer_new, 0, -1, false, right_lines)
  
  -- Make buffers read-only
  api.nvim_buf_set_option(state.diff_buffer, "modifiable", false)
  api.nvim_buf_set_option(state.diff_buffer_new, "modifiable", false)
  
  -- Apply syntax highlighting for side-by-side diff
  local namespace = api.nvim_create_namespace("claude_diff")
  
  -- Define highlight groups for side-by-side view
  vim.cmd([[
    highlight ClaudeDiffRemoved guibg=#4A1E1E guifg=#FF6B6B ctermfg=red ctermbg=darkred gui=bold cterm=bold
    highlight ClaudeDiffAdded guibg=#1E4A1E guifg=#50C878 ctermfg=green ctermbg=darkgreen gui=bold cterm=bold  
    highlight ClaudeDiffContext guifg=#7C7C7C ctermfg=gray gui=NONE cterm=NONE
    highlight ClaudeDiffHeader guifg=#61AFEF ctermfg=blue gui=bold cterm=bold
    highlight ClaudeDiffSeparator guifg=#5C6370 ctermfg=darkgray
  ]])
  
  -- Create diff markers for highlighting
  local left_highlights = {}
  local right_highlights = {}
  
  -- Simple line-by-line comparison to find changes
  local max_check = math.max(#original_lines, #new_lines)
  
  for i = 1, max_check do
    local orig = original_lines[i] or ""
    local new = new_lines[i] or ""
    
    if orig ~= new then
      if orig ~= "" then
        left_highlights[i] = "removed"
      end
      if new ~= "" then
        right_highlights[i] = "added"
      end
    end
  end
  
  -- Apply highlights and signs to buffers
  -- First, apply headers
  for i = 1, 7 do -- Header lines
    if i <= #left_lines then
      api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffHeader", i-1, 0, -1)
    end
    if i <= #right_lines then
      api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffHeader", i-1, 0, -1)
    end
  end
  
  -- Apply highlights to content lines
  for i = 8, #left_lines do -- Skip header lines
    local line_idx = i - 1
    local line_num = i - 7 -- Adjust for header offset
    
    -- Left buffer highlights
    if left_highlights[line_num] == "removed" then
      api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffRemoved", line_idx, 0, -1)
    end
  end
  
  for i = 8, #right_lines do -- Skip header lines
    local line_idx = i - 1
    local line_num = i - 7 -- Adjust for header offset
    
    -- Right buffer highlights
    if right_highlights[line_num] == "added" then
      api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffAdded", line_idx, 0, -1)
    end
  end
  
  -- Set buffer keymaps for both buffers
  local function close_diff()
    -- Close diff buffers properly
    if state.diff_buffer and api.nvim_buf_is_valid(state.diff_buffer) then
      api.nvim_buf_delete(state.diff_buffer, { force = true })
    end
    if state.diff_buffer_new and api.nvim_buf_is_valid(state.diff_buffer_new) then
      api.nvim_buf_delete(state.diff_buffer_new, { force = true })
    end
    
    -- Close the entire diff tab and return to previous tab
    pcall(function()
      vim.cmd("tabclose")
    end)
  end
  
  -- Set keymaps for both buffers
  for _, buf in ipairs({state.diff_buffer, state.diff_buffer_new}) do
    local opts = { buffer = buf, silent = true }
    vim.keymap.set("n", "q", close_diff, opts)
    vim.keymap.set("n", "<Esc>", close_diff, opts)
    vim.keymap.set("n", "<CR>", close_diff, opts)
  end
  
  -- Add synchronized scrolling with improved logic
  local function sync_scroll()
    local current_win = api.nvim_get_current_win()
    local other_win = (current_win == left_win) and right_win or left_win
    
    if api.nvim_win_is_valid(other_win) and api.nvim_win_is_valid(current_win) then
      local cursor = api.nvim_win_get_cursor(current_win)
      local line = cursor[1]
      
      -- Get current window's top line for viewport sync
      local topline = vim.fn.line('w0', current_win)
      
      -- Set the other window to the same line and viewport
      pcall(function()
        api.nvim_win_set_cursor(other_win, {line, 0})
        -- Also sync the viewport (what's visible)
        api.nvim_win_call(other_win, function()
          local cmd = string.format("normal! %dzt", topline)
          vim.cmd(cmd)
        end)
      end)
    end
  end
  
  -- Set up scroll synchronization for both windows  
  for _, win in ipairs({left_win, right_win}) do
    local buf = api.nvim_win_get_buf(win)
    api.nvim_create_autocmd({"CursorMoved", "WinScrolled"}, {
      buffer = buf,
      callback = sync_scroll
    })
  end
  
  -- Show notification
  vim.notify("🤖 Claude Code applied changes to " .. vim.fn.fnamemodify(diff_data.filename or "unknown", ":t"), vim.log.levels.INFO)
end

-- Generate diff content for display
function generate_diff_content(diff_data)
  local lines = {
    "# Claude Code Diff Preview",
    "# File: " .. vim.fn.fnamemodify(diff_data.filename, ":t"),
    "# " .. string.rep("=", 50),
    "",
    "## Original:",
  }
  
  -- Add original content with line numbers
  local original_lines = vim.split(diff_data.original_content, "\n")
  for i, line in ipairs(original_lines) do
    table.insert(lines, string.format("%3d | %s", i, line))
  end
  
  table.insert(lines, "")
  table.insert(lines, "## Proposed Changes:")
  
  -- Add new content with line numbers
  local new_lines = vim.split(diff_data.new_content, "\n")
  for i, line in ipairs(new_lines) do
    table.insert(lines, string.format("%3d | %s", i, line))
  end
  
  table.insert(lines, "")
  table.insert(lines, "## Actions:")
  table.insert(lines, "Press 'a' to ACCEPT changes")
  table.insert(lines, "Press 'r' to REJECT changes") 
  table.insert(lines, "Press 'q' or <Esc> to close without action")
  
  return lines
end

-- Accept the proposed changes
function M.accept_diff()
  if not state.current_diff then
    vim.notify("No diff to accept", vim.log.levels.WARN)
    return
  end
  
  local diff_data = state.current_diff
  
  -- Apply changes to the file
  local bufnr = vim.fn.bufnr(diff_data.filename)
  if bufnr == -1 then
    -- File not open, open it
    vim.cmd("edit " .. vim.fn.fnameescape(diff_data.filename))
    bufnr = vim.fn.bufnr(diff_data.filename)
  end
  
  if bufnr ~= -1 then
    local new_lines = vim.split(diff_data.new_content, "\n")
    api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    vim.cmd("write")
  end
  
  -- Close diff view
  if state.diff_buffer and api.nvim_buf_is_valid(state.diff_buffer) then
    api.nvim_buf_delete(state.diff_buffer, { force = true })
  end
  if state.diff_buffer_new and api.nvim_buf_is_valid(state.diff_buffer_new) then
    api.nvim_buf_delete(state.diff_buffer_new, { force = true })
  end
  
  state.current_diff = nil
  vim.notify("✅ Changes accepted and applied", vim.log.levels.INFO)
end

-- Reject the proposed changes
function M.reject_diff()
  if not state.current_diff then
    vim.notify("No diff to reject", vim.log.levels.WARN)
    return
  end
  
  -- Close diff view
  if state.diff_buffer and api.nvim_buf_is_valid(state.diff_buffer) then
    api.nvim_buf_delete(state.diff_buffer, { force = true })
  end
  if state.diff_buffer_new and api.nvim_buf_is_valid(state.diff_buffer_new) then
    api.nvim_buf_delete(state.diff_buffer_new, { force = true })
  end
  
  state.current_diff = nil
  vim.notify("❌ Changes rejected", vim.log.levels.INFO)
end

-- Show current diff (manual command)
function M.show_diff()
  if state.current_diff then
    show_diff_view(state.current_diff)
  else
    vim.notify("No current diff to show", vim.log.levels.WARN)
  end
end

-- Show integration status
function M.status()
  print("🤖 Claude Code Diff Integration Status:")
  print("Server running: " .. (state.server and "✅ Yes" or "❌ No"))
  print("Server port: " .. state.config.server_port)
  print("Current diff: " .. (state.current_diff and "✅ Yes" or "❌ No"))
  
  if state.current_diff then
    print("Pending file: " .. state.current_diff.filename)
  end
  
  -- Check bridge installation
  local installer = require("claude-diff.install")
  local bridge_ok = installer.check_bridge()
  print("Bridge script: " .. (bridge_ok and "✅ Installed" or "❌ Not installed"))
end

-- Run Claude Code with a prompt
function M.run_claude(prompt)
  if not prompt or prompt == "" then
    prompt = vim.fn.input("Claude Code prompt: ")
    if prompt == "" then
      return
    end
  end
  
  -- Change to current file's directory if in a file
  local current_file = api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  
  if current_file ~= "" then
    local file_dir = vim.fn.fnamemodify(current_file, ":h")
    if vim.fn.isdirectory(file_dir) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(file_dir))
    end
  end
  
  -- Execute claude command
  local claude_cmd = "claude " .. vim.fn.shellescape(prompt)
  
  vim.notify("🤖 Running Claude Code: " .. prompt, vim.log.levels.INFO)
  
  -- Run in terminal
  vim.cmd("split")
  vim.cmd("terminal " .. claude_cmd)
  
  -- Restore original directory
  vim.cmd("cd " .. vim.fn.fnameescape(cwd))
end

-- Setup Claude Code hooks automatically
local function setup_claude_hooks()
  if not state.config.auto_setup_hooks then
    return
  end
  
  -- Set environment variables to make Claude Code think we're in VSCode
  vim.env.TERM_PROGRAM = "vscode"
  vim.env.GIT_ASKPASS = "/usr/share/code/resources/app/extensions/git/dist/askpass.sh"
  vim.env.OPENCODE_CALLER = "vscode"
  
  -- Write port info for bridge script
  local port_file = "/tmp/claude-diff/nvim-port-" .. vim.fn.getpid()
  vim.fn.mkdir("/tmp/claude-diff", "p")
  vim.fn.writefile({tostring(state.config.server_port)}, port_file)
  
  -- First, install the bridge script
  local installer = require("claude-diff.install")
  if not installer.check_bridge() then
    vim.notify("Installing Claude bridge script...", vim.log.levels.INFO)
    if not installer.install_bridge() then
      vim.notify("❌ Failed to install bridge script. Claude integration won't work.", vim.log.levels.ERROR)
      return
    end
  end
  
  local claude_dir = os.getenv("HOME") .. "/.claude"
  local settings_file = claude_dir .. "/settings.json"
  
  -- Create .claude directory if it doesn't exist
  vim.fn.mkdir(claude_dir, "p")
  
  -- Read existing settings or create new
  local settings = {}
  if vim.fn.filereadable(settings_file) == 1 then
    local content = vim.fn.readfile(settings_file)
    if #content > 0 then
      local ok, parsed = pcall(vim.json.decode, table.concat(content, "\n"))
      if ok then
        settings = parsed
      end
    end
  end
  
  -- Add our hook configuration
  if not settings.hooks then
    settings.hooks = {}
  end
  
  if not settings.hooks.PostToolUse then
    settings.hooks.PostToolUse = {}
  end
  
  -- Add our hook matcher
  local hook_config = {
    matcher = "Edit|MultiEdit|Write",
    hooks = {
      {
        type = "command",
        command = "nvim-claude-bridge"
      }
    }
  }
  
  -- Check if our hook already exists
  local hook_exists = false
  for _, hook in ipairs(settings.hooks.PostToolUse) do
    if hook.matcher == "Edit|MultiEdit|Write" then
      hook_exists = true
      break
    end
  end
  
  if not hook_exists then
    table.insert(settings.hooks.PostToolUse, hook_config)
    
    -- Write settings back
    local json_content = vim.json.encode(settings)
    vim.fn.writefile(vim.split(json_content, "\n"), settings_file)
    
    vim.notify("📝 Claude Code hooks configured automatically", vim.log.levels.INFO)
  end
end

-- Setup function
function M.setup(config)
  state.config = vim.tbl_deep_extend("force", default_config, config or {})
  
  -- Start HTTP server
  state.server = create_http_server()
  if state.server then
    vim.notify("🚀 Claude Diff server started on port " .. state.config.server_port, vim.log.levels.INFO)
  end
  
  -- Setup Claude Code hooks
  setup_claude_hooks()
  
  -- Create user commands
  api.nvim_create_user_command("ClaudeDiff", M.show_diff, { desc = "Show current Claude diff" })
  api.nvim_create_user_command("ClaudeAccept", M.accept_diff, { desc = "Accept Claude changes" })
  api.nvim_create_user_command("ClaudeReject", M.reject_diff, { desc = "Reject Claude changes" })
  api.nvim_create_user_command("ClaudeStatus", M.status, { desc = "Show Claude integration status" })
  
  -- Claude Code execution command
  api.nvim_create_user_command("ClaudeCode", function(opts)
    M.run_claude(opts.args)
  end, { 
    desc = "Run Claude Code with prompt",
    nargs = "*",
    complete = function()
      return {
        "fix this function",
        "add documentation", 
        "optimize this code",
        "add error handling",
        "refactor this",
        "add tests",
      }
    end
  })
  
  -- Installation management commands
  api.nvim_create_user_command("ClaudeInstallBridge", function()
    local installer = require("claude-diff.install")
    installer.install_bridge()
  end, { desc = "Install Claude bridge script" })
  
  api.nvim_create_user_command("ClaudeCheckBridge", function()
    local installer = require("claude-diff.install")
    installer.check_bridge()
  end, { desc = "Check Claude bridge installation" })
  
  api.nvim_create_user_command("ClaudeUninstallBridge", function()
    local installer = require("claude-diff.install")
    installer.uninstall_bridge()
  end, { desc = "Uninstall Claude bridge script" })
  
  -- Set up global keymaps
  if state.config.keymaps.show_diff then
    vim.keymap.set("n", state.config.keymaps.show_diff, M.show_diff, { desc = "Show Claude diff" })
  end
  if state.config.keymaps.accept then
    vim.keymap.set("n", state.config.keymaps.accept, M.accept_diff, { desc = "Accept Claude changes" })
  end
  if state.config.keymaps.reject then
    vim.keymap.set("n", state.config.keymaps.reject, M.reject_diff, { desc = "Reject Claude changes" })
  end
  
  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if state.server then
        state.server:close()
      end
      -- Clean up port file
      local port_file = "/tmp/claude-diff/nvim-port-" .. vim.fn.getpid()
      if vim.fn.filereadable(port_file) == 1 then
        vim.fn.delete(port_file)
      end
    end,
  })
end

return M