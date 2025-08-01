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
  original_content = {},
}

-- Default configuration
local default_config = {
  server_port = 38547,
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
local handle_http_request, show_diff_view, generate_diff_content

-- HTTP server implementation
local function create_http_server()
  local server = uv.new_tcp()
  
  server:bind("127.0.0.1", state.config.server_port)
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
  
  -- Parse HTTP POST data
  local body = data:match("\r\n\r\n(.*)$")
  if not body then
    client:write(response)
    client:close()
    return
  end
  
  -- Parse JSON payload
  local ok, diff_data = pcall(vim.json.decode, body)
  if not ok or not diff_data then
    vim.notify("Claude Diff: Invalid diff data received", vim.log.levels.ERROR)
    client:write(response)
    client:close()
    return
  end
  
  -- Store diff and show it
  state.current_diff = diff_data
  show_diff_view(diff_data)
  
  client:write(response)
  client:close()
end

-- Create diff buffer and show visual diff
function show_diff_view(diff_data)
  vim.notify("Debug: show_diff_view called with filename: " .. (diff_data.filename or "nil"), vim.log.levels.INFO)
  
  -- Close existing diff buffer
  if state.diff_buffer and api.nvim_buf_is_valid(state.diff_buffer) then
    api.nvim_buf_delete(state.diff_buffer, { force = true })
  end
  
  -- Create new diff buffer
  state.diff_buffer = api.nvim_create_buf(false, true)
  
  -- Split window and show diff
  vim.cmd("split")
  api.nvim_win_set_buf(0, state.diff_buffer)
  
  -- Set buffer options
  api.nvim_buf_set_option(state.diff_buffer, "buftype", "nofile")
  api.nvim_buf_set_option(state.diff_buffer, "swapfile", false)
  api.nvim_buf_set_option(state.diff_buffer, "filetype", "markdown")
  
  -- Split content into lines properly
  local original_lines = {}
  local new_lines = {}
  
  if diff_data.original_content then
    original_lines = vim.split(diff_data.original_content, "\n")
  end
  
  if diff_data.new_content then
    new_lines = vim.split(diff_data.new_content, "\n")
  end
  
  local test_lines = {
    "# Claude Code Diff",
    "File: " .. (diff_data.filename or "unknown"),
    "",
    "## Original:",
  }
  
  -- Add original content lines
  for _, line in ipairs(original_lines) do
    table.insert(test_lines, line)
  end
  
  table.insert(test_lines, "")
  table.insert(test_lines, "## New:")
  
  -- Add new content lines
  for _, line in ipairs(new_lines) do
    table.insert(test_lines, line)
  end
  
  table.insert(test_lines, "")
  table.insert(test_lines, "Press 'a' to accept, 'r' to reject, 'q' to close")
  
  api.nvim_buf_set_lines(state.diff_buffer, 0, -1, false, test_lines)
  api.nvim_buf_set_option(state.diff_buffer, "modifiable", false)
  
  -- Set buffer keymaps
  local opts = { buffer = state.diff_buffer, silent = true }
  vim.keymap.set("n", "a", function() M.accept_diff() end, opts)
  vim.keymap.set("n", "r", function() M.reject_diff() end, opts)
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
  
  -- Show notification
  vim.notify("📝 Claude wants to modify " .. (diff_data.filename or "unknown") .. ". Press 'a' to accept, 'r' to reject", vim.log.levels.INFO)
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
    vim.cmd("close")
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
    vim.cmd("close")
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
    end,
  })
end

return M