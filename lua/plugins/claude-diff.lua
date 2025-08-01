-- Claude Code Diff Integration Plugin for Neovim
-- Integrates with Claude Code via PostToolUse hooks to show diffs before applying changes

return {
  {
    -- New Claude Code integration via hooks
    dir = vim.fn.stdpath("config") .. "/lua/claude-diff",
    name = "claude-diff.nvim",
    lazy = false,
    config = function()
      require("claude-diff").setup({
        server_port = 38547,
        auto_setup_hooks = true,
        keymaps = {
          accept = "<leader>ca",
          reject = "<leader>cr",
          show_diff = "<leader>cd",
        },
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "🤖 Run Claude Code" },
      { "<leader>cd", "<cmd>ClaudeDiff<cr>", desc = "📊 Show Claude Diff" },
      { "<leader>ca", "<cmd>ClaudeAccept<cr>", desc = "✅ Accept Claude Changes" },
      { "<leader>cr", "<cmd>ClaudeReject<cr>", desc = "❌ Reject Claude Changes" },
      { "<leader>c?", "<cmd>ClaudeStatus<cr>", desc = "❓ Claude Integration Status" },
    },
  }
}