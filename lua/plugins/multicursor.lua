-- vim-visual-multi - Multi-cursor estilo VSCode
return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      -- Configurar Ctrl+D para selecionar proxima ocorrencia (estilo VSCode)
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",         -- Ctrl+D seleciona palavra e proxima
        ["Find Subword Under"] = "<C-d>", -- Funciona em partes de palavras
        ["Select All"] = "<C-S-l>",       -- Ctrl+Shift+L seleciona todas
        ["Skip Region"] = "<C-k>",        -- Ctrl+K pula ocorrencia
        ["Remove Region"] = "<C-p>",      -- Ctrl+P remove cursor
      }
      -- Tema visual
      vim.g.VM_theme = "iceblue"
      -- Mostrar warnings
      vim.g.VM_show_warnings = 0
    end,
  },
}
