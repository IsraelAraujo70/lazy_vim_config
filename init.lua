-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Auto-instalar Nerd Fonts se necessário (executar de forma assíncrona)
vim.schedule(function()
  local ok, err = pcall(require, "config.nerd-fonts")
  if ok then
    require("config.nerd-fonts").auto_setup()
  end
end)

-- Configurar comandos para ajudar com fontes
require("config.terminal-setup").setup_commands()
