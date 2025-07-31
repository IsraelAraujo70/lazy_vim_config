-- Claude Code Integration Plugin for Neovim  
-- Auto diff viewer when Claude Code is running

return {
  {
    -- Custom Claude Code plugin
    dir = vim.fn.stdpath("config") .. "/lua/claude-code-nvim",
    name = "claude-code-nvim",
    lazy = false,
    config = function()
      require("claude-code-nvim").setup({
        check_interval = 2000, -- Check for Claude Code every 2 seconds
        auto_diff = true,
        keymaps = {
          show_diff = "<leader>cd",
        },
      })
    end,
    keys = {
      { "<leader>cd", "<cmd>ClaudeShowDiff<cr>", desc = "📊 Show Claude Diff" },
      { "<leader>c?", "<cmd>ClaudeStatus<cr>", desc = "❓ Check Claude Status" },
    },
  }
}