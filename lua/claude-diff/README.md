# Claude Code Diff Integration for Neovim

Esta é uma integração completa entre Claude Code e Neovim que mostra diffs antes de aplicar mudanças, permitindo que você aceite ou rejeite as alterações propostas pelo Claude.

## Como Funciona

1. **Plugin Neovim** roda um servidor HTTP local
2. **Claude Code hooks** executam após cada modificação de arquivo
3. **Script bridge** envia diffs para o Neovim via HTTP
4. **Interface visual** mostra as mudanças propostas
5. **Usuário decide** aceitar ou rejeitar as mudanças

## Instalação

O plugin já está configurado no seu LazyVim. Na primeira vez que carregar, ele vai:

1. ✅ Instalar automaticamente o script bridge em `~/.local/bin`
2. ✅ Configurar os hooks do Claude Code em `~/.claude/settings.json`
3. ✅ Iniciar o servidor HTTP na porta 38547

## Comandos Disponíveis

### Comandos Principais
- `:ClaudeDiff` - Mostra o diff atual (se houver)
- `:ClaudeAccept` - Aceita as mudanças propostas
- `:ClaudeReject` - Rejeita as mudanças propostas
- `:ClaudeStatus` - Mostra status da integração

### Comandos de Instalação
- `:ClaudeInstallBridge` - Instala/reinstala o script bridge
- `:ClaudeCheckBridge` - Verifica se o bridge está instalado
- `:ClaudeUninstallBridge` - Remove o script bridge

## Keymaps

- `<leader>cd` - Mostra diff atual
- `<leader>ca` - Aceita mudanças
- `<leader>cr` - Rejeita mudanças
- `<leader>c?` - Status da integração

### Na janela de diff:
- `a` - Aceita mudanças
- `r` - Rejeita mudanças  
- `q` ou `<Esc>` - Fecha sem ação

## Fluxo de Uso

1. **Execute o Claude Code** normalmente:
   ```bash
   claude "fix this function"
   ```

2. **Claude processa** e quando for modificar um arquivo:
   - Hook dispara automaticamente
   - Diff aparece no Neovim
   - Você vê exatamente o que vai mudar

3. **Você decide**:
   - Pressiona `a` para aceitar
   - Pressiona `r` para rejeitar
   - Mudanças só são aplicadas se você aceitar

## Configuração

No seu `lua/plugins/claude-diff.lua`:

```lua
{
  dir = vim.fn.stdpath("config") .. "/lua/claude-diff",
  name = "claude-diff.nvim", 
  config = function()
    require("claude-diff").setup({
      server_port = 38547,           -- Porta do servidor HTTP
      auto_setup_hooks = true,      -- Configurar hooks automaticamente  
      keymaps = {
        accept = "<leader>ca",
        reject = "<leader>cr",
        show_diff = "<leader>cd",
      },
    })
  end,
}
```

## Arquivos Criados

- `~/.local/bin/nvim-claude-bridge` - Script executável
- `~/.claude/settings.json` - Configuração dos hooks (modificado)

## Troubleshooting

### "Bridge script not in PATH"
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Verificar se está funcionando
```vim
:ClaudeStatus
:ClaudeCheckBridge
```

### Reinstalar bridge
```vim
:ClaudeInstallBridge
```

### Ver logs do servidor
O plugin mostra notificações quando recebe diffs ou há erros.

## Vantagens

✅ **Controle total** - Você vê e aprova cada mudança  
✅ **Interface visual** - Diff claro no Neovim  
✅ **Não modifica Claude Code** - Usa API oficial de hooks  
✅ **Instalação automática** - Setup transparente  
✅ **Funciona com qualquer comando** - `claude`, `:ClaudeCode`, etc.  

Esta implementação é **muito superior** à extensão VSCode porque você vê as mudanças ANTES delas serem aplicadas, não depois.