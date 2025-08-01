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
    algorithm = "github",         -- Algorithm: github, myers, patience, histogram 
    context = 3,                  -- Lines of context around changes
    full_context = true,          -- Show full context like GitHub (vs minimal hunks)
    ignore_whitespace = false,    -- Ignore whitespace differences
    ignore_blank_lines = false,   -- Ignore blank line differences
    word_diff = true,             -- Enable word-level diff highlighting
    minimal_diff = false,         -- Show only changed blocks, not entire file
  },
}

-- Forward declarations
local handle_http_request, show_diff_view, generate_diff_content, find_change_blocks

-- Find available port starting from base port
local function find_available_port(base_port)
  for port = base_port, base_port + 100 do
    -- Check if port is already in use by existing Neovim instances
    local port_file = "/tmp/claude-diff/nvim-port-" .. vim.fn.getpid()
    local port_in_use = false
    
    -- Check existing port files
    local port_files = vim.fn.glob("/tmp/claude-diff/nvim-port-*", false, true)
    for _, file in ipairs(port_files) do
      if vim.fn.filereadable(file) == 1 then
        local existing_port = tonumber(vim.fn.readfile(file)[1])
        if existing_port == port then
          port_in_use = true
          break
        end
      end
    end
    
    if not port_in_use then
      -- Test if we can actually bind to this port
      local server = uv.new_tcp()
      local ok = pcall(function()
        server:bind("127.0.0.1", port)
        server:close()
      end)
      if ok then
        return port
      end
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

-- GitHub-style Diff Algorithm with proper block grouping
function find_change_blocks(original_lines, new_lines)
  local context_lines = state.config.diff_options.context or 3
  local full_context = state.config.diff_options.full_context or false
  local ignore_whitespace = state.config.diff_options.ignore_whitespace
  local ignore_blank_lines = state.config.diff_options.ignore_blank_lines
  
  -- If full_context is enabled, use larger context windows
  if full_context then
    context_lines = math.max(context_lines, 10)
  end
  
  -- Simple unified diff approach like GitHub
  local function create_unified_diff()
    local hunks = {}
    local i, j = 1, 1  -- original and new line indices
    
    while i <= #original_lines or j <= #new_lines do
      local hunk_start_orig = i
      local hunk_start_new = j
      local changes = {}
      local has_changes = false
      
      -- Scan for differences
      while i <= #original_lines and j <= #new_lines do
        local orig_line = original_lines[i] or ""
        local new_line = new_lines[j] or ""
        
        -- Normalize for comparison if needed
        local norm_orig = orig_line
        local norm_new = new_line
        
        if ignore_whitespace then
          norm_orig = orig_line:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
          norm_new = new_line:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        end
        
        if ignore_blank_lines and norm_orig:match("^%s*$") and norm_new:match("^%s*$") then
          norm_orig = ""
          norm_new = ""
        end
        
        if norm_orig == norm_new then
          -- Lines match
          table.insert(changes, {
            type = "equal",
            orig_line = i,
            new_line = j,
            content = orig_line
          })
          i = i + 1
          j = j + 1
        else
          -- Lines differ - this is where we need to be smart
          has_changes = true
          
          -- Look ahead to see if this is a simple replacement or insertion/deletion
          local found_match_ahead = false
          local lookahead_orig, lookahead_new = i + 1, j + 1
          
          -- Check if original line appears later in new (deletion)
          for k = j, math.min(j + 10, #new_lines) do
            if original_lines[i] == new_lines[k] then
              -- Found original line later, so new lines before it are insertions
              for insert_idx = j, k - 1 do
                table.insert(changes, {
                  type = "insert",
                  new_line = insert_idx,
                  content = new_lines[insert_idx]
                })
              end
              j = k
              found_match_ahead = true
              break
            end
          end
          
          if not found_match_ahead then
            -- Check if new line appears later in original (insertion)
            for k = i, math.min(i + 10, #original_lines) do
              if new_lines[j] == original_lines[k] then
                -- Found new line later, so original lines before it are deletions
                for delete_idx = i, k - 1 do
                  table.insert(changes, {
                    type = "delete",
                    orig_line = delete_idx,
                    content = original_lines[delete_idx]
                  })
                end
                i = k
                found_match_ahead = true
                break
              end
            end
          end
          
          if not found_match_ahead then
            -- No match found ahead, treat as replacement
            table.insert(changes, {
              type = "delete",
              orig_line = i,
              content = original_lines[i]
            })
            table.insert(changes, {
              type = "insert", 
              new_line = j,
              content = new_lines[j]
            })
            i = i + 1
            j = j + 1
          end
        end
        
        -- If we've found changes and then several matching lines, finish this hunk
        if has_changes then
          local consecutive_matches = 0
          local temp_i, temp_j = i, j
          
          while temp_i <= #original_lines and temp_j <= #new_lines and 
                (original_lines[temp_i] or "") == (new_lines[temp_j] or "") do
            consecutive_matches = consecutive_matches + 1
            temp_i = temp_i + 1
            temp_j = temp_j + 1
            
            local threshold = full_context and context_lines or context_lines * 2
            if consecutive_matches >= threshold then
              -- Add context after and finish hunk
              for ctx = 1, context_lines do
                if i + ctx - 1 <= #original_lines then
                  table.insert(changes, {
                    type = "equal",
                    orig_line = i + ctx - 1,
                    new_line = j + ctx - 1,
                    content = original_lines[i + ctx - 1]
                  })
                end
              end
              break
            end
          end
          
          local threshold = full_context and context_lines or context_lines * 2
          if consecutive_matches >= threshold then
            break
          end
        end
      end
      
      -- Handle remaining lines
      while i <= #original_lines do
        table.insert(changes, {
          type = "delete",
          orig_line = i,
          content = original_lines[i]
        })
        i = i + 1
        has_changes = true
      end
      
      while j <= #new_lines do
        table.insert(changes, {
          type = "insert",
          new_line = j,
          content = new_lines[j]
        })
        j = j + 1
        has_changes = true
      end
      
      -- Create hunk if there were changes
      if has_changes and #changes > 0 then
        -- Add context before
        local context_before = {}
        local start_context = math.max(1, hunk_start_orig - context_lines)
        for ctx = start_context, hunk_start_orig - 1 do
          if ctx > 0 and ctx <= #original_lines then
            table.insert(context_before, {
              type = "equal",
              orig_line = ctx,
              new_line = ctx,  -- approximate
              content = original_lines[ctx]
            })
          end
        end
        
        -- Combine context_before + changes
        local all_changes = {}
        for _, ctx in ipairs(context_before) do
          table.insert(all_changes, ctx)
        end
        for _, change in ipairs(changes) do
          table.insert(all_changes, change)
        end
        
        table.insert(hunks, {
          start_orig = start_context,
          start_new = hunk_start_new - #context_before,
          changes = all_changes
        })
      end
    end
    
    return hunks
  end
  
  return create_unified_diff()
end

-- Helper function to calculate word-level diff for intra-line changes
local function calculate_word_diff(old_line, new_line)
  if old_line == new_line then
    return {type = "equal", content = old_line}
  end
  
  local old_words = vim.split(old_line, "%s+")
  local new_words = vim.split(new_line, "%s+")
  
  -- Simple word-level LCS for intra-line diff
  local function word_lcs(a, b)
    local m, n = #a, #b
    local dp = {}
    
    for i = 0, m do
      dp[i] = {}
      for j = 0, n do
        if i == 0 or j == 0 then
          dp[i][j] = 0
        elseif a[i] == b[j] then
          dp[i][j] = dp[i-1][j-1] + 1
        else
          dp[i][j] = math.max(dp[i-1][j], dp[i][j-1])
        end
      end
    end
    
    -- Backtrack to find the changes
    local result = {}
    local i, j = m, n
    
    while i > 0 and j > 0 do
      if a[i] == b[j] then
        table.insert(result, 1, {type = "equal", word = a[i]})
        i, j = i - 1, j - 1
      elseif dp[i-1][j] > dp[i][j-1] then
        table.insert(result, 1, {type = "removed", word = a[i]})
        i = i - 1
      else
        table.insert(result, 1, {type = "added", word = b[j]})
        j = j - 1
      end
    end
    
    while i > 0 do
      table.insert(result, 1, {type = "removed", word = a[i]})
      i = i - 1
    end
    
    while j > 0 do
      table.insert(result, 1, {type = "added", word = b[j]})
      j = j - 1
    end
    
    return result
  end
  
  return word_lcs(old_words, new_words)
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
  
  -- Find changed hunks using GitHub-style algorithm
  local hunks = find_change_blocks(original_lines, new_lines)
  
  if #hunks == 0 then
    table.insert(left_lines, "ℹ️  No differences detected")
    table.insert(right_lines, "ℹ️  File is identical")
  else
    -- Process each hunk without duplication
    for hunk_idx, hunk in ipairs(hunks) do
      -- Add hunk separator if not first hunk
      if hunk_idx > 1 then
        table.insert(left_lines, "")
        table.insert(right_lines, "")
        table.insert(left_lines, "  " .. string.rep("⋯", 20))
        table.insert(right_lines, "  " .. string.rep("⋯", 20))
        table.insert(left_lines, "")
        table.insert(right_lines, "")
      end
      
      -- Group consecutive deletes and inserts to detect modifications
      local i = 1
      while i <= #hunk.changes do
        local change = hunk.changes[i]
        
        if change.type == "equal" then
          -- Context line - show on both sides with same line number
          local line_num = change.orig_line or change.new_line
          local line_content = string.format("%3d │ %s", line_num, change.content)
          table.insert(left_lines, line_content)
          table.insert(right_lines, line_content)
          i = i + 1
          
        elseif change.type == "delete" then
          -- Check if there's a corresponding insert (modification)
          local j = i
          local deletes = {}
          local inserts = {}
          
          -- Collect consecutive deletes
          while j <= #hunk.changes and hunk.changes[j].type == "delete" do
            table.insert(deletes, hunk.changes[j])
            j = j + 1
          end
          
          -- Collect consecutive inserts
          while j <= #hunk.changes and hunk.changes[j].type == "insert" do
            table.insert(inserts, hunk.changes[j])
            j = j + 1
          end
          
          -- Process as modification or pure delete/insert
          if #deletes > 0 and #inserts > 0 then
            -- Check if lines are actually modified or just moved
            local k_del = 1
            local k_ins = 1
            
            while k_del <= #deletes or k_ins <= #inserts do
              local del = deletes[k_del]
              local ins = inserts[k_ins]
              
              if del and ins then
                -- Compare content to see if it's actually modified
                local del_content = del.content:gsub("^%s+", ""):gsub("%s+$", "")
                local ins_content = ins.content:gsub("^%s+", ""):gsub("%s+$", "")
                
                if del_content == ins_content then
                  -- Lines are identical, just moved - show as context
                  local left_content = string.format("%3d │ %s", del.orig_line, del.content)
                  local right_content = string.format("%3d │ %s", ins.new_line, ins.content)
                  table.insert(left_lines, left_content)
                  table.insert(right_lines, right_content)
                else
                  -- Lines are actually modified - show with yellow highlight
                  local left_content = string.format("%3d │~%s", del.orig_line, del.content)
                  local right_content = string.format("%3d │~%s", ins.new_line, ins.content)
                  table.insert(left_lines, left_content)
                  table.insert(right_lines, right_content)
                end
                k_del = k_del + 1
                k_ins = k_ins + 1
              elseif del then
                -- More deletes than inserts - this is a real deletion
                local left_content = string.format("%3d │-%s", del.orig_line, del.content)
                local right_content = "    │ "
                table.insert(left_lines, left_content)
                table.insert(right_lines, right_content)
                k_del = k_del + 1
              elseif ins then
                -- More inserts than deletes - this is a real insertion
                local left_content = "    │ "
                local right_content = string.format("%3d │+%s", ins.new_line, ins.content)
                table.insert(left_lines, left_content)
                table.insert(right_lines, right_content)
                k_ins = k_ins + 1
              end
            end
            
            i = j
          else
            -- Pure deletes (no corresponding inserts)
            for _, del in ipairs(deletes) do
              local left_content = string.format("%3d │-%s", del.orig_line, del.content)
              local right_content = "    │ "
              table.insert(left_lines, left_content)
              table.insert(right_lines, right_content)
            end
            i = j
          end
          
        elseif change.type == "insert" then
          -- Pure insert (shouldn't happen after our grouping, but handle it)
          local left_content = "    │ "
          local right_content = string.format("%3d │+%s", change.new_line, change.content)
          table.insert(left_lines, left_content)
          table.insert(right_lines, right_content)
          i = i + 1
        end
      end
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
    highlight ClaudeDiffModified guibg=#4A4A1E guifg=#FFEB3B ctermfg=yellow ctermbg=darkyellow gui=bold cterm=bold
    highlight ClaudeDiffModifiedText guibg=#5A5A2E guifg=#FFF59D ctermfg=lightyellow ctermbg=darkyellow gui=bold,underline cterm=bold,underline
    highlight ClaudeDiffContext guifg=#7C7C7C ctermfg=gray gui=NONE cterm=NONE
    highlight ClaudeDiffHeader guifg=#61AFEF ctermfg=blue gui=bold cterm=bold
    highlight ClaudeDiffSeparator guifg=#5C6370 ctermfg=darkgray
  ]])
  
  -- Apply precise highlighting based on diff blocks
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
    local line_content = left_lines[i]
    
    if line_content then
      -- Check for modification marker
      if line_content:match("^%s*%d+%s*│~") then
        api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffModified", line_idx, 0, -1)
      -- Check for deletion marker
      elseif line_content:match("^%s*%d+%s*│%-") then
        api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffRemoved", line_idx, 0, -1)
      -- Check for context separator
      elseif line_content:match("⋯") then
        api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffSeparator", line_idx, 0, -1)
      -- Context lines (normal highlighting)
      elseif line_content:match("^%s*%d+%s*│%s") then
        api.nvim_buf_add_highlight(state.diff_buffer, namespace, "ClaudeDiffContext", line_idx, 0, -1)
      end
    end
  end
  
  for i = 8, #right_lines do -- Skip header lines
    local line_idx = i - 1
    local line_content = right_lines[i]
    
    if line_content then
      -- Check for modification marker
      if line_content:match("^%s*%d+%s*│~") then
        api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffModified", line_idx, 0, -1)
      -- Check for addition marker
      elseif line_content:match("^%s*%d+%s*│%+") then
        api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffAdded", line_idx, 0, -1)
      -- Check for context separator
      elseif line_content:match("⋯") then
        api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffSeparator", line_idx, 0, -1)
      -- Context lines (normal highlighting)
      elseif line_content:match("^%s*%d+%s*│%s") then
        api.nvim_buf_add_highlight(state.diff_buffer_new, namespace, "ClaudeDiffContext", line_idx, 0, -1)
      end
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