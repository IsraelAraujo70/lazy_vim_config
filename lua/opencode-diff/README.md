# OpenCode Integration for Neovim

Esta integração permite que o [OpenCode](https://opencode.ai) envie diffs diretamente para o Neovim, proporcionando uma experiência visual rica para revisar e aplicar mudanças de código.

## 🚀 Funcionalidades

- **Visualização side-by-side** de diffs com highlighting sintático
- **Descoberta automática de porta** - suporta múltiplas instâncias do Neovim
- **Health check endpoint** para verificação de instâncias ativas
- **Configuração automática** do opencode.json
- **Sincronização de scroll** entre painéis
- **Keymaps personalizáveis** para aceitar/rejeitar mudanças

## 📦 Instalação

A integração já está configurada nesta config do Neovim. Os arquivos incluem:

```
lua/
├── opencode-diff/
│   ├── init.lua          # Módulo principal
│   └── install.lua       # Gerenciamento do bridge script
└── plugins/
    └── opencode-diff.lua # Configuração do plugin
```

## 🔧 Configuração

### 1. Instalar o Bridge Script

```vim
:OpenCodeInstallBridge
```

Isso instala o script `nvim-opencode-bridge` em `~/.local/bin/` (ou outro diretório apropriado).

### 2. Verificar Instalação

```vim
:OpenCodeStatus
```

### 3. Configuração Automática

O plugin configura automaticamente o `opencode.json` no diretório do projeto com os hooks necessários:

```json
{
  "experimental": {
    "hook": {
      "file_edited": {
        ".lua": [{
          "command": ["nvim-opencode-bridge"],
          "environment": {
            "OPENCODE_FILE": "$FILE",
            "OPENCODE_ACTION": "edited"
          }
        }],
        ".ts": [{ /* ... */ }],
        ".js": [{ /* ... */ }]
        // ... outras extensões
      }
    }
  }
}
```

## 🎯 Como Usar

### 1. Iniciar o Neovim
O servidor HTTP inicia automaticamente e encontra uma porta disponível (38600+).

### 2. Usar o OpenCode
Execute comandos normalmente no opencode:
```bash
opencode "fix this function"
opencode "add error handling to this code"
```

### 3. Visualizar Diffs
Quando o opencode fizer mudanças, uma nova aba será aberta automaticamente mostrando:
- **Painel esquerdo**: Código original
- **Painel direito**: Código modificado
- **Highlighting**: Linhas adicionadas (verde), removidas (vermelho), modificadas (amarelo)

### 4. Aceitar/Rejeitar Mudanças
- `<leader>oa` - Aceitar mudanças
- `<leader>or` - Rejeitar mudanças  
- `<leader>od` - Mostrar diff atual
- `q` ou `<Esc>` - Fechar visualização

## 🔧 Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `:OpenCode <prompt>` | Executar opencode com prompt |
| `:OpenCodeDiff` | Mostrar diff atual |
| `:OpenCodeAccept` | Aceitar mudanças pendentes |
| `:OpenCodeReject` | Rejeitar mudanças pendentes |
| `:OpenCodeStatus` | Mostrar status da integração |
| `:OpenCodeInstallBridge` | Instalar bridge script |
| `:OpenCodeCheckBridge` | Verificar instalação do bridge |
| `:OpenCodeUninstallBridge` | Desinstalar bridge script |

## ⚙️ Configuração Personalizada

Você pode personalizar a integração editando `lua/plugins/opencode-diff.lua`:

```lua
require("opencode-diff").setup({
  -- Porta base (será encontrada automaticamente)
  server_port_base = 38600,
  
  -- Configuração automática do opencode.json
  auto_setup_hooks = true,
  
  -- Keymaps personalizados
  keymaps = {
    accept = "<leader>oa",
    reject = "<leader>or", 
    show_diff = "<leader>od",
  },
  
  -- Opções de diff
  diff_options = {
    algorithm = "github",
    context = 3,
    full_context = true,
    ignore_whitespace = false,
    word_diff = true,
  },
})
```

## 🔍 Descoberta Dinâmica de Porta

O sistema usa múltiplos métodos para encontrar instâncias ativas do Neovim:

1. **Arquivos de porta**: `/tmp/opencode-diff/nvim-port-*`
2. **Health checks**: Testa conectividade HTTP
3. **Scan de portas**: Verifica ranges comuns (38600-38700)
4. **Compatibilidade**: Suporta instâncias claude-diff existentes

## 🐛 Troubleshooting

### Bridge Script Não Encontrado
```vim
:OpenCodeInstallBridge
```

### Porta Não Disponível
O sistema encontra automaticamente uma porta livre. Verifique com:
```vim
:OpenCodeStatus
```

### OpenCode Não Conecta
1. Verifique se o bridge está no PATH:
   ```bash
   which nvim-opencode-bridge
   ```

2. Teste manualmente:
   ```bash
   echo '{"filename":"test.txt","new_content":"hello","action":"edited"}' | \
   curl -X POST -H "Content-Type: application/json" -d @- http://localhost:38600/diff
   ```

### Múltiplas Instâncias
Cada instância do Neovim usa uma porta diferente automaticamente. O bridge encontra a instância correta baseada no diretório de trabalho.

## 🔄 Diferenças do Claude Code

| Aspecto | Claude Code | OpenCode |
|---------|-------------|----------|
| **Config** | `.claude/settings.json` | `opencode.json` |
| **Hooks** | `PostToolUse` | `file_edited` |
| **Trigger** | Tool matcher | Por extensão |
| **Porta** | Fixa (38500) | Dinâmica (38600+) |
| **Bridge** | `nvim-claude-bridge` | `nvim-opencode-bridge` |

## 📝 Logs e Debug

Para debug, verifique:
- Logs do Neovim: `:messages`
- Status do servidor: `:OpenCodeStatus`
- Teste do bridge: Execute manualmente o script

## 🤝 Compatibilidade

- ✅ Funciona junto com claude-diff (portas diferentes)
- ✅ Suporta múltiplas instâncias do Neovim
- ✅ Compatível com todos os LLM providers do opencode
- ✅ Funciona em Linux, macOS e WSL