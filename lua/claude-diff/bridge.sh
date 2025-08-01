#!/bin/bash
# Claude Code Bridge Script
# This script is called by Claude Code PostToolUse hooks
# It sends diff information to the Neovim plugin via HTTP

# Configuration
TEMP_DIR="/tmp/claude-diff"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Read hook data from stdin
hook_data=$(cat)

# Extract file path from hook data
file_path=$(echo "$hook_data" | jq -r '.tool_input.file_path // empty')

# Find Neovim server port for current working directory
NVIM_PORT=""
CURRENT_DIR=$(pwd)

# If we have a file path from the hook, use its directory instead of pwd
if [ -n "$file_path" ] && [ -f "$file_path" ]; then
    FILE_DIR=$(dirname "$file_path")
    echo "DEBUG: Using file directory instead of pwd: $FILE_DIR" >&2
    CURRENT_DIR="$FILE_DIR"
fi

echo "DEBUG: Current directory: $CURRENT_DIR" >&2
echo "DEBUG: Looking for Neovim instances..." >&2

# Also write to a debug file for troubleshooting
echo "$(date): DEBUG: Current directory: $CURRENT_DIR" >> /tmp/claude-diff/debug.log
echo "$(date): DEBUG: Looking for Neovim instances..." >> /tmp/claude-diff/debug.log

# Store info about all instances for debugging
debug_info=""

# First try to find Neovim instance in current directory
for port_file in /tmp/claude-diff/nvim-port-*; do
    if [ -f "$port_file" ]; then
        # Extract PID from filename
        pid=$(basename "$port_file" | cut -d'-' -f3)
        
        # Check if process is still running
        if kill -0 "$pid" 2>/dev/null; then
            # Try multiple methods to get working directory
            nvim_cwd=""
            
            # Method 1: pwdx
            if command -v pwdx >/dev/null 2>&1; then
                nvim_cwd=$(pwdx "$pid" 2>/dev/null | cut -d':' -f2 | xargs)
            fi
            
            # Method 2: /proc filesystem (Linux)
            if [ -z "$nvim_cwd" ] && [ -r "/proc/$pid/cwd" ]; then
                nvim_cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null)
            fi
            
            # Method 3: lsof (fallback)
            if [ -z "$nvim_cwd" ] && command -v lsof >/dev/null 2>&1; then
                nvim_cwd=$(lsof -p "$pid" 2>/dev/null | grep -E '\s+cwd\s+' | awk '{print $NF}' | head -1)
            fi
            
            debug_info="$debug_info\nPID $pid: $nvim_cwd"
            
            # Log to debug file
            echo "$(date): Found Neovim PID $pid at: $nvim_cwd" >> /tmp/claude-diff/debug.log
            
            # Check if this Neovim is in current directory or parent
            if [ -n "$nvim_cwd" ] && ([ "$nvim_cwd" = "$CURRENT_DIR" ] || [[ "$CURRENT_DIR" == "$nvim_cwd"/* ]]); then
                NVIM_PORT=$(cat "$port_file")
                
                # Test if the port actually responds
                if curl -s --max-time 1 -X POST "http://127.0.0.1:$NVIM_PORT" >/dev/null 2>&1; then
                    echo "DEBUG: Found Neovim in matching directory!" >&2
                    echo "DEBUG: Neovim CWD: $nvim_cwd" >&2
                    echo "DEBUG: Current DIR: $CURRENT_DIR" >&2
                    echo "DEBUG: Using port: $NVIM_PORT" >&2
                    
                    # Log success to debug file
                    echo "$(date): MATCH! Using Neovim PID $pid, port $NVIM_PORT" >> /tmp/claude-diff/debug.log
                    break
                else
                    echo "DEBUG: Port $NVIM_PORT not responding, cleaning up..." >&2
                    rm -f "$port_file"
                    echo "$(date): Port $NVIM_PORT not responding, cleaned up" >> /tmp/claude-diff/debug.log
                fi
            else
                # Log no match to debug file
                echo "$(date): No match - Current: $CURRENT_DIR, Neovim: $nvim_cwd" >> /tmp/claude-diff/debug.log
            fi
        else
            # Clean up stale port file
            rm -f "$port_file"
        fi
    fi
done

# Debug: show all found instances
if [ -n "$debug_info" ]; then
    echo "DEBUG: Found Neovim instances:$debug_info" >&2
fi

# If no match found in current directory, try any active Neovim as fallback
if [ -z "$NVIM_PORT" ]; then
    echo "No Neovim found in current directory, trying any active instance..." >&2
    for port_file in /tmp/claude-diff/nvim-port-*; do
        if [ -f "$port_file" ]; then
            pid=$(basename "$port_file" | cut -d'-' -f3)
            if kill -0 "$pid" 2>/dev/null; then
                NVIM_PORT=$(cat "$port_file")
                echo "Using fallback Neovim instance" >&2
                break
            fi
        fi
    done
fi

if [ -z "$NVIM_PORT" ]; then
    echo "No active Neovim instance found" >&2
    exit 1
fi

NVIM_SERVER_URL="http://127.0.0.1:$NVIM_PORT"

if [ -z "$file_path" ] || [ "$file_path" = "null" ]; then
    echo "No file path found in hook data" >&2
    exit 1
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
    echo "File does not exist: $file_path" >&2
    exit 1
fi

# Create backup of original content (before Claude's changes)
backup_file="$TEMP_DIR/$(basename "$file_path").backup"

# For PostToolUse:Edit hooks, we can use the complete original file content
original_file_content=$(echo "$hook_data" | jq -r '.tool_response.originalFile // empty')

if [ -n "$original_file_content" ] && [ "$original_file_content" != "null" ]; then
    # Use complete original file content from hook data
    original_content="$original_file_content"
    echo "Using complete original file from hook data" >&2
elif [ -f "$backup_file" ]; then
    # Use existing backup
    original_content=$(cat "$backup_file")
    echo "Using existing backup file" >&2
else
    # First time - assume file was empty or create minimal diff
    original_content=""
    echo "No backup found, assuming new file" >&2
fi

# Get current (new) content
new_content=$(cat "$file_path")

# Only proceed if there are actual changes
if [ "$original_content" = "$new_content" ]; then
    echo "No changes detected in $file_path" >&2
    exit 0
fi

# Create JSON payload for Neovim
json_payload=$(jq -n \
    --arg filename "$file_path" \
    --arg original "$original_content" \
    --arg new "$new_content" \
    --arg timestamp "$(date -Iseconds)" \
    '{
        filename: $filename,
        original_content: $original,
        new_content: $new,
        timestamp: $timestamp,
        tool_name: "claude-code"
    }')

# Send to Neovim via HTTP POST
response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    --max-time 5 \
    "$NVIM_SERVER_URL" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Diff sent to Neovim successfully"
    # Update backup with new content for next time
    echo "$new_content" > "$backup_file"
else
    echo "Failed to send diff to Neovim" >&2
    # Still update backup to avoid repeated notifications
    echo "$new_content" > "$backup_file"
    exit 1
fi