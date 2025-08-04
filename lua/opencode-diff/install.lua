-- OpenCode Bridge Installation Module
-- Handles installation and management of the nvim-opencode-bridge script

local M = {}

-- Get bridge script installation path
local function get_bridge_path()
  -- Try to find a suitable installation directory
  local paths = {
    os.getenv("HOME") .. "/.local/bin",
    os.getenv("HOME") .. "/bin",
    "/usr/local/bin",
  }
  
  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 1 and vim.fn.filewritable(path) == 2 then
      return path .. "/nvim-opencode-bridge"
    end
  end
  
  -- Fallback: create ~/.local/bin if it doesn't exist
  local local_bin = os.getenv("HOME") .. "/.local/bin"
  vim.fn.mkdir(local_bin, "p")
  return local_bin .. "/nvim-opencode-bridge"
end

-- Smart Bridge script content with git-based file discovery
local function get_bridge_script_content()
  return [[#!/bin/bash

# OpenCode to Neovim Bridge Script
# Receives file path as first argument from OpenCode hooks

ACTION="$OPENCODE_ACTION"

# Get file path from command line argument (OpenCode passes $FILE as argument)
FILE_PATH="$1"

# Exit if no file specified
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Function to get original content using git
get_original_content() {
    local file="$1"
    local relative_path
    
    # Get relative path from git root
    if git rev-parse --git-dir >/dev/null 2>&1; then
        # Get the relative path from git root
        relative_path=$(git ls-files --full-name "$file" 2>/dev/null)
        
        if [ -n "$relative_path" ]; then
            # File is tracked by git, get HEAD version
            git show "HEAD:$relative_path" 2>/dev/null
            return $?
        fi
    fi
    
    # Fallback: return empty (no original content available)
    echo ""
    return 0
}

# Function to find active Neovim port
find_nvim_port() {
    # Method 1: Check port files in /tmp/opencode-diff
    for port_file in /tmp/opencode-diff/nvim-port-*; do
        if [ -f "$port_file" ]; then
            # Read port info JSON
            port_info=$(cat "$port_file" 2>/dev/null)
            if [ -n "$port_info" ]; then
                # Extract port using basic JSON parsing
                port=$(echo "$port_info" | grep -o '"port":[0-9]*' | cut -d: -f2)
                if echo "$port" | grep -q '^[0-9]\+$' && [ "$port" -gt 1024 ] && [ "$port" -lt 65536 ]; then
                    # Test if the port is actually active with health check
                    if curl -s --connect-timeout 1 --max-time 2 "http://127.0.0.1:$port/health" >/dev/null 2>&1; then
                        echo "$port"
                        return 0
                    fi
                fi
            fi
        fi
    done
    
    # Method 2: Check legacy claude-diff ports for compatibility
    for port_file in /tmp/claude-diff/nvim-port-*; do
        if [ -f "$port_file" ]; then
            port=$(cat "$port_file" 2>/dev/null)
            if echo "$port" | grep -q '^[0-9]\+$' && [ "$port" -gt 1024 ] && [ "$port" -lt 65536 ]; then
                if curl -s --connect-timeout 1 --max-time 2 "http://127.0.0.1:$port/health" >/dev/null 2>&1; then
                    echo "$port"
                    return 0
                fi
            fi
        fi
    done
    
    # Method 3: Scan common port ranges
    for port in $(seq 38600 38700) $(seq 38500 38600); do
        if curl -s --connect-timeout 0.5 --max-time 1 "http://127.0.0.1:$port/health" >/dev/null 2>&1; then
            echo "$port"
            return 0
        fi
    done
    
    # Method 4: Use netstat/ss to find nvim processes (if available)
    if command -v ss >/dev/null 2>&1; then
        nvim_ports=$(ss -tlnp 2>/dev/null | grep nvim | grep -oE ':[0-9]+' | cut -d: -f2 | head -1)
        if [ -n "$nvim_ports" ] && echo "$nvim_ports" | grep -q '^[0-9]\+$'; then
            if curl -s --connect-timeout 0.5 --max-time 1 "http://127.0.0.1:$nvim_ports/health" >/dev/null 2>&1; then
                echo "$nvim_ports"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Find active Neovim port
ACTIVE_PORT=$(find_nvim_port)

if [ -z "$ACTIVE_PORT" ]; then
    # No active Neovim instance found, exit silently
    exit 0
fi

# Get original content (from git if available)
ORIGINAL_CONTENT=$(get_original_content "$FILE_PATH")

# Read current file content (after changes)
NEW_CONTENT=$(cat "$FILE_PATH" 2>/dev/null)
if [ $? -ne 0 ]; then
    exit 0
fi

# Create JSON payload with both original and new content
# Use jq if available, otherwise use basic string manipulation
if command -v jq >/dev/null 2>&1; then
    JSON_PAYLOAD=$(jq -n \
        --arg filename "$FILE_PATH" \
        --arg new_content "$NEW_CONTENT" \
        --arg original_content "$ORIGINAL_CONTENT" \
        --arg action "$ACTION" \
        '{
            filename: $filename,
            new_content: $new_content,
            original_content: $original_content,
            action: $action
        }')
else
    # Fallback: Basic JSON creation (escape quotes and newlines)
    ESCAPED_NEW_CONTENT=$(echo "$NEW_CONTENT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    ESCAPED_ORIGINAL_CONTENT=$(echo "$ORIGINAL_CONTENT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    ESCAPED_FILENAME=$(echo "$FILE_PATH" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    
    JSON_PAYLOAD="{\"filename\":\"$ESCAPED_FILENAME\",\"new_content\":\"$ESCAPED_NEW_CONTENT\",\"original_content\":\"$ESCAPED_ORIGINAL_CONTENT\",\"action\":\"$ACTION\"}"
fi

# Send to Neovim with retry logic
for attempt in 1 2 3; do
    if curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD" \
        --connect-timeout 2 \
        --max-time 5 \
        "http://127.0.0.1:$ACTIVE_PORT/diff" \
        >/dev/null 2>&1; then
        exit 0
    fi
    
    # Brief delay before retry
    sleep 0.1
done

# All attempts failed, exit silently
exit 0
]]
end

-- Check if bridge script is installed and working
function M.check_bridge()
  local bridge_path = get_bridge_path()
  
  if vim.fn.filereadable(bridge_path) ~= 1 then
    vim.notify("OpenCode bridge script not found at: " .. bridge_path, vim.log.levels.WARN)
    return false
  end
  
  -- Check if it's executable
  if vim.fn.executable(bridge_path) ~= 1 then
    vim.notify("OpenCode bridge script is not executable: " .. bridge_path, vim.log.levels.WARN)
    return false
  end
  
  -- Check if it's in PATH
  if vim.fn.executable("nvim-opencode-bridge") ~= 1 then
    local bin_dir = vim.fn.fnamemodify(bridge_path, ":h")
    vim.notify("OpenCode bridge script installed but not in PATH. Add to your shell profile:\nexport PATH=\"$PATH:" .. bin_dir .. "\"", vim.log.levels.WARN)
    return false
  end
  
  vim.notify("✅ OpenCode bridge script is properly installed", vim.log.levels.INFO)
  return true
end

-- Install the bridge script
function M.install_bridge()
  local bridge_path = get_bridge_path()
  local bin_dir = vim.fn.fnamemodify(bridge_path, ":h")
  
  -- Create directory if it doesn't exist
  if vim.fn.isdirectory(bin_dir) ~= 1 then
    local ok = vim.fn.mkdir(bin_dir, "p")
    if ok ~= 1 then
      vim.notify("❌ Failed to create directory: " .. bin_dir, vim.log.levels.ERROR)
      return false
    end
  end
  
  -- Write the bridge script
  local script_content = get_bridge_script_content()
  local lines = vim.split(script_content, "\n")
  local write_ok = vim.fn.writefile(lines, bridge_path)
  if write_ok ~= 0 then
    vim.notify("❌ Failed to write bridge script to: " .. bridge_path, vim.log.levels.ERROR)
    return false
  end
  
  -- Make it executable
  local chmod_result = vim.fn.system("chmod +x " .. vim.fn.shellescape(bridge_path))
  if vim.v.shell_error ~= 0 then
    vim.notify("❌ Failed to make bridge script executable: " .. chmod_result, vim.log.levels.ERROR)
    return false
  end
  
  -- Check if the directory is in PATH
  local path_env = os.getenv("PATH") or ""
  if not path_env:find(bin_dir, 1, true) then
    vim.notify("⚠️  Bridge script installed to: " .. bridge_path, vim.log.levels.WARN)
    vim.notify("Add to your shell profile for global access:\nexport PATH=\"$PATH:" .. bin_dir .. "\"", vim.log.levels.INFO)
  else
    vim.notify("✅ OpenCode bridge script installed successfully!", vim.log.levels.INFO)
  end
  
  return true
end

-- Uninstall the bridge script
function M.uninstall_bridge()
  local bridge_path = get_bridge_path()
  
  if vim.fn.filereadable(bridge_path) ~= 1 then
    vim.notify("Bridge script not found, nothing to uninstall", vim.log.levels.INFO)
    return true
  end
  
  local delete_ok = vim.fn.delete(bridge_path)
  if delete_ok ~= 0 then
    vim.notify("❌ Failed to delete bridge script: " .. bridge_path, vim.log.levels.ERROR)
    return false
  end
  
  vim.notify("✅ OpenCode bridge script uninstalled successfully", vim.log.levels.INFO)
  return true
end

-- Update the bridge script (reinstall with latest version)
function M.update_bridge()
  vim.notify("Updating OpenCode bridge script...", vim.log.levels.INFO)
  
  -- Uninstall old version
  M.uninstall_bridge()
  
  -- Install new version
  return M.install_bridge()
end

-- Show bridge script information
function M.bridge_info()
  local bridge_path = get_bridge_path()
  
  print("🚀 OpenCode Bridge Script Information:")
  print("Path: " .. bridge_path)
  print("Exists: " .. (vim.fn.filereadable(bridge_path) == 1 and "✅ Yes" or "❌ No"))
  print("Executable: " .. (vim.fn.executable(bridge_path) == 1 and "✅ Yes" or "❌ No"))
  print("In PATH: " .. (vim.fn.executable("nvim-opencode-bridge") == 1 and "✅ Yes" or "❌ No"))
  
  -- Show PATH directories
  local path_env = os.getenv("PATH") or ""
  local path_dirs = vim.split(path_env, ":")
  local bin_dir = vim.fn.fnamemodify(bridge_path, ":h")
  local in_path = false
  
  for _, dir in ipairs(path_dirs) do
    if dir == bin_dir then
      in_path = true
      break
    end
  end
  
  if not in_path then
    print("\n⚠️  To make the bridge globally accessible, add this to your shell profile:")
    print("export PATH=\"$PATH:" .. bin_dir .. "\"")
  end
  
  -- Check dependencies
  print("\nDependencies:")
  print("curl: " .. (vim.fn.executable("curl") == 1 and "✅ Available" or "❌ Missing"))
  print("jq: " .. (vim.fn.executable("jq") == 1 and "✅ Available (recommended)" or "⚠️  Missing (will use fallback)"))
end

return M