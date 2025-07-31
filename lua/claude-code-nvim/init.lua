-- Claude Code Neovim Integration - Auto Diff Viewer
-- Automatically shows diffs when files are modified and Claude Code is running

local M = {}
local api = vim.api

-- Plugin state
local state = {
  config = {},
  file_snapshots = {}, -- Store file content before changes
  claude_running = false,
}

-- Default configuration
local default_config = {
  check_interval = 2000, -- Check for Claude Code every 2 seconds
  auto_diff = true,
  keymaps = {
    accept_diff = "<leader>ca",
    reject_diff = "<leader>cr",
    show_diff = "<leader>cd",
  },
}

-- Check if Claude Code is running
local function is_claude_running()
  local handle = io.popen("ps aux | grep -E '(claude|node.*claude)' | grep -v grep")
  if not handle then return false end
  
  local result = handle:read("*a")
  handle:close()
  
  return result and result ~= ""
end

-- Take snapshot of current file content
local function take_file_snapshot(bufnr)
  local filename = api.nvim_buf_get_name(bufnr)
  if filename == "" then return end
  
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  state.file_snapshots[filename] = {
    content = table.concat(lines, "\n"),
    timestamp = os.time(),
  }
end

-- Compare current content with snapshot
local function get_file_diff(bufnr)
  local filename = api.nvim_buf_get_name(bufnr)
  if filename == "" or not state.file_snapshots[filename] then 
    return nil 
  end
  
  local current_lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local current_content = table.concat(current_lines, "\n")
  local old_content = state.file_snapshots[filename].content
  
  if current_content == old_content then
    return nil -- No changes
  end
  
  return {
    filename = filename,
    old_content = old_content,
    new_content = current_content,
    old_lines = vim.split(old_content, "\n"),
    new_lines = current_lines,
  }
end

-- Create diff view
local function show_diff_view(diff_data)
  -- Create a new buffer for diff
  local diff_buf = api.nvim_create_buf(false, true)
  
  -- Split window and show diff
  vim.cmd("split")
  api.nvim_win_set_buf(0, diff_buf)
  
  -- Generate diff content
  local diff_lines = {
    "# File: " .. vim.fn.fnamemodify(diff_data.filename, ":t"),
    "# Modified while Claude Code was running",
    "",
    "--- Before",
    "+++ After",
  }
  
  -- Simple line-by-line diff
  local max_lines = math.max(#diff_data.old_lines, #diff_data.new_lines)
  
  for i = 1, max_lines do
    local old_line = diff_data.old_lines[i] or ""
    local new_line = diff_data.new_lines[i] or ""
    
    if old_line == new_line then
      table.insert(diff_lines, " " .. old_line)
    else
      if old_line ~= "" then
        table.insert(diff_lines, "-" .. old_line)
      end
      if new_line ~= "" then
        table.insert(diff_lines, "+" .. new_line)
      end
    end
  end
  
  table.insert(diff_lines, "")
  table.insert(diff_lines, "Press 'a' to accept, 'r' to reject, 'q' to close")
  
  -- Set diff content
  api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff_lines)
  api.nvim_buf_set_option(diff_buf, "filetype", "diff")
  api.nvim_buf_set_option(diff_buf, "modifiable", false)
  
  -- Set keymaps for diff buffer
  vim.keymap.set("n", "a", function()
    M.accept_diff(diff_data)
    vim.cmd("close")
  end, { buffer = diff_buf, silent = true })
  
  vim.keymap.set("n", "r", function()
    M.reject_diff(diff_data)
    vim.cmd("close")
  end, { buffer = diff_buf, silent = true })
  
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = diff_buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = diff_buf, silent = true })
  
  vim.notify("📝 File modified while Claude Code running. Press 'a' to accept, 'r' to reject")
end

-- Accept changes (keep current content)
function M.accept_diff(diff_data)
  -- Update snapshot with current content
  state.file_snapshots[diff_data.filename] = {
    content = diff_data.new_content,
    timestamp = os.time(),
  }
  
  vim.notify("✅ Changes accepted")
end

-- Reject changes (revert to old content)
function M.reject_diff(diff_data)
  -- Find buffer for this file
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_get_name(bufnr) == diff_data.filename then
      -- Revert to old content
      local old_lines = vim.split(diff_data.old_content, "\n")
      api.nvim_buf_set_lines(bufnr, 0, -1, false, old_lines)
      
      -- Update snapshot
      state.file_snapshots[diff_data.filename] = {
        content = diff_data.old_content,
        timestamp = os.time(),
      }
      
      vim.notify("❌ Changes reverted")
      break
    end
  end
end

-- Manual diff show
function M.show_diff()
  local bufnr = api.nvim_get_current_buf()
  local diff_data = get_file_diff(bufnr)
  
  if not diff_data then
    vim.notify("No changes detected")
    return
  end
  
  show_diff_view(diff_data)
end

-- Check Claude Code status and update
local function check_claude_status()
  local was_running = state.claude_running
  state.claude_running = is_claude_running()
  
  if state.claude_running and not was_running then
    -- Claude Code just started - take snapshots of all open files
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
      if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_get_name(bufnr) ~= "" then
        take_file_snapshot(bufnr)
      end
    end
    vim.notify("🤖 Claude Code detected - File monitoring enabled")
  elseif not state.claude_running and was_running then
    vim.notify("🤖 Claude Code stopped - File monitoring disabled")
  end
end

-- Set up file monitoring
local function setup_file_monitoring()
  local group = api.nvim_create_augroup("ClaudeCodeDiffMonitor", { clear = true })
  
  -- Take snapshot when file is opened
  api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
    group = group,
    callback = function(args)
      if state.claude_running then
        take_file_snapshot(args.buf)
      end
    end,
  })
  
  -- Check for changes when file is written
  api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
      if not state.claude_running or not state.config.auto_diff then
        return
      end
      
      -- Small delay to ensure file is written
      vim.defer_fn(function()
        local diff_data = get_file_diff(args.buf)
        if diff_data then
          show_diff_view(diff_data)
        end
      end, 100)
    end,
  })
  
  -- Periodic Claude Code status check
  local timer = vim.loop.new_timer()
  timer:start(1000, state.config.check_interval, function()
    vim.schedule(check_claude_status)
  end)
end

-- Status command
function M.status()
  print("🤖 Claude Code Integration Status:")
  print("Claude Code running: " .. (state.claude_running and "✅ Yes" or "❌ No"))
  print("Auto diff: " .. (state.config.auto_diff and "✅ Enabled" or "❌ Disabled"))
  print("Monitored files: " .. vim.tbl_count(state.file_snapshots))
  
  if vim.tbl_count(state.file_snapshots) > 0 then
    print("Files being monitored:")
    for filename, _ in pairs(state.file_snapshots) do
      print("  - " .. vim.fn.fnamemodify(filename, ":t"))
    end
  end
end

-- Setup function
function M.setup(config)
  state.config = vim.tbl_deep_extend("force", default_config, config or {})
  
  -- Set up file monitoring
  setup_file_monitoring()
  
  -- Create user commands
  api.nvim_create_user_command("ClaudeStatus", M.status, { desc = "Check Claude Code integration status" })
  api.nvim_create_user_command("ClaudeShowDiff", M.show_diff, { desc = "Show diff for current file" })
  
  -- Set up keymaps
  if state.config.keymaps.show_diff then
    vim.keymap.set("n", state.config.keymaps.show_diff, M.show_diff, { desc = "Show Claude diff" })
  end
  
  -- Initial Claude Code check
  check_claude_status()
end

return M