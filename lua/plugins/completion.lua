return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = (function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return
      end
      return "make install_jsregexp"
    end)(),
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      
      -- Custom snippets
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local sn = ls.snippet_node
      
      -- JavaScript/TypeScript snippets
      ls.add_snippets("javascript", {
        s("cl", {
          t("console.log("), i(1), t(");")
        }),
        s("fn", {
          t("function "), i(1, "name"), t("("), i(2), t(") {"),
          t({"", "  "}), i(0),
          t({"", "}"})
        }),
        s("af", {
          t("const "), i(1, "name"), t(" = ("), i(2), t(") => {"),
          t({"", "  "}), i(0),
          t({"", "}"})
        }),
        s("imp", {
          t("import "), i(1), t(" from '"), i(2), t("';")
        }),
        s("exp", {
          t("export "), c(1, {
            sn(nil, {t("default "), i(1)}),
            sn(nil, {t("{ "), i(1), t(" }")}),
            sn(nil, {t("const "), i(1), t(" = "), i(2), t(";")}),
          })
        }),
        s("try", {
          t({"try {", "  "}), i(1),
          t({"", "} catch ("}), i(2, "error"), t({") {", "  "}), i(0),
          t({"", "}"})
        }),
        s("if", {
          t("if ("), i(1), t({") {", "  "}), i(0),
          t({"", "}"})
        }),
        s("ife", {
          t("if ("), i(1), t({") {", "  "}), i(2),
          t({"", "} else {", "  "}), i(0),
          t({"", "}"})
        }),
        s("for", {
          t("for ("), c(1, {
            sn(nil, {t("let "), i(1, "i"), t(" = 0; "), i(2, "i"), t(" < "), i(3, "length"), t("; "), i(4, "i"), t("++")}),
            sn(nil, {t("const "), i(1, "item"), t(" of "), i(2, "array")}),
            sn(nil, {t("const "), i(1, "key"), t(" in "), i(2, "object")}),
          }), 
          t({") {", "  "}), i(0),
          t({"", "}"})
        }),
      })
      
      -- TypeScript specific snippets
      ls.add_snippets("typescript", {
        s("int", {
          t("interface "), i(1, "Name"), t({" {", "  "}), i(0),
          t({"", "}"})
        }),
        s("type", {
          t("type "), i(1, "Name"), t(" = "), i(0), t(";")
        }),
        s("enum", {
          t("enum "), i(1, "Name"), t({" {", "  "}), i(0),
          t({"", "}"})
        }),
        s("class", {
          t("class "), i(1, "Name"), t({" {", "  "}), i(0),
          t({"", "}"})
        }),
      })
      
      -- PHP snippets
      ls.add_snippets("php", {
        s("php", {
          t("<?php"), t({"", ""}), i(0)
        }),
        s("echo", {
          t("echo "), i(1), t(";")
        }),
        s("var", {
          t("var_dump("), i(1), t(");")
        }),
        s("fn", {
          c(1, {
            sn(nil, {t("function "), i(1, "name"), t("("), i(2), t({") {", "    "}), i(0), t({"", "}"})}),
            sn(nil, {t("public function "), i(1, "name"), t("("), i(2), t({") {", "    "}), i(0), t({"", "}"})}),
            sn(nil, {t("private function "), i(1, "name"), t("("), i(2), t({") {", "    "}), i(0), t({"", "}"})}),
            sn(nil, {t("protected function "), i(1, "name"), t("("), i(2), t({") {", "    "}), i(0), t({"", "}"})}),
          })
        }),
        s("class", {
          t("class "), i(1, "Name"), t({" {", "    "}), i(0),
          t({"", "}"})
        }),
        s("if", {
          t("if ("), i(1), t({") {", "    "}), i(0),
          t({"", "}"})
        }),
        s("foreach", {
          t("foreach ("), i(1, "$array"), t(" as "), c(2, {
            sn(nil, {t("$"), i(1, "item")}),
            sn(nil, {t("$"), i(1, "key"), t(" => $"), i(2, "value")}),
          }),
          t({") {", "    "}), i(0),
          t({"", "}"})
        }),
        s("try", {
          t({"try {", "    "}), i(1),
          t({"", "} catch ("}), i(2, "Exception"), t(" $"), i(3, "e"), t({") {", "    "}), i(0),
          t({"", "}"})
        }),
        s("namespace", {
          t("namespace "), i(1), t(";")
        }),
        s("use", {
          t("use "), i(1), t(";")
        }),
      })
      
      -- Copy JavaScript snippets to TypeScript
      for _, snippet in ipairs(ls.get_snippets("javascript")) do
        ls.add_snippets("typescript", {snippet})
      end
      
      -- React/JSX snippets for both JS and TS
      local react_snippets = {
        s("rfc", {
          t("import React from 'react';"), t({"", "", ""}),
          t("const "), i(1, "ComponentName"), t(" = () => {"),
          t({"", "  return (", "    "}), i(0),
          t({"", "  );", "};", "", "export default "}), f(function(args) return args[1][1] end, {1}), t(";")
        }),
        s("rcc", {
          t("import React, { Component } from 'react';"), t({"", "", ""}),
          t("class "), i(1, "ComponentName"), t(" extends Component {"),
          t({"", "  render() {", "    return (", "      "}), i(0),
          t({"", "    );", "  }", "}", "", "export default "}), f(function(args) return args[1][1] end, {1}), t(";")
        }),
        s("useState", {
          t("const ["), i(1, "state"), t(", set"), f(function(args) return args[1][1]:gsub("^%l", string.upper) end, {1}), t("] = useState("), i(2), t(");")
        }),
        s("useEffect", {
          t("useEffect(() => {"), t({"", "  "}), i(1),
          t({"", "}, ["}), i(2), t("]);")
        }),
      }
      
      ls.add_snippets("javascriptreact", react_snippets)
      ls.add_snippets("typescriptreact", react_snippets)
    end,
  },

  -- Enhanced completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "onsails/lspkind.nvim",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      
      opts.snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      }
      
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "nvim_lsp_signature_help", priority = 700 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
        { name = "nvim_lua", priority = 200 },
      })
      
      opts.formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
          before = function(entry, vim_item)
            -- Source
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
              nvim_lua = "[Lua]",
            })[entry.source.name]
            return vim_item
          end,
        }),
      }
      
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
      
      opts.experimental = {
        ghost_text = true,
      }
      
      return opts
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)
      
      -- Set configuration for specific filetype.
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "buffer" },
        })
      })
      
      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })
      
      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end,
  },

  -- AI-powered completion (Codeium) - volta para versão VimScript que funciona
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Disable default <Tab> mapping to avoid conflicts
      vim.g.codeium_disable_bindings = 1
      
      -- 🤖 CODEIUM - IGUAL VSCODE COPILOT
      
      -- Ctrl+G = Aceitar sugestão (como você pediu!)
      vim.keymap.set('i', '<C-g>', function()
        return vim.fn['codeium#Accept']()
      end, { expr = true, silent = true, desc = "Accept Codeium" })
      
      -- Tab também aceita (padrão universal)
      vim.keymap.set('i', '<Tab>', function()
        if vim.fn['codeium#GetStatusString']() ~= '' then
          return vim.fn['codeium#Accept']()
        else
          return '<Tab>'
        end
      end, { expr = true, silent = true, desc = "Accept Codeium or Tab" })
      
      -- Ctrl+] = Próxima sugestão (igual VSCode)
      vim.keymap.set('i', '<C-]>', function()
        return vim.fn['codeium#CycleCompletions'](1)
      end, { expr = true, silent = true, desc = "Next Codeium suggestion" })
      
      -- Ctrl+[ = Sugestão anterior (igual VSCode)
      vim.keymap.set('i', '<C-[>', function()
        return vim.fn['codeium#CycleCompletions'](-1)
      end, { expr = true, silent = true, desc = "Previous Codeium suggestion" })
      
      -- Escape = Rejeitar sugestão (igual VSCode)
      vim.keymap.set('i', '<Esc>', function()
        vim.fn['codeium#Clear']()
        return '<Esc>'
      end, { expr = true, silent = true, desc = "Reject Codeium and exit" })
      
      -- Management commands
      vim.keymap.set('n', '<leader>cs', '<cmd>Codeium Auth<cr>', { desc = "Codeium: Authenticate" })
      vim.keymap.set('n', '<leader>cd', '<cmd>Codeium Disable<cr>', { desc = "Codeium: Disable" })
      vim.keymap.set('n', '<leader>ce', '<cmd>Codeium Enable<cr>', { desc = "Codeium: Enable" })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = {'string'},
        javascript = {'template_string'},
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey='Comment'
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      
      -- Integration with nvim-cmp (only if cmp is available)
      local ok_cmp, cmp = pcall(require, 'cmp')
      if ok_cmp then
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on(
          'confirm_done',
          cmp_autopairs.on_confirm_done()
        )
      end
    end,
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },
      })
    end
  },
}