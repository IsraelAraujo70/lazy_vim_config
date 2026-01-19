-- OpenCode.nvim - Integracao com OpenCode AI via tmux
return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    keys = {
      -- Leader keymaps (aparecem no which-key)
      { "<leader>oo", function() require("opencode").toggle() end, desc = "Toggle OpenCode" },
      { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask OpenCode", mode = { "n", "x" } },
      { "<leader>os", function() require("opencode").select() end, desc = "Select action", mode = { "n", "x" } },
      { "<leader>ol", function() require("opencode").operator("@this ") end, desc = "Add line to OpenCode", expr = true },
      { "<leader>oA", function() require("opencode").prompt("lumen_annotations") end, desc = "Explicar anotacoes Lumen" },
      -- Ctrl+. para toggle rapido
      { "<C-.>", function() require("opencode").toggle() end, desc = "Toggle OpenCode", mode = { "n", "t" } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        provider = {
          enabled = "tmux",
          tmux = {},
        },
        contexts = {
          ["@lumen_annotations"] = function()
            local path = vim.fn.input("Arquivo de anotacoes Lumen: ", "", "file")
            if path == "" then
              return nil
            end
            local ok, lines = pcall(vim.fn.readfile, path)
            if not ok then
              vim.notify("Nao foi possivel ler: " .. path, vim.log.levels.ERROR)
              return nil
            end
            return table.concat(lines, "\n")
          end,
        },
        prompts = {
          lumen_annotations = {
            prompt = "Explique estas anotacoes de code review do Lumen:\n@lumen_annotations",
            submit = true,
          },
        },
      }

      -- Necessario para reload automatico de arquivos editados pelo opencode
      vim.o.autoread = true

      -- Operator keymaps
      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Add range to OpenCode", expr = true })

      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Add line to OpenCode", expr = true })

      -- Scroll OpenCode
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll OpenCode up" })

      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll OpenCode down" })
    end,
  },

  -- Which-key group para OpenCode
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "+OpenCode", icon = "" },
      },
    },
  },
}
