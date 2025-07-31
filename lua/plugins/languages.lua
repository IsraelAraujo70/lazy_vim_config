return {
  -- TypeScript/JavaScript support
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- JSON support
  { import = "lazyvim.plugins.extras.lang.json" },

  -- Tailwind CSS support (removido temporariamente - extras mudaram)
  -- { import = "lazyvim.plugins.extras.lsp.tailwindcss" },

  -- PHP Language Server configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          enabled = true,
        },
        intelephense = {
          enabled = true,
          init_options = {
            globalStoragePath = os.getenv("HOME") .. "/.local/share/intelephense",
          },
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
                associations = { "*.php", "*.phtml" },
                exclude = {
                  "**/node_modules/**",
                  "**/vendor/**/Tests/**",
                  "**/vendor/**/tests/**",
                  "**/storage/framework/views/*.php",
                },
              },
              completion = {
                insertUseDeclaration = true,
                fullyQualifyGlobalConstantsAndFunctions = false,
                triggerParameterHints = true,
                maxItems = 100,
              },
              format = {
                enable = true,
                braces = "psr12",
              },
              environment = {
                documentRoot = vim.fn.getcwd(),
                includePaths = { vim.fn.getcwd() .. "/vendor" },
              },
            },
          },
        },
        -- HTML/CSS for PHP templates
        html = {},
        cssls = {},
        emmet_ls = {
          filetypes = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "php" },
        },
      },
    },
  },

  -- Tree-sitter parsers for the languages
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "tsx",
        "javascript",
        "jsdoc",
        "php",
        "phpdoc",
        "html",
        "css",
        "scss",
        "json",
        "yaml",
        "sql",
      })
    end,
  },

  -- Auto-pairs and surround
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- Comment handling
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  -- Context-aware commenting for JSX/TSX
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },

  -- Better syntax highlighting for PHP
  {
    "StanAngeloff/php.vim",
    ft = "php",
    config = function()
      vim.g.php_syntax_extensions_enabled = {
        "bcmath",
        "bz2",
        "core",
        "curl",
        "date",
        "dom",
        "ereg",
        "gd",
        "gettext",
        "hash",
        "iconv",
        "json",
        "libxml",
        "mbstring",
        "mcrypt",
        "mhash",
        "mysql",
        "mysqli",
        "openssl",
        "pcre",
        "pdo",
        "phar",
        "reflection",
        "session",
        "simplexml",
        "soap",
        "sockets",
        "spl",
        "tokenizer",
        "wddx",
        "xml",
        "xmlreader",
        "xmlwriter",
        "zip",
        "zlib",
      }
      vim.g.php_html_load = 0
      vim.g.php_html_in_heredoc = 0
      vim.g.php_html_in_nowdoc = 0
      vim.g.php_sql_query = 0
      vim.g.php_sql_heredoc = 0
      vim.g.php_sql_nowdoc = 0
    end,
  },

  -- Laravel Blade syntax
  {
    "jwalton512/vim-blade",
    ft = "blade",
  },
  -- Emmet for HTML/CSS
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "php", "blade" },
    config = function()
      vim.g.user_emmet_leader_key = "<C-z>"
      vim.g.user_emmet_settings = {
        typescript = { extends = "jsx" },
        javascript = { extends = "jsx" },
      }
    end,
  },
}

