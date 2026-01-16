-- Diffview.nvim - Visualização de diffs estilo GitHub
return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View (Open)" },
      { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diff vs Last Commit" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- Desabilita algumas coisas no buffer de diff para performance
          vim.opt_local.wrap = false
          vim.opt_local.list = false
        end,
      },
    },
  },
}
