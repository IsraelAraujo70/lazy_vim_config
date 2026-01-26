-- OpenCode.nvim - Integracao com OpenCode AI via tmux
return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    keys = {
      -- Leader keymaps (aparecem no which-key)
      { "<leader>oo", function() require("opencode").choose_backend() end, desc = "Toggle OpenCode" },
      { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask OpenCode", mode = { "n", "x" } },
      { "<leader>os", function() require("opencode").select() end, desc = "Select action", mode = { "n", "x" } },
      { "<leader>oL", function() require("opencode").operator("@this ") end, desc = "Add line to OpenCode", expr = true },
      { "<leader>od", function() require("opencode").open_desktop_and_server() end, desc = "Open Desktop + Server" },
      { "<leader>ol", function() require("opencode").list_opencode_servers() end, desc = "Listar/Kill servers" },
      { "<leader>op", function() require("opencode").pick_model() end, desc = "Selecionar provider/model" },
      -- Ctrl+. para toggle rapido
      { "<C-.>", function() require("opencode").toggle() end, desc = "Toggle OpenCode", mode = { "n", "t" } },
    },
    config = function()
      local function system(cmd, opts)
        local result = vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait()
        return result.code, result.stdout or "", result.stderr or ""
      end

      local function is_executable(cmd)
        return vim.fn.executable(cmd) == 1
      end

      local function is_port_listening(port)
        if not is_executable("lsof") then
          return false
        end
        local code, stdout = system({ "lsof", "-iTCP:" .. tostring(port), "-sTCP:LISTEN", "-P", "-n" })
        return code == 0 and stdout ~= ""
      end

      local function pick_tmux_port()
        for port = 4097, 4107 do
          if not is_port_listening(port) then
            return port
          end
        end
        return 4097
      end

      local function resolve_desktop_cmd()
        if is_executable("OpenCode") then
          return "OpenCode"
        end
        if is_executable("/usr/bin/OpenCode") then
          return "/usr/bin/OpenCode"
        end
        return nil
      end

      local function is_desktop_running()
        if not is_executable("pgrep") then
          return false
        end
        local code, stdout = system({ "pgrep", "-f", "OpenCode" })
        return code == 0 and stdout ~= ""
      end

      local function start_desktop()
        local cmd = resolve_desktop_cmd()
        if not cmd then
          vim.notify("OpenCode Desktop nao encontrado no PATH.", vim.log.levels.ERROR)
          return false
        end
        if not is_desktop_running() then
          vim.system({ cmd }, { detach = true })
        end
        return true
      end

      local function start_server(port)
        if not is_executable("opencode") then
          vim.notify("Binario 'opencode' nao encontrado no PATH.", vim.log.levels.ERROR)
          return false
        end
        if is_port_listening(port) then
          return true
        end
        vim.system({ "opencode", "serve", "--port", tostring(port) }, { detach = true })
        return true
      end

      local function get_command_for_pid(pid)
        if not is_executable("ps") then
          return ""
        end
        local _, stdout = system({ "ps", "-o", "args=", "-p", tostring(pid) })
        return vim.trim(stdout)
      end

      local function get_port_for_pid(pid)
        if not is_executable("lsof") then
          return nil
        end
        local _, stdout = system({ "lsof", "-w", "-iTCP", "-sTCP:LISTEN", "-P", "-n", "-a", "-p", tostring(pid) })
        if stdout == "" then
          return nil
        end
        for line in stdout:gmatch("[^\r\n]+") do
          if not line:match("^COMMAND") then
            local port = line:match(":(%d+)%s") or line:match(":(%d+)$")
            if port then
              return tonumber(port)
            end
          end
        end
        return nil
      end

      local function get_opencode_pids()
        if not is_executable("pgrep") then
          return {}
        end
        local code, stdout = system({ "pgrep", "-f", "opencode.*--port" })
        if code ~= 0 or stdout == "" then
          return {}
        end
        local pids = {}
        for line in stdout:gmatch("[^\r\n]+") do
          local pid = tonumber(line)
          if pid then
            table.insert(pids, pid)
          end
        end
        return pids
      end

      local function rebuild_provider(provider_name)
        local config = require("opencode.config")
        if not provider_name then
          config.provider = nil
          return
        end

        local provider_opts = config.opts.provider or {}
        provider_opts.enabled = provider_name

        local ok, provider_mod = pcall(require, "opencode.provider." .. provider_name)
        if not ok then
          vim.notify("Falha ao carregar provider '" .. provider_name .. "': " .. provider_mod, vim.log.levels.ERROR)
          config.provider = nil
          return
        end

        local resolved_provider_opts = provider_opts[provider_name]
        local provider = provider_mod.new(resolved_provider_opts)
        provider.cmd = provider.cmd or provider_opts.cmd

        local port = config.opts.port
        if port and provider.cmd then
          provider.cmd = provider.cmd:gsub("--port ?", "") .. " --port " .. tostring(port)
        end

        config.provider = provider
      end

      local function set_mode_desktop()
        local config = require("opencode.config")
        config.opts.port = 4096
        if config.opts.provider then
          config.opts.provider.enabled = false
        end
        rebuild_provider(nil)
      end

      local function set_mode_tmux()
        local config = require("opencode.config")
        config.opts.port = pick_tmux_port()
        if config.opts.provider then
          config.opts.provider.enabled = "tmux"
        end
        rebuild_provider("tmux")
      end

      local function open_desktop_and_server()
        local port = 4096
        set_mode_desktop()
        local desktop_ok = start_desktop()
        local server_ok = start_server(port)
        require("opencode.config").opts.port = port
        if desktop_ok and server_ok then
          vim.notify(
            "OpenCode Desktop aberto. No app, clique no nome do servidor e selecione http://localhost:4096.",
            vim.log.levels.INFO
          )
        end
      end

      local function open_tmux()
        set_mode_tmux()
        local ok, err = pcall(require("opencode.provider").start)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
        end
      end

      local function choose_backend()
        local items = {
          { label = "Desktop (API 4096)", value = "desktop" },
          { label = "Terminal (tmux)", value = "tmux" },
        }
        vim.ui.select(items, {
          prompt = "OpenCode",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if not choice then
            return
          end
          if choice.value == "desktop" then
            open_desktop_and_server()
          else
            open_tmux()
          end
        end)
      end

      local function list_and_kill_servers()
        local items = {}
        for _, pid in ipairs(get_opencode_pids()) do
          table.insert(items, {
            pid = pid,
            port = get_port_for_pid(pid),
            cmd = get_command_for_pid(pid),
          })
        end

        if #items == 0 then
          vim.notify("Nenhum server opencode encontrado.", vim.log.levels.INFO)
          return
        end

        vim.ui.select(items, {
          prompt = "OpenCode servers",
          format_item = function(item)
            local port = item.port and tostring(item.port) or "-"
            local cmd = item.cmd ~= "" and item.cmd or "<cmd indisponivel>"
            return string.format("pid %d  port %s  %s", item.pid, port, cmd)
          end,
        }, function(choice)
          if not choice then
            return
          end
          local confirm = vim.fn.confirm("Matar processo PID " .. choice.pid .. "?", "&Sim\n&Nao", 2)
          if confirm == 1 then
            system({ "kill", tostring(choice.pid) })
            vim.notify("Processo " .. choice.pid .. " finalizado.", vim.log.levels.INFO)
          end
        end)
      end

      local function api_call(port, path, method, body)
        local promise = require("opencode.promise")
        return promise.new(function(resolve)
          require("opencode.cli.client").call(port, path, method, body, function(response)
            resolve(response)
          end)
        end)
      end

      local function select_latest_session(sessions, cwd)
        local best = nil
        for _, session in ipairs(sessions or {}) do
          if session.directory == cwd then
            if not best or (session.time and session.time.updated or 0) > (best.time and best.time.updated or 0) then
              best = session
            end
          end
        end
        return best
      end

      local current_model = nil
      local function current_model_label()
        if not current_model then
          return nil
        end
        if require("opencode.config").opts.port ~= 4096 then
          return nil
        end
        return string.format("%s/%s", current_model.providerID, current_model.modelID)
      end

      local function pick_model()
        require("opencode.cli.server")
          .get_port(false)
          :next(function(port)
            if port ~= 4096 then
              vim.notify("Selecao de modelo so no modo API (porta 4096).", vim.log.levels.WARN)
              return nil
            end
            return api_call(port, "/provider", "GET", nil)
          end)
          :next(function(payload)
            if not payload then
              return nil
            end
            local items = {}
            for _, provider in ipairs(payload.all or {}) do
              for model_id, model in pairs(provider.models or {}) do
                local provider_name = provider.name or provider.id
                local model_name = model.name or model_id
                table.insert(items, {
                  label = string.format("%s / %s", provider_name, model_name),
                  value = { providerID = provider.id, modelID = model_id },
                })
              end
            end
            table.sort(items, function(a, b)
              return a.label < b.label
            end)
            table.insert(items, 1, { label = "(usar default do servidor)", value = nil })
            vim.ui.select(items, {
              prompt = "Provider / Model",
              format_item = function(item)
                return item.label
              end,
            }, function(choice)
              if not choice then
                return
              end
              current_model = choice.value
              if current_model then
                vim.notify(
                  string.format("Modelo selecionado: %s/%s", current_model.providerID, current_model.modelID),
                  vim.log.levels.INFO
                )
              else
                vim.notify("Usando default do servidor.", vim.log.levels.INFO)
              end
            end)
            return true
          end)
          :catch(function(err)
            vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
          end)
      end

      local function prompt_via_api(prompt, opts)
        local referenced = require("opencode.config").opts.prompts[prompt]
        local resolved_prompt = referenced and referenced.prompt or prompt
        opts = {
          clear = opts and opts.clear or false,
          submit = opts and opts.submit or false,
          context = opts and opts.context or require("opencode.context").new(),
        }

        require("opencode.cli.server")
          .get_port(false)
          :next(function(port)
            if port ~= 4096 then
              return nil
            end

            local rendered = opts.context:render(resolved_prompt)
            local plaintext = opts.context.plaintext(rendered.output)
            local cwd = vim.fn.getcwd()
            local encoded = vim.uri_encode and vim.uri_encode(cwd) or cwd:gsub(" ", "%%20")

            return api_call(port, "/session?directory=" .. encoded, "GET", nil)
              :next(function(sessions)
                local session = select_latest_session(sessions, cwd)
                if session then
                  return { port = port, session_id = session.id, prompt = plaintext }
                end
                return api_call(port, "/session", "POST", {})
                  :next(function(created)
                    return { port = port, session_id = created.id, prompt = plaintext }
                  end)
              end)
          end)
          :next(function(state)
            if not state then
              return nil
            end
            require("opencode.events").subscribe()
            local payload = {
              parts = {
                {
                  type = "text",
                  text = state.prompt,
                },
              },
            }
            if current_model then
              payload.model = current_model
            end
            return api_call(state.port, "/session/" .. state.session_id .. "/message", "POST", payload)
          end)
          :catch(function(err)
            vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
          end)
          :next(function()
            opts.context:clear()
          end)
      end

      local original_prompt = require("opencode.api.prompt").prompt
      local function prompt_dispatch(prompt, opts)
        if require("opencode.config").opts.port == 4096 then
          return prompt_via_api(prompt, opts)
        end
        return original_prompt(prompt, opts)
      end

      local opencode = require("opencode")
      opencode.open_desktop_and_server = open_desktop_and_server
      opencode.list_opencode_servers = list_and_kill_servers
      opencode.pick_model = pick_model
      opencode.choose_backend = choose_backend

      local original_statusline = opencode.statusline
      opencode.statusline = function()
        local icon = original_statusline()
        local label = current_model_label()
        if label then
          return string.format("%s %s", icon, label)
        end
        return icon
      end
      opencode.prompt = prompt_dispatch
      require("opencode.api.prompt").prompt = prompt_dispatch

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        port = nil,
        provider = {
          enabled = "tmux",
          tmux = {},
        },
        prompts = {},
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
