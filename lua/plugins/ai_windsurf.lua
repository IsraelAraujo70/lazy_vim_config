-- Windsurf.vim - Free, ultrafast Copilot alternative
return {
  {
    "Exafunction/windsurf.vim",
    event = "InsertEnter", -- Carrega só quando entra em insert mode (mais rápido)
    config = function()
      -- === PERFORMANCE ===
      vim.g.codeium_idle_delay = 75 -- Delay menor = sugestões mais rápidas (default: 75)
      vim.g.codeium_render = true -- Renderiza sugestões inline
      vim.g.codeium_tab_fallback = "\t" -- Fallback quando não há sugestão

      -- === CONTEXTO INTELIGENTE (Python Serverless + TypeScript) ===
      -- Hints para detectar root do projeto (ordem importa - mais específico primeiro)
      vim.g.codeium_workspace_root_hints = {
        -- Serverless / AWS
        "serverless.yml",
        "serverless.ts",
        "template.yaml", -- SAM
        "samconfig.toml",
        "cdk.json", -- AWS CDK

        -- Python
        "pyproject.toml",
        "requirements.txt",
        "setup.py",
        "Pipfile",
        "poetry.lock",
        ".python-version",

        -- TypeScript / JavaScript
        "package.json",
        "tsconfig.json",
        "package-lock.json",
        "yarn.lock",
        "pnpm-lock.yaml",
        "nx.json", -- Monorepo Nx
        "turbo.json", -- Turborepo

        -- Geral
        ".git",
        "Makefile",
        ".nvim",
      }

      -- Desabilita bindings default para customizar
      vim.g.codeium_disable_bindings = 1

      -- === KEYMAPS ===
      vim.keymap.set("i", "<Tab>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })

      vim.keymap.set("i", "<C-Right>", function()
        return vim.fn["codeium#AcceptNextWord"]()
      end, { expr = true, silent = true })

      vim.keymap.set("i", "<C-End>", function()
        return vim.fn["codeium#AcceptNextLine"]()
      end, { expr = true, silent = true })

      vim.keymap.set("i", "<M-]>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true, silent = true })

      vim.keymap.set("i", "<M-[>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true, silent = true })

      vim.keymap.set("i", "<C-]>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true })

      -- Trigger manual com Alt+\
      vim.keymap.set("i", "<M-Bslash>", function()
        return vim.fn["codeium#Complete"]()
      end, { expr = true, silent = true })

      -- === FILETYPES ===
      -- Habilitado em todos por default, lista exceções aqui
      vim.g.codeium_filetypes = {
        TelescopePrompt = false,
        DressingInput = false,
        ["neo-tree-popup"] = false,
      }
    end,
  },
}
