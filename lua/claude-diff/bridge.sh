#!/bin/bash
# Claude Code Bridge Script
# This script is called by Claude Code PostToolUse hooks
# It sends diff information to the Neovim plugin via HTTP

# Configuration
NVIM_SERVER_URL="http://127.0.0.1:38547"
TEMP_DIR="/tmp/claude-diff"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Read hook data from stdin
hook_data=$(cat)

# Extract file path from hook data
file_path=$(echo "$hook_data" | jq -r '.tool_input.file_path // empty')

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

# Extract original content from hook data if available
original_from_hook=$(echo "$hook_data" | jq -r '.tool_input.old_string // empty')

if [ -n "$original_from_hook" ] && [ "$original_from_hook" != "null" ]; then
    # Use original content from hook data
    original_content="$original_from_hook"
    echo "Using original content from hook data" >&2
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