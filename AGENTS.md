# AGENTS.md - Neovim Configuration

## Build/Test/Lint Commands
- **Format Lua**: `stylua .` (uses stylua.toml config)
- **No package.json**: This is a Lua-based Neovim config, no npm commands
- **No test suite**: Configuration files don't have automated tests

## Code Style Guidelines

### Lua Formatting
- **Indentation**: 2 spaces (no tabs)
- **Line width**: 120 characters max
- **String quotes**: Use double quotes for strings
- **Table formatting**: Trailing commas in multi-line tables

### File Structure
- **Config files**: `lua/config/` - core Neovim settings
- **Plugins**: `lua/plugins/` - plugin configurations  
- **Custom modules**: `lua/claude-diff/` - custom functionality

### Naming Conventions
- **Files**: kebab-case (e.g., `terminal-setup.lua`)
- **Variables**: snake_case (e.g., `state.current_diff`)
- **Functions**: snake_case (e.g., `show_diff_view`)
- **Constants**: UPPER_SNAKE_CASE

### Import Style
- Use `require()` for modules
- Local variables for frequently used modules: `local api = vim.api`
- Group requires at top of file

### Error Handling
- Use `pcall()` for operations that might fail
- Provide meaningful error messages with `vim.notify()`
- Always validate inputs and check if buffers/windows are valid