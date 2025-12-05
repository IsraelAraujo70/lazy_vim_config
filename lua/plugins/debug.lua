return {
  -- Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Debug: Set Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Debug: Evaluate", mode = {"n", "v"} },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      -- Setup DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      -- Virtual text setup
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Breakpoint icons
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '📍', texthl = 'DapLogPoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

      -- Node.js/JavaScript debugging
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = {vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"},
      }

      dap.configurations.javascript = {
        {
          name = 'Launch',
          type = 'node2',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          name = 'Attach to process',
          type = 'node2',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        },
      }

      dap.configurations.typescript = dap.configurations.javascript

      -- PHP debugging
      dap.adapters.php = {
        type = 'executable',
        command = 'node',
        args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" }
      }

      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug',
          port = 9003,
          log = false,
          pathMappings = {
            ["/var/www/html"] = "${workspaceFolder}",
          },
        },
      }
    end,
  },

  -- Testing framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adapters
      "nvim-neotest/neotest-jest",
      "olimorris/neotest-phpunit",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Test" },
      { "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run Test File" },
      { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run All Tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop Test" },
      { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug Test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
              require("neotest-phpunit")({
            phpunit_cmd = function()
              return "vendor/bin/phpunit"
            end,
          }),
        },
        discovery = {
          enabled = false,
        },
        running = {
          concurrent = true,
        },
        summary = {
          enabled = true,
          animated = true,
          follow = true,
          expandErrors = true,
        },
        output = {
          enabled = true,
          open_on_run = "short",
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = false,
        },
        icons = {
          child_indent = "│",
          child_prefix = "├",
          collapsed = "─",
          expanded = "╮",
          failed = "✘",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          passed = "✓",
          running = "⟳",
          running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
          skipped = "○",
          unknown = "?"
        },
        floating = {
          border = "rounded",
          max_height = 0.6,
          max_width = 0.6,
          options = {}
        },
        highlights = {
          adapter_name = "NeotestAdapterName",
          border = "NeotestBorder",
          dir = "NeotestDir",
          expand_marker = "NeotestExpandMarker",
          failed = "NeotestFailed",
          file = "NeotestFile",
          focused = "NeotestFocused",
          indent = "NeotestIndent",
          marked = "NeotestMarked",
          namespace = "NeotestNamespace",
          passed = "NeotestPassed",
          running = "NeotestRunning",
          select_win = "NeotestWinSelect",
          skipped = "NeotestSkipped",
          target = "NeotestTarget",
          test = "NeotestTest",
          unknown = "NeotestUnknown"
        }
      })
    end,
  },

  -- Coverage
  {
    "andythigpen/nvim-coverage",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "Coverage",
      "CoverageLoad",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageClear",
    },
    keys = {
      { "<leader>tcl", "<cmd>CoverageLoad<cr>", desc = "Load Coverage" },
      { "<leader>tcs", "<cmd>CoverageShow<cr>", desc = "Show Coverage" },
      { "<leader>tch", "<cmd>CoverageHide<cr>", desc = "Hide Coverage" },
      { "<leader>tct", "<cmd>CoverageToggle<cr>", desc = "Toggle Coverage" },
      { "<leader>tcc", "<cmd>CoverageClear<cr>", desc = "Clear Coverage" },
    },
    config = function()
      require("coverage").setup({
        commands = true,
        highlights = {
          covered = { fg = "#C3E88D" },
          uncovered = { fg = "#F07178" },
        },
        signs = {
          covered = { hl = "CoverageCovered", text = "▎" },
          uncovered = { hl = "CoverageUncovered", text = "▎" },
        },
        summary = {
          min_coverage = 80.0,
        },
        lang = {
          javascript = {
            coverage_file = "coverage/lcov.info",
          },
          typescript = {
            coverage_file = "coverage/lcov.info",
          },
          php = {
            coverage_file = "coverage/clover.xml",
          },
        },
      })
    end,
  },

  -- Simple HTTP client alternative
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>rr", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP request" },
      { "<leader>ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run all HTTP requests" },
      { "<leader>ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect HTTP request" },
    },
    config = function()
      require("kulala").setup()
    end,
  },

  -- Performance profiling
  {
    "stevearc/profile.nvim",
    keys = {
      { "<leader>pp", function() require("profile").start("*") end, desc = "Start Profiling" },
      { "<leader>ps", function() require("profile").stop() end, desc = "Stop Profiling" },
      { "<leader>pr", function() require("profile").start("require") end, desc = "Profile Requires" },
    },
    config = function()
      local should_profile = os.getenv("NVIM_PROFILE")
      if should_profile then
        require("profile").instrument_autocmds()
        if should_profile:lower():match("^start") then
          require("profile").start("*")
        else
          require("profile").instrument("*")
        end
      end

      local function toggle_profile()
        local prof = require("profile")
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format("Wrote %s", filename))
            end
          end)
        else
          prof.start("*")
        end
      end
      vim.keymap.set("", "<f1>", toggle_profile)
    end,
  },
}