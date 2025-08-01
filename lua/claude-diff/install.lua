-- Installation helper for Claude Diff bridge script

local M = {}

local function get_bridge_script_path()
  return vim.fn.stdpath("config") .. "/lua/claude-diff/bridge.sh"
end

local function get_install_path()
  local home = os.getenv("HOME")
  local local_bin = home .. "/.local/bin"
  
  -- Create ~/.local/bin if it doesn't exist
  vim.fn.mkdir(local_bin, "p")
  
  return local_bin .. "/nvim-claude-bridge"
end

-- Install the bridge script to PATH
function M.install_bridge()
  local source_path = get_bridge_script_path()
  local install_path = get_install_path()
  
  -- Check if source exists
  if vim.fn.filereadable(source_path) == 0 then
    vim.notify("Bridge script not found: " .. source_path, vim.log.levels.ERROR)
    return false
  end
  
  -- Copy and make executable
  local copy_cmd = string.format("cp '%s' '%s'", source_path, install_path)
  local chmod_cmd = string.format("chmod +x '%s'", install_path)
  
  local copy_result = os.execute(copy_cmd)
  local chmod_result = os.execute(chmod_cmd)
  
  if copy_result == 0 and chmod_result == 0 then
    vim.notify("✅ Claude bridge installed to: " .. install_path, vim.log.levels.INFO)
    
    -- Check if ~/.local/bin is in PATH
    local path = os.getenv("PATH") or ""
    local local_bin = os.getenv("HOME") .. "/.local/bin"
    
    if not path:match(vim.pesc(local_bin)) then
      vim.notify("⚠️  Please add ~/.local/bin to your PATH:\n" ..
                "echo 'export PATH=\"$HOME/.local/bin:$PATH\"' >> ~/.bashrc", 
                vim.log.levels.WARN)
    end
    
    return true
  else
    vim.notify("❌ Failed to install bridge script", vim.log.levels.ERROR)
    return false
  end
end

-- Check if bridge is installed and accessible
function M.check_bridge()
  local install_path = get_install_path()
  
  if vim.fn.executable("nvim-claude-bridge") == 1 then
    vim.notify("✅ Bridge script is installed and accessible", vim.log.levels.INFO)
    return true
  elseif vim.fn.filereadable(install_path) == 1 then
    vim.notify("⚠️  Bridge script exists but not in PATH: " .. install_path, vim.log.levels.WARN)
    return false
  else
    vim.notify("❌ Bridge script not installed", vim.log.levels.ERROR)
    return false
  end
end

-- Uninstall the bridge script
function M.uninstall_bridge() 
  local install_path = get_install_path()
  
  if vim.fn.filereadable(install_path) == 1 then
    local rm_cmd = string.format("rm -f '%s'", install_path)
    local result = os.execute(rm_cmd)
    
    if result == 0 then
      vim.notify("✅ Bridge script uninstalled", vim.log.levels.INFO)
      return true
    else
      vim.notify("❌ Failed to uninstall bridge script", vim.log.levels.ERROR)
      return false
    end
  else
    vim.notify("Bridge script not found at: " .. install_path, vim.log.levels.WARN)
    return false
  end
end

return M