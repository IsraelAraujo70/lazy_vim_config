-- Script para ajudar na configuração do terminal
local M = {}

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