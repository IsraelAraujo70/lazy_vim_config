-- Script para ajudar na configuração do terminal
local M = {}

local command_terminal

local function get_toggleterm()
  local ok, term = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm.nvim não está disponível", vim.log.levels.ERROR)
    return nil
  end
  return term
end

local function get_command_terminal(term_module)
  if not command_terminal then
    command_terminal = term_module.Terminal:new({
      direction = "float",
      close_on_exit = false,
      hidden = true,
    })
  end
  return command_terminal
end

function M.run_in_terminal(opts)
  local term_module = get_toggleterm()
  if not term_module then
    return
  end

  if opts.args == "" then
    vim.notify("Use :T <comando> para executar no terminal", vim.log.levels.WARN)
    return
  end

  local term = get_command_terminal(term_module)
  term:open()
  term:send(opts.args .. "\n", false)
end

function M.show_font_instructions()
  print("\n🎨 Como configurar fontes no seu terminal:")
  
  print("\n🐧 FEDORA/RHEL:")
  print("📱 GNOME Terminal:")
  print("   1. Abra Preferências (Ctrl+,)")
  print("   2. Vá em Perfis > [Seu perfil]")
  print("   3. Desmarque 'Usar fonte do sistema'")
  print("   4. Clique em 'Fonte personalizada'")
  print("   5. Escolha: JetBrains Mono ou Fira Code")
  
  print("\n🟠 UBUNTU/DEBIAN:")
  print("📱 Terminal (padrão):")
  print("   1. Abra Preferências (Ctrl+,)")
  print("   2. Aba 'Texto'")
  print("   3. Desmarque 'Usar fonte monoespaçada do sistema'")
  print("   4. Escolha: JetBrains Mono ou Fira Code")
  
  print("\n📱 GNOME Terminal (se instalado):")
  print("   1. Igual ao procedimento do Fedora")
  
  print("\n🖥️  KONSOLE (KDE - qualquer distro):")
  print("   1. Configurações > Editar perfil atual")
  print("   2. Aba Aparência > Fonte")
  print("   3. Escolha uma fonte instalada")
  
  print("\n🚀 TILIX:")
  print("   1. Preferências > Perfis > [Seu perfil]")
  print("   2. Aba Texto > Fonte personalizada")
  print("   3. Escolha uma fonte instalada")
  
  print("\n💡 TERMINAIS ALTERNATIVOS:")
  print("   - Alacritty: edite ~/.config/alacritty/alacritty.yml")
  print("   - Kitty: edite ~/.config/kitty/kitty.conf")
  print("   - Wezterm: edite ~/.config/wezterm/wezterm.lua")
  print("   - Terminator: Clique direito > Preferências > Perfis > Fonte")
end

function M.test_icons()
  print("\n🧪 Teste de ícones:")
  print("   📁 Pasta")
  print("   📄 Arquivo")
  print("   🚀 Git")
  print("   ⚡ Nvim")
  print("   🔧 Config")
  print("   🐛 Debug")
  print("   📊 Stats")
  
  print("\nSe você vê símbolos estranhos em vez dos ícones acima,")
  print("configure seu terminal para usar uma Nerd Font!")
end

-- Criar comandos do Neovim
function M.setup_commands()
  -- Comando :T para executar comandos no terminal
  vim.api.nvim_create_user_command('T', function(opts)
    local cmd = opts.args
    if cmd == "" then
      local term_module = get_toggleterm()
      if term_module then
        local term = term_module.Terminal:new({
          direction = "float",
          close_on_exit = true,
        })
        term:toggle()
      end
    else
      M.run_in_terminal(opts)
    end
  end, { nargs = '*', desc = 'Executar comando no terminal' })

  vim.api.nvim_create_user_command('NerdFontsInstall', function()
    require('config.nerd-fonts').setup()
  end, { desc = 'Instalar Nerd Fonts' })
  
  vim.api.nvim_create_user_command('NerdFontsHelp', function()
    M.show_font_instructions()
  end, { desc = 'Mostrar instruções para configurar fontes no terminal' })
  
  vim.api.nvim_create_user_command('NerdFontsTest', function()
    M.test_icons()
  end, { desc = 'Testar se os ícones estão funcionando' })
  
  vim.api.nvim_create_user_command('NerdFontsList', function()
    require('config.nerd-fonts').list_installed_fonts()
  end, { desc = 'Listar fontes monospace instaladas no sistema' })
end

return M