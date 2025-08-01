-- Script para baixar e instalar Nerd Fonts automaticamente
local M = {}

-- Função para verificar se uma fonte está instalada (otimizada)
local function is_font_installed(font_name)
  local handle = io.popen("fc-list | grep -qi '" .. font_name .. "' && echo '1' || echo '0'")
  local result = handle:read("*a")
  handle:close()
  return result and result:match("1")
end

-- Função para listar todas as fontes instaladas
local function list_installed_fonts()
  print("\n🔍 Fontes monospace instaladas no sistema:")
  local handle = io.popen("fc-list :mono | grep -E '(JetBrains|Fira|Noto|Font|Hack|Source)' | cut -d: -f2 | sort | uniq")
  local result = handle:read("*a")
  handle:close()
  
  if result and result ~= "" then
    for line in result:gmatch("[^\r\n]+") do
      if line and line:gsub("%s+", "") ~= "" then
        print("  ✓ " .. line:gsub("^%s+", ""):gsub("%s+$", ""))
      end
    end
  else
    print("  ❌ Nenhuma fonte monospace encontrada")
  end
end

-- Função para baixar e instalar uma fonte (método otimizado via wget)
local function install_font(font_name, font_url)
  local fonts_dir = os.getenv("HOME") .. "/.local/share/fonts"
  
  -- Criar diretório se não existir
  os.execute("mkdir -p " .. fonts_dir .. " 2>/dev/null")
  
  print("📦 Instalando " .. font_name .. "...")
  
  -- Método otimizado: download direto, extração e limpeza em uma linha
  local install_cmd = string.format(
    "wget -P %s %s && cd %s && unzip -qq %s.zip && rm %s.zip && fc-cache -fv > /dev/null 2>&1",
    fonts_dir, font_url, fonts_dir, font_name, font_name
  )
  
  if os.execute(install_cmd) == 0 then
    print("✓ " .. font_name .. " instalada!")
    return true
  else
    print("✗ Erro ao instalar " .. font_name)
    return false
  end
end

-- Função para atualizar cache de fontes
local function update_font_cache()
  print("Atualizando cache de fontes...")
  os.execute("fc-cache -fv ~/.local/share/fonts > /dev/null 2>&1")
  print("✓ Cache de fontes atualizado!")
end

-- Função para detectar o gerenciador de pacotes
local function detect_package_manager()
  local managers = {
    { cmd = "dnf", distro = "fedora" },
    { cmd = "apt", distro = "ubuntu" },
    { cmd = "yum", distro = "rhel" },
    { cmd = "pacman", distro = "arch" },
    { cmd = "zypper", distro = "opensuse" }
  }
  
  for _, manager in ipairs(managers) do
    local handle = io.popen("command -v " .. manager.cmd .. " 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    
    if result and result ~= "" then
      return manager.cmd, manager.distro
    end
  end
  
  return nil, "unknown"
end

-- Função para verificar se um pacote está instalado via DNF
local function is_package_installed_dnf(package_name)
  local handle = io.popen("dnf list installed " .. package_name .. " 2>/dev/null | grep -c '" .. package_name .. "'")
  local result = handle:read("*a")
  handle:close()
  return tonumber(result) > 0
end

-- Função para verificar se um pacote está instalado via APT
local function is_package_installed_apt(package_name)
  local handle = io.popen("dpkg -l " .. package_name .. " 2>/dev/null | grep -c '^ii'")
  local result = handle:read("*a")
  handle:close()
  return tonumber(result) > 0
end

-- Função para verificar se pacotes estão instalados baseado no sistema
local function are_font_packages_installed()
  local package_manager, distro = detect_package_manager()
  
  local font_packages = {}
  if package_manager == "dnf" then
    font_packages = {
      "jetbrains-mono-fonts",
      "fira-code-fonts", 
      "google-noto-emoji-fonts",
      "fontawesome-fonts",
      "powerline-fonts"
    }
  elseif package_manager == "apt" then
    font_packages = {
      "fonts-jetbrains-mono",
      "fonts-firacode",
      "fonts-noto-emoji",
      "fonts-fontawesome",
      "fonts-powerline"
    }
  else
    return false -- Para outros sistemas, usar verificação de fonte
  end
  
  local installed_count = 0
  for _, package in ipairs(font_packages) do
    if package_manager == "dnf" and is_package_installed_dnf(package) then
      installed_count = installed_count + 1
    elseif package_manager == "apt" and is_package_installed_apt(package) then
      installed_count = installed_count + 1
    end
  end
  
  -- Se pelo menos 3 dos 5 pacotes estão instalados, considerar como já instalado
  return installed_count >= 3
end

-- Função para instalar via DNF (Fedora/RHEL)
local function install_fonts_fedora()
  print("🔧 Instalando fontes via DNF...")
  
  local fonts_to_install = {
    "jetbrains-mono-fonts",
    "fira-code-fonts", 
    "google-noto-emoji-fonts",
    "fontawesome-fonts",
    "powerline-fonts"
  }
  
  for _, font_package in ipairs(fonts_to_install) do
    print("📦 Instalando " .. font_package .. "...")
    local cmd = "sudo dnf install -y " .. font_package .. " 2>/dev/null || echo 'Pacote não encontrado: " .. font_package .. "'"
    os.execute(cmd)
  end
  
  return true
end

-- Função para instalar via APT (Ubuntu/Debian)
local function install_fonts_ubuntu()
  print("🔧 Instalando fontes via APT...")
  
  -- Primeiro, atualizar a lista de pacotes
  print("📦 Atualizando lista de pacotes...")
  os.execute("sudo apt update -qq 2>/dev/null")
  
  local fonts_to_install = {
    "fonts-jetbrains-mono",
    "fonts-firacode",
    "fonts-noto-emoji",
    "fonts-fontawesome",
    "fonts-powerline"
  }
  
  for _, font_package in ipairs(fonts_to_install) do
    print("📦 Instalando " .. font_package .. "...")
    local cmd = "sudo apt install -y " .. font_package .. " 2>/dev/null || echo 'Pacote não encontrado: " .. font_package .. "'"
    os.execute(cmd)
  end
  
  return true
end

-- Função para instalar via Pacman (Arch Linux)
local function install_fonts_arch()
  print("🔧 Instalando fontes via Pacman...")
  
  local fonts_to_install = {
    "ttf-jetbrains-mono",
    "ttf-fira-code",
    "noto-fonts-emoji",
    "ttf-font-awesome",
    "powerline-fonts"
  }
  
  for _, font_package in ipairs(fonts_to_install) do
    print("📦 Instalando " .. font_package .. "...")
    local cmd = "sudo pacman -S --noconfirm " .. font_package .. " 2>/dev/null || echo 'Pacote não encontrado: " .. font_package .. "'"
    os.execute(cmd)
  end
  
  return true
end

-- Função para instalar fontes baseada no sistema
local function install_fonts_system()
  local package_manager, distro = detect_package_manager()
  
  print("🔍 Sistema detectado: " .. (distro or "desconhecido"))
  print("📦 Gerenciador de pacotes: " .. (package_manager or "não encontrado"))
  
  if package_manager == "dnf" then
    return install_fonts_fedora()
  elseif package_manager == "apt" then
    return install_fonts_ubuntu()
  elseif package_manager == "pacman" then
    return install_fonts_arch()
  elseif package_manager == "yum" then
    -- Para RHEL/CentOS mais antigos, usar yum com pacotes similares ao DNF
    print("🔧 Instalando fontes via YUM...")
    local fonts_to_install = {
      "google-noto-emoji-fonts",
      "fontawesome-fonts",
    }
    
    for _, font_package in ipairs(fonts_to_install) do
      print("📦 Instalando " .. font_package .. "...")
      local cmd = "sudo yum install -y " .. font_package .. " 2>/dev/null || echo 'Pacote não encontrado: " .. font_package .. "'"
      os.execute(cmd)
    end
    return true
  else
    print("⚠️  Gerenciador de pacotes não suportado, tentando download direto...")
    return false
  end
end

-- Lista de fontes essenciais para LazyVim (URLs específicas v3.0.2)
local fonts = {
  {
    name = "JetBrainsMono",
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  },
  {
    name = "FiraCode", 
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
  },
  {
    name = "Hack",
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
  }
}

-- Função principal para instalar todas as fontes necessárias
function M.setup()
  print("🔍 Verificando Nerd Fonts...")
  
  -- Primeiro verificar se os pacotes já estão instalados
  if are_font_packages_installed() then
    print("✅ Fontes já instaladas via gerenciador de pacotes!")
    list_installed_fonts()
    return
  end
  
  -- Verificar se as fontes básicas estão instaladas
  local basic_fonts_missing = false
  local basic_fonts = {"JetBrains", "Fira", "Noto"}
  
  for _, font in ipairs(basic_fonts) do
    if not is_font_installed(font) then
      basic_fonts_missing = true
      break
    end
  end
  
  if basic_fonts_missing then
    print("📦 Instalando fontes via repositório do sistema...")
    local system_success = install_fonts_system()
    
    if not system_success then
      print("🚀 Tentando instalar Nerd Fonts via download...")
      for _, font in ipairs(fonts) do
        install_font(font.name, font.url)
      end
    end
    
    update_font_cache()
    
    print("\n🎉 Fontes instaladas! Reinicie seu terminal e configure para usar:")
    print("   - JetBrains Mono")
    print("   - Fira Code") 
    print("   - Noto Emoji")
    print("\nPara configurar no terminal:")
    print("   GNOME Terminal: Preferências > Perfis > Fonte")
    print("   Terminal (Ubuntu): Preferências > Fonte")
    print("   Konsole (KDE): Configurações > Editar perfil > Aparência > Fonte")
  else
    print("✅ Fontes básicas já encontradas no sistema!")
    list_installed_fonts()
  end
end

-- Auto-executar na primeira vez (otimizado para evitar tela preta)
function M.auto_setup()
  -- Verificação rápida: se tem JetBrains ou Fira, já está bom
  if is_font_installed("JetBrains") or is_font_installed("Fira") then
    return -- Sai silenciosamente se já tem fontes
  end
  
  -- Verificação de pacotes apenas se não tem fontes básicas
  if are_font_packages_installed() then
    return -- Sai silenciosamente se pacotes estão instalados
  end
  
  -- Só mostra mensagem se realmente vai instalar
  print("🚀 Instalando fontes essenciais...")
  
  -- Instalar apenas JetBrains Mono (mais rápido)
  local jetbrains_url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  if install_font("JetBrainsMono", jetbrains_url) then
    print("✅ Fonte instalada! Configure seu terminal para usar JetBrains Mono")
  else
    -- Fallback para método do sistema
    install_fonts_system()
  end
end

-- Expor a função list_installed_fonts
function M.list_installed_fonts()
  list_installed_fonts()
end

return M