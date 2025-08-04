-- OpenCode Diff Plugin Configuration
-- Integrates OpenCode with Neovim for real-time diff visualization

return {
  -- OpenCode Diff Integration
  {
    name = "opencode-diff",
    dir = vim.fn.stdpath("config") .. "/lua/opencode-diff",
    config = function()
      require("opencode-diff").setup({
        -- Server configuration
        server_port_base = 38600,  -- Base port for opencode (different from claude)
        auto_setup_hooks = true,   -- Automatically configure opencode.json
        
        -- Keymaps
        keymaps = {
          accept = "<leader>oa",      -- Accept OpenCode changes
          reject = "<leader>or",      -- Reject OpenCode changes  
          show_diff = "<leader>od",   -- Show current diff
        },
        
        -- Diff visualization options
        diff_options = {
          algorithm = "github",         -- Diff algorithm: github, myers, patience, histogram
          context = 3,                  -- Lines of context around changes
          full_context = true,          -- Show full context like GitHub
          ignore_whitespace = false,    -- Ignore whitespace differences
          ignore_blank_lines = false,   -- Ignore blank line differences
          word_diff = true,             -- Enable word-level diff highlighting
          minimal_diff = false,         -- Show only changed blocks
        },
      })
    end,
    
    -- Load on startup to start the HTTP server
    lazy = false,
    priority = 1000,
  },
}