# Claude Code + Neovim Integration

Plugin simples que integra Claude Code com Neovim usando terminal, similar à extensão do VSCode.

## ✨ Funcionalidades

- 🚀 **Execução direta** do Claude Code via terminal no Neovim
- 🔧 **Quick Fix** com contexto automático (similar ao VSCode)
- 📤 **Envio de arquivos** para análise do Claude
- 💻 **Terminal integrado** (split ou floating)
- 🎯 **Suporte a seleções** e diagnósticos automáticos

## 🚀 Como usar

O plugin funciona executando o comando `claude` diretamente no terminal do Neovim, similar à extensão do VSCode.

### Comandos principais:

1. **`:ClaudeRun`** - Executa Claude Code no arquivo atual
2. **`:ClaudeQuickFix`** - Executa quick fix com contexto automático  
3. **`:ClaudeSend`** - Envia arquivo atual para Claude
4. **`:ClaudeToggle`** - Alterna terminal do Claude

## ⌨️ Keymaps

| Tecla | Comando | Descrição |
|-------|---------|-----------|
| `<leader>cc` | `:ClaudeRun` | Executar Claude Code |
| `<leader>cf` | `:ClaudeQuickFix` | Quick Fix com Claude |
| `<leader>cs` | `:ClaudeSend` | Enviar arquivo para Claude |
| `<leader>ct` | `:ClaudeToggle` | Toggle terminal Claude |

## 🛠️ Comandos disponíveis

- `:ClaudeRun [args]` - Executa Claude Code com argumentos opcionais
- `:ClaudeQuickFix [prompt]` - Quick fix com prompt customizado opcional
- `:ClaudeSend` - Envia arquivo atual para Claude
- `:ClaudeToggle` - Alterna visibilidade do terminal Claude

## ⚙️ Configuração

```lua
require("claude-code-nvim").setup({
  claude_command = "claude",        -- Comando do Claude Code
  auto_start_terminal = true,       -- Auto-iniciar terminal
  terminal_name = "Claude Code",    -- Nome do terminal
  use_floating_terminal = false,    -- Terminal flutuante (true/false)
  keymaps = {
    run_claude = "<leader>cc",      -- Executar Claude
    quick_fix = "<leader>cf",       -- Quick fix
    send_file = "<leader>cs",       -- Enviar arquivo
  },
})
```

## 🔧 Como funciona

1. **Execução via terminal**: Plugin cria um terminal e executa o comando `claude`
2. **Contexto automático**: Envia informações do arquivo, seleção e diagnósticos
3. **Quick Fix inteligente**: Constrói prompts similares à extensão VSCode
4. **Terminal reutilizável**: Mantém terminal aberto para múltiplas interações

## 📋 Quick Fix Features

O comando `:ClaudeQuickFix` automaticamente:

- ✅ Detecta o tipo de arquivo e linguagem
- ✅ Inclui seleção atual (se houver)
- ✅ Adiciona diagnósticos do LSP automaticamente
- ✅ Constrói prompt contextual inteligente
- ✅ Executa com argumentos otimizados

Exemplo de prompt gerado:
```
I'm working on a javascript file.
Here's the selected code (lines 10-15):

The code has the following issues:
- Error at line 12: 'variable' is not defined
- Warning at line 14: Unused variable 'temp'
```

## 🎛️ Tipos de Terminal

### Terminal Split (padrão)
- Abre em split horizontal na parte inferior
- Altura fixa de 15 linhas
- Boa para workflows rápidos

### Terminal Flutuante
- Janela flutuante centralizada 
- 80% da tela (largura/altura)
- Melhor para sessões longas

Para ativar terminal flutuante:
```lua
require("claude-code-nvim").setup({
  use_floating_terminal = true,
})
```

## 🐛 Troubleshooting

### Claude não encontrado
Certifique-se que o Claude Code está instalado e no PATH:
```bash
which claude  # Deve retornar o caminho do Claude
claude --version  # Deve mostrar a versão
```

### Terminal não abre
1. Verifique se `termopen` está disponível: `:echo has('nvim')`
2. Teste comando manual: `:terminal claude`

### Keymaps não funcionam
Verifique se não há conflitos:
```vim
:map <leader>cc  # Deve mostrar o mapping do Claude
```

## 📝 Diferenças da extensão VSCode

| Recurso | VSCode Extension | Este Plugin |
|---------|------------------|-------------|
| **Execução** | Terminal interno | Terminal Neovim |
| **Contexto** | Automático | Automático |
| **Quick Fix** | ✅ | ✅ |
| **Diff Visual** | ✅ | Via Claude Code |
| **Accept/Reject** | Botões UI | Via Claude Code |

## 🤝 Contribuindo

Esta é uma implementação simples baseada na análise da extensão VSCode oficial. Para melhorias ou bugs, sinta-se livre para contribuir!