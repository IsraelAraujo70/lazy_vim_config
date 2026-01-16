-- Cursor Dark - Custom colorscheme based on OpenCode cursor-dark theme

-- Define colors from cursor-dark.json
local colors = {
  bg = "#1a1a1a",
  bgDark = "#151515",
  bgLighter = "#252525",
  bgHighlight = "#2a2a2a",
  bgVisual = "#3a3a3a",
  fg = "#d4d4d4",
  fgDark = "#a0a0a0",
  fgGutter = "#4a4a4a",
  cyan = "#4fc1ff",
  blue = "#9cdcfe",
  yellow = "#dcdcaa",
  orange = "#ce9178",
  pink = "#c586c0",
  purple = "#b48ead",
  green = "#6a9955",
  red = "#f44747",
  magenta = "#d16d9e",
  border = "#3a3a3a",
  selection = "#264f78",
  gitAdd = "#89d185",
  gitChange = "#e2c08d",
  gitDelete = "#c74e39",
  diffAddBg = "#2d4a2d",
  diffRemoveBg = "#4a2d2d",
}

-- Create the colorscheme function
local function apply_cursor_dark()
  local function set_hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = "cursor-dark"

  -- Editor
  set_hl("Normal", { fg = colors.fg, bg = colors.bg })
  set_hl("NormalFloat", { fg = colors.fg, bg = colors.bgDark })
  set_hl("FloatBorder", { fg = colors.border, bg = colors.bgDark })
  set_hl("ColorColumn", { bg = colors.bgHighlight })
  set_hl("Cursor", { fg = colors.bg, bg = colors.fg })
  set_hl("CursorLine", { bg = colors.bgHighlight })
  set_hl("CursorColumn", { bg = colors.bgHighlight })
  set_hl("LineNr", { fg = colors.fgGutter })
  set_hl("CursorLineNr", { fg = colors.yellow, bold = true })
  set_hl("SignColumn", { fg = colors.fgGutter, bg = colors.bg })
  set_hl("VertSplit", { fg = colors.border })
  set_hl("WinSeparator", { fg = colors.border })
  set_hl("Folded", { fg = colors.fgDark, bg = colors.bgLighter })
  set_hl("FoldColumn", { fg = colors.fgGutter })
  set_hl("NonText", { fg = colors.fgGutter })
  set_hl("SpecialKey", { fg = colors.fgGutter })
  set_hl("Search", { fg = colors.bg, bg = colors.yellow })
  set_hl("IncSearch", { fg = colors.bg, bg = colors.orange })
  set_hl("CurSearch", { fg = colors.bg, bg = colors.orange })
  set_hl("Substitute", { fg = colors.bg, bg = colors.red })
  set_hl("MatchParen", { fg = colors.yellow, bold = true, underline = true })
  set_hl("Whitespace", { fg = colors.fgGutter })
  set_hl("Visual", { bg = colors.selection })
  set_hl("VisualNOS", { bg = colors.selection })
  set_hl("Pmenu", { fg = colors.fg, bg = colors.bgLighter })
  set_hl("PmenuSel", { fg = colors.fg, bg = colors.selection })
  set_hl("PmenuSbar", { bg = colors.bgLighter })
  set_hl("PmenuThumb", { bg = colors.fgGutter })
  set_hl("WildMenu", { fg = colors.bg, bg = colors.cyan })
  set_hl("StatusLine", { fg = colors.fg, bg = colors.bgLighter })
  set_hl("StatusLineNC", { fg = colors.fgDark, bg = colors.bgDark })
  set_hl("TabLine", { fg = colors.fgDark, bg = colors.bgDark })
  set_hl("TabLineFill", { bg = colors.bgDark })
  set_hl("TabLineSel", { fg = colors.fg, bg = colors.bg })
  set_hl("WinBar", { fg = colors.fg, bg = colors.bg })
  set_hl("WinBarNC", { fg = colors.fgDark, bg = colors.bgDark })
  set_hl("Title", { fg = colors.cyan, bold = true })
  set_hl("ModeMsg", { fg = colors.fg, bold = true })
  set_hl("MoreMsg", { fg = colors.cyan })
  set_hl("Question", { fg = colors.cyan })
  set_hl("WarningMsg", { fg = colors.yellow })
  set_hl("ErrorMsg", { fg = colors.red })
  set_hl("Directory", { fg = colors.cyan })
  set_hl("Conceal", { fg = colors.fgDark })
  set_hl("SpellBad", { sp = colors.red, undercurl = true })
  set_hl("SpellCap", { sp = colors.yellow, undercurl = true })
  set_hl("SpellLocal", { sp = colors.cyan, undercurl = true })
  set_hl("SpellRare", { sp = colors.purple, undercurl = true })

  -- Syntax
  set_hl("Comment", { fg = colors.green, italic = true })
  set_hl("Constant", { fg = colors.purple })
  set_hl("String", { fg = colors.orange })
  set_hl("Character", { fg = colors.orange })
  set_hl("Number", { fg = colors.purple })
  set_hl("Boolean", { fg = colors.purple })
  set_hl("Float", { fg = colors.purple })
  set_hl("Identifier", { fg = colors.blue })
  set_hl("Function", { fg = colors.yellow })
  set_hl("Statement", { fg = colors.cyan })
  set_hl("Conditional", { fg = colors.cyan })
  set_hl("Repeat", { fg = colors.cyan })
  set_hl("Label", { fg = colors.cyan })
  set_hl("Operator", { fg = colors.fg })
  set_hl("Keyword", { fg = colors.cyan })
  set_hl("Exception", { fg = colors.cyan })
  set_hl("PreProc", { fg = colors.pink })
  set_hl("Include", { fg = colors.pink })
  set_hl("Define", { fg = colors.pink })
  set_hl("Macro", { fg = colors.pink })
  set_hl("PreCondit", { fg = colors.pink })
  set_hl("Type", { fg = colors.cyan })
  set_hl("StorageClass", { fg = colors.cyan })
  set_hl("Structure", { fg = colors.cyan })
  set_hl("Typedef", { fg = colors.cyan })
  set_hl("Special", { fg = colors.orange })
  set_hl("SpecialChar", { fg = colors.orange })
  set_hl("Tag", { fg = colors.cyan })
  set_hl("Delimiter", { fg = colors.fg })
  set_hl("SpecialComment", { fg = colors.fgDark })
  set_hl("Debug", { fg = colors.red })
  set_hl("Underlined", { underline = true })
  set_hl("Ignore", { fg = colors.fgGutter })
  set_hl("Error", { fg = colors.red })
  set_hl("Todo", { fg = colors.bg, bg = colors.yellow, bold = true })

  -- Treesitter
  set_hl("@comment", { link = "Comment" })
  set_hl("@variable", { fg = colors.blue })
  set_hl("@variable.builtin", { fg = colors.purple })
  set_hl("@variable.parameter", { fg = colors.blue })
  set_hl("@variable.member", { fg = colors.blue })
  set_hl("@constant", { fg = colors.purple })
  set_hl("@constant.builtin", { fg = colors.purple })
  set_hl("@constant.macro", { fg = colors.purple })
  set_hl("@module", { fg = colors.cyan })
  set_hl("@label", { fg = colors.cyan })
  set_hl("@string", { fg = colors.orange })
  set_hl("@string.escape", { fg = colors.pink })
  set_hl("@string.regexp", { fg = colors.pink })
  set_hl("@character", { fg = colors.orange })
  set_hl("@number", { fg = colors.purple })
  set_hl("@boolean", { fg = colors.purple })
  set_hl("@float", { fg = colors.purple })
  set_hl("@function", { fg = colors.yellow })
  set_hl("@function.builtin", { fg = colors.yellow })
  set_hl("@function.call", { fg = colors.yellow })
  set_hl("@function.macro", { fg = colors.pink })
  set_hl("@function.method", { fg = colors.yellow })
  set_hl("@function.method.call", { fg = colors.yellow })
  set_hl("@constructor", { fg = colors.cyan })
  set_hl("@operator", { fg = colors.fg })
  set_hl("@keyword", { fg = colors.cyan })
  set_hl("@keyword.coroutine", { fg = colors.cyan })
  set_hl("@keyword.function", { fg = colors.cyan })
  set_hl("@keyword.operator", { fg = colors.cyan })
  set_hl("@keyword.import", { fg = colors.pink })
  set_hl("@keyword.type", { fg = colors.cyan })
  set_hl("@keyword.modifier", { fg = colors.cyan })
  set_hl("@keyword.repeat", { fg = colors.cyan })
  set_hl("@keyword.return", { fg = colors.cyan })
  set_hl("@keyword.exception", { fg = colors.cyan })
  set_hl("@keyword.conditional", { fg = colors.cyan })
  set_hl("@punctuation.delimiter", { fg = colors.fg })
  set_hl("@punctuation.bracket", { fg = colors.fg })
  set_hl("@punctuation.special", { fg = colors.pink })
  set_hl("@type", { fg = colors.cyan })
  set_hl("@type.builtin", { fg = colors.cyan })
  set_hl("@type.definition", { fg = colors.cyan })
  set_hl("@type.qualifier", { fg = colors.cyan })
  set_hl("@attribute", { fg = colors.yellow })
  set_hl("@property", { fg = colors.blue })
  set_hl("@tag", { fg = colors.cyan })
  set_hl("@tag.attribute", { fg = colors.yellow })
  set_hl("@tag.delimiter", { fg = colors.fgDark })
  set_hl("@markup.heading", { fg = colors.cyan, bold = true })
  set_hl("@markup.italic", { italic = true })
  set_hl("@markup.strong", { bold = true })
  set_hl("@markup.strikethrough", { strikethrough = true })
  set_hl("@markup.underline", { underline = true })
  set_hl("@markup.quote", { fg = colors.fgDark, italic = true })
  set_hl("@markup.math", { fg = colors.purple })
  set_hl("@markup.link", { fg = colors.cyan })
  set_hl("@markup.link.url", { fg = colors.blue, underline = true })
  set_hl("@markup.raw", { fg = colors.pink })
  set_hl("@markup.list", { fg = colors.cyan })

  -- LSP Semantic Tokens
  set_hl("@lsp.type.class", { fg = colors.cyan })
  set_hl("@lsp.type.decorator", { fg = colors.yellow })
  set_hl("@lsp.type.enum", { fg = colors.cyan })
  set_hl("@lsp.type.enumMember", { fg = colors.purple })
  set_hl("@lsp.type.function", { fg = colors.yellow })
  set_hl("@lsp.type.interface", { fg = colors.cyan })
  set_hl("@lsp.type.macro", { fg = colors.pink })
  set_hl("@lsp.type.method", { fg = colors.yellow })
  set_hl("@lsp.type.namespace", { fg = colors.cyan })
  set_hl("@lsp.type.parameter", { fg = colors.blue })
  set_hl("@lsp.type.property", { fg = colors.blue })
  set_hl("@lsp.type.struct", { fg = colors.cyan })
  set_hl("@lsp.type.type", { fg = colors.cyan })
  set_hl("@lsp.type.typeParameter", { fg = colors.cyan })
  set_hl("@lsp.type.variable", { fg = colors.blue })

  -- Diagnostics
  set_hl("DiagnosticError", { fg = colors.red })
  set_hl("DiagnosticWarn", { fg = colors.yellow })
  set_hl("DiagnosticInfo", { fg = colors.blue })
  set_hl("DiagnosticHint", { fg = colors.cyan })
  set_hl("DiagnosticUnderlineError", { sp = colors.red, undercurl = true })
  set_hl("DiagnosticUnderlineWarn", { sp = colors.yellow, undercurl = true })
  set_hl("DiagnosticUnderlineInfo", { sp = colors.blue, undercurl = true })
  set_hl("DiagnosticUnderlineHint", { sp = colors.cyan, undercurl = true })
  set_hl("DiagnosticVirtualTextError", { fg = colors.red, bg = colors.bgLighter })
  set_hl("DiagnosticVirtualTextWarn", { fg = colors.yellow, bg = colors.bgLighter })
  set_hl("DiagnosticVirtualTextInfo", { fg = colors.blue, bg = colors.bgLighter })
  set_hl("DiagnosticVirtualTextHint", { fg = colors.cyan, bg = colors.bgLighter })

  -- Git
  set_hl("GitSignsAdd", { fg = colors.gitAdd })
  set_hl("GitSignsChange", { fg = colors.gitChange })
  set_hl("GitSignsDelete", { fg = colors.gitDelete })
  set_hl("DiffAdd", { bg = colors.diffAddBg })
  set_hl("DiffChange", { bg = colors.bgHighlight })
  set_hl("DiffDelete", { bg = colors.diffRemoveBg })
  set_hl("DiffText", { bg = colors.selection })

  -- Telescope
  set_hl("TelescopeBorder", { fg = colors.border })
  set_hl("TelescopeNormal", { fg = colors.fg, bg = colors.bgDark })
  set_hl("TelescopeSelection", { bg = colors.selection })
  set_hl("TelescopeSelectionCaret", { fg = colors.cyan })
  set_hl("TelescopePromptBorder", { fg = colors.cyan })
  set_hl("TelescopePromptTitle", { fg = colors.cyan, bold = true })
  set_hl("TelescopeResultsTitle", { fg = colors.purple })
  set_hl("TelescopePreviewTitle", { fg = colors.green })
  set_hl("TelescopeMatching", { fg = colors.yellow, bold = true })

  -- NeoTree
  set_hl("NeoTreeNormal", { fg = colors.fg, bg = colors.bgDark })
  set_hl("NeoTreeNormalNC", { fg = colors.fg, bg = colors.bgDark })
  set_hl("NeoTreeDirectoryIcon", { fg = colors.cyan })
  set_hl("NeoTreeDirectoryName", { fg = colors.cyan })
  set_hl("NeoTreeRootName", { fg = colors.cyan, bold = true })
  set_hl("NeoTreeGitAdded", { fg = colors.gitAdd })
  set_hl("NeoTreeGitModified", { fg = colors.gitChange })
  set_hl("NeoTreeGitDeleted", { fg = colors.gitDelete })
  set_hl("NeoTreeGitUntracked", { fg = colors.yellow })
  set_hl("NeoTreeGitIgnored", { fg = colors.fgGutter })

  -- Which-key
  set_hl("WhichKey", { fg = colors.cyan })
  set_hl("WhichKeyGroup", { fg = colors.purple })
  set_hl("WhichKeyDesc", { fg = colors.fg })
  set_hl("WhichKeySeparator", { fg = colors.fgGutter })
  set_hl("WhichKeyFloat", { bg = colors.bgDark })

  -- Indent Blankline
  set_hl("IblIndent", { fg = colors.bgHighlight })
  set_hl("IblScope", { fg = colors.fgGutter })

  -- Lazy
  set_hl("LazyNormal", { fg = colors.fg, bg = colors.bgDark })
  set_hl("LazyButton", { fg = colors.fg, bg = colors.bgLighter })
  set_hl("LazyButtonActive", { fg = colors.bg, bg = colors.cyan })
  set_hl("LazyH1", { fg = colors.bg, bg = colors.cyan, bold = true })
  set_hl("LazyH2", { fg = colors.cyan, bold = true })

  -- Notify
  set_hl("NotifyERRORBorder", { fg = colors.red })
  set_hl("NotifyWARNBorder", { fg = colors.yellow })
  set_hl("NotifyINFOBorder", { fg = colors.cyan })
  set_hl("NotifyDEBUGBorder", { fg = colors.fgDark })
  set_hl("NotifyTRACEBorder", { fg = colors.purple })
  set_hl("NotifyERRORIcon", { fg = colors.red })
  set_hl("NotifyWARNIcon", { fg = colors.yellow })
  set_hl("NotifyINFOIcon", { fg = colors.cyan })
  set_hl("NotifyDEBUGIcon", { fg = colors.fgDark })
  set_hl("NotifyTRACEIcon", { fg = colors.purple })
  set_hl("NotifyERRORTitle", { fg = colors.red })
  set_hl("NotifyWARNTitle", { fg = colors.yellow })
  set_hl("NotifyINFOTitle", { fg = colors.cyan })
  set_hl("NotifyDEBUGTitle", { fg = colors.fgDark })
  set_hl("NotifyTRACETitle", { fg = colors.purple })

  -- Cmp / Blink
  set_hl("CmpItemAbbrMatch", { fg = colors.cyan, bold = true })
  set_hl("CmpItemAbbrMatchFuzzy", { fg = colors.cyan })
  set_hl("CmpItemKindVariable", { fg = colors.blue })
  set_hl("CmpItemKindFunction", { fg = colors.yellow })
  set_hl("CmpItemKindMethod", { fg = colors.yellow })
  set_hl("CmpItemKindClass", { fg = colors.cyan })
  set_hl("CmpItemKindInterface", { fg = colors.cyan })
  set_hl("CmpItemKindModule", { fg = colors.cyan })
  set_hl("CmpItemKindProperty", { fg = colors.blue })
  set_hl("CmpItemKindKeyword", { fg = colors.cyan })
  set_hl("CmpItemKindText", { fg = colors.fg })
  set_hl("CmpItemKindSnippet", { fg = colors.purple })
  set_hl("CmpItemKindCopilot", { fg = colors.green })

  -- Diffview
  set_hl("DiffviewNormal", { fg = colors.fg, bg = colors.bgDark })
  set_hl("DiffviewFilePanelTitle", { fg = colors.cyan, bold = true })
  set_hl("DiffviewFilePanelCounter", { fg = colors.purple })
  set_hl("DiffviewStatusAdded", { fg = colors.gitAdd })
  set_hl("DiffviewStatusModified", { fg = colors.gitChange })
  set_hl("DiffviewStatusDeleted", { fg = colors.gitDelete })

  -- Snacks
  set_hl("SnacksNormal", { fg = colors.fg, bg = colors.bgDark })
  set_hl("SnacksDashboardHeader", { fg = colors.cyan })
  set_hl("SnacksDashboardFooter", { fg = colors.fgDark })
  set_hl("SnacksDashboardKey", { fg = colors.yellow })
  set_hl("SnacksDashboardIcon", { fg = colors.cyan })
  set_hl("SnacksDashboardDesc", { fg = colors.fg })
end

-- Register the colorscheme
vim.api.nvim_create_user_command("CursorDark", apply_cursor_dark, {})

-- Create colors directory and file for vim colorscheme discovery
local colors_dir = vim.fn.stdpath("config") .. "/colors"
if vim.fn.isdirectory(colors_dir) == 0 then
  vim.fn.mkdir(colors_dir, "p")
end

local colorscheme_file = colors_dir .. "/cursor-dark.lua"
if vim.fn.filereadable(colorscheme_file) == 0 then
  local f = io.open(colorscheme_file, "w")
  if f then
    f:write('require("plugins.cursor-dark").apply()\n')
    f:close()
  end
end

-- Export for use
return {
  apply = apply_cursor_dark,
  colors = colors,

  -- Plugin spec for lazy.nvim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        apply_cursor_dark()
      end,
    },
  },

  -- Configure snacks explorer to show gitignored files
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },

  -- Configure neo-tree to show gitignored files
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- Show hidden/ignored files
          hide_dotfiles = false,
          hide_gitignored = false, -- Show gitignored files
          hide_hidden = false,
          never_show = {
            ".DS_Store",
            "thumbs.db",
          },
        },
      },
    },
  },
}
