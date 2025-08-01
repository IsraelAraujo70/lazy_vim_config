-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Auto-instalar Nerd Fonts se necessário
require("config.nerd-fonts").auto_setup()

-- Configurar comandos para ajudar com fontes
require("config.terminal-setup").setup_commands()
