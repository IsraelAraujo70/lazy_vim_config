-- Test script for the improved diff algorithm

local M = require('claude-diff.init')

-- Test data: small change that previously showed entire file as changed
local original_content = [[function hello()
  print("Hello")
  print("World")
  
  local x = 1
  local y = 2
  local z = x + y
  
  return z
end

function goodbye()
  print("Goodbye")
  return true
end]]

local new_content = [[function hello()
  print("Hello")
  print("World")
  
  local x = 1
  local y = 3  -- Changed from 2 to 3
  local z = x + y
  
  return z
end

function goodbye()
  print("Goodbye")
  return true
end]]

-- Test the diff algorithm
local function test_diff()
  print("🧪 Testing improved diff algorithm...")
  
  local original_lines = vim.split(original_content, "\n")
  local new_lines = vim.split(new_content, "\n")
  
  -- Set up minimal config for testing
  if not require('claude-diff.init').state then
    require('claude-diff.init').state = {
      config = {
        diff_options = {
          context = 3,
          ignore_whitespace = false,
          ignore_blank_lines = false,
        }
      }
    }
  end
  
  local blocks = require('claude-diff.init').find_change_blocks(original_lines, new_lines)
  
  print("📊 Diff Results:")
  print("Number of change blocks found: " .. #blocks)
  
  for i, block in ipairs(blocks) do
    print("\n📍 Block " .. i .. ":")
    
    if block.context_before and #block.context_before > 0 then
      print("  Context before:")
      for _, ctx in ipairs(block.context_before) do
        print("    " .. ctx.line_num .. ": " .. ctx.content)
      end
    end
    
    if #block.removed > 0 then
      print("  Removed lines:")
      for _, rem in ipairs(block.removed) do
        print("    -" .. rem.line_num .. ": " .. rem.content)
      end
    end
    
    if #block.added > 0 then
      print("  Added lines:")
      for _, add in ipairs(block.added) do
        print("    +" .. add.line_num .. ": " .. add.content)
      end
    end
    
    if block.context_after and #block.context_after > 0 then
      print("  Context after:")
      for _, ctx in ipairs(block.context_after) do
        print("    " .. ctx.line_num .. ": " .. ctx.content)
      end
    end
  end
  
  if #blocks == 0 then
    print("❌ No changes detected - algorithm may have issues")
  elseif #blocks == 1 and #blocks[1].removed <= 2 and #blocks[1].added <= 2 then
    print("✅ SUCCESS: Only minimal changes detected (as expected)")
  else
    print("⚠️  WARNING: More changes detected than expected")
  end
end

-- Run test
test_diff()

return M