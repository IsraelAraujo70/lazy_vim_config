-- Additional treesitter parsers for Python, TypeScript, and Go
-- LSP extras are configured in lua/config/lazy.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
        "typescript",
        "tsx",
        "javascript",
        "go",
        "gomod",
        "gosum",
        "gowork",
      },
    },
  },
}
