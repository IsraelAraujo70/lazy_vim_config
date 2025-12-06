-- Cursor IDE Dark Theme for Neovim
-- A dark theme inspired by Cursor IDE's color scheme

local M = {}

M.colors = {
  -- Base colors
  bg = "#1a1a1a",
  bg_dark = "#151515",
  bg_lighter = "#252525",
  bg_highlight = "#2a2a2a",
  bg_visual = "#3a3a3a",

  -- Foreground
  fg = "#d4d4d4",
  fg_dark = "#a0a0a0",
  fg_gutter = "#4a4a4a",

  -- Syntax colors
  cyan = "#4fc1ff", -- keywords (if, for, def, try, except, import, from)
  blue = "#9cdcfe", -- variables
  yellow = "#dcdcaa", -- functions/methods
  orange = "#ce9178", -- strings (alternative)
  pink = "#c586c0", -- strings
  purple = "#b48ead", -- constants/numbers
  green = "#6a9955", -- comments
  red = "#f44747", -- errors
  magenta = "#d16d9e", -- special

  -- UI colors
  border = "#3a3a3a",
  selection = "#264f78",
  cursor_line = "#2a2a2a",
  line_nr = "#5a5a5a",
  line_nr_active = "#c6c6c6",

  -- Git colors
  git_add = "#89d185",
  git_change = "#e2c08d",
  git_delete = "#c74e39",

  -- Diagnostics
  error = "#f44747",
  warning = "#cca700",
  info = "#3794ff",
  hint = "#89d185",
}

function M.setup()
  local colors = M.colors

  -- Reset highlights
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "cursor-dark"

  local highlights = {
    -- Editor
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.bg_dark },
    FloatBorder = { fg = colors.border, bg = colors.bg_dark },
    ColorColumn = { bg = colors.bg_highlight },
    Cursor = { fg = colors.bg, bg = colors.fg },
    CursorColumn = { bg = colors.cursor_line },
    CursorLine = { bg = colors.cursor_line },
    CursorLineNr = { fg = colors.line_nr_active, bold = true },
    LineNr = { fg = colors.line_nr },
    SignColumn = { fg = colors.fg_gutter, bg = colors.bg },
    VertSplit = { fg = colors.border },
    WinSeparator = { fg = colors.border },
    Folded = { fg = colors.fg_dark, bg = colors.bg_highlight },
    FoldColumn = { fg = colors.fg_gutter },
    NonText = { fg = colors.fg_gutter },
    SpecialKey = { fg = colors.fg_gutter },
    EndOfBuffer = { fg = colors.bg },

    -- Search
    Search = { fg = colors.bg, bg = colors.yellow },
    IncSearch = { fg = colors.bg, bg = colors.orange },
    CurSearch = { fg = colors.bg, bg = colors.orange },
    Substitute = { fg = colors.bg, bg = colors.red },

    -- Visual
    Visual = { bg = colors.bg_visual },
    VisualNOS = { bg = colors.bg_visual },

    -- Pmenu (completion menu)
    Pmenu = { fg = colors.fg, bg = colors.bg_dark },
    PmenuSel = { fg = colors.fg, bg = colors.selection },
    PmenuSbar = { bg = colors.bg_highlight },
    PmenuThumb = { bg = colors.fg_gutter },

    -- Messages
    ErrorMsg = { fg = colors.error },
    WarningMsg = { fg = colors.warning },
    ModeMsg = { fg = colors.fg, bold = true },
    MoreMsg = { fg = colors.cyan },
    Question = { fg = colors.cyan },

    -- Tabs
    TabLine = { fg = colors.fg_dark, bg = colors.bg_dark },
    TabLineFill = { bg = colors.bg_dark },
    TabLineSel = { fg = colors.fg, bg = colors.bg },

    -- Status line
    StatusLine = { fg = colors.fg, bg = colors.bg_dark },
    StatusLineNC = { fg = colors.fg_dark, bg = colors.bg_dark },

    -- Diff
    DiffAdd = { bg = "#2d4a2d" },
    DiffChange = { bg = "#4a4a2d" },
    DiffDelete = { bg = "#4a2d2d" },
    DiffText = { bg = "#5a5a2d" },

    -- Spell
    SpellBad = { undercurl = true, sp = colors.error },
    SpellCap = { undercurl = true, sp = colors.warning },
    SpellLocal = { undercurl = true, sp = colors.info },
    SpellRare = { undercurl = true, sp = colors.hint },

    -- Syntax highlighting
    Comment = { fg = colors.green, italic = true },
    Constant = { fg = colors.purple },
    String = { fg = colors.pink },
    Character = { fg = colors.pink },
    Number = { fg = colors.purple },
    Boolean = { fg = colors.purple },
    Float = { fg = colors.purple },

    Identifier = { fg = colors.blue },
    Function = { fg = colors.yellow },

    Statement = { fg = colors.cyan },
    Conditional = { fg = colors.cyan },
    Repeat = { fg = colors.cyan },
    Label = { fg = colors.cyan },
    Operator = { fg = colors.fg },
    Keyword = { fg = colors.cyan },
    Exception = { fg = colors.cyan },

    PreProc = { fg = colors.cyan },
    Include = { fg = colors.cyan },
    Define = { fg = colors.cyan },
    Macro = { fg = colors.cyan },
    PreCondit = { fg = colors.cyan },

    Type = { fg = colors.cyan },
    StorageClass = { fg = colors.cyan },
    Structure = { fg = colors.cyan },
    Typedef = { fg = colors.cyan },

    Special = { fg = colors.orange },
    SpecialChar = { fg = colors.orange },
    Tag = { fg = colors.cyan },
    Delimiter = { fg = colors.fg },
    SpecialComment = { fg = colors.green },
    Debug = { fg = colors.orange },

    Underlined = { underline = true },
    Bold = { bold = true },
    Italic = { italic = true },

    Error = { fg = colors.error },
    Todo = { fg = colors.bg, bg = colors.yellow, bold = true },

    -- Treesitter highlights
    ["@comment"] = { link = "Comment" },
    ["@error"] = { fg = colors.error },
    ["@none"] = { fg = colors.fg },
    ["@preproc"] = { fg = colors.cyan },
    ["@define"] = { fg = colors.cyan },
    ["@operator"] = { fg = colors.fg },

    -- Punctuation
    ["@punctuation.delimiter"] = { fg = colors.fg },
    ["@punctuation.bracket"] = { fg = colors.fg },
    ["@punctuation.special"] = { fg = colors.cyan },

    -- Literals
    ["@string"] = { fg = colors.pink },
    ["@string.regex"] = { fg = colors.orange },
    ["@string.escape"] = { fg = colors.orange },
    ["@string.special"] = { fg = colors.orange },
    ["@character"] = { fg = colors.pink },
    ["@character.special"] = { fg = colors.orange },
    ["@boolean"] = { fg = colors.purple },
    ["@number"] = { fg = colors.purple },
    ["@float"] = { fg = colors.purple },

    -- Functions
    ["@function"] = { fg = colors.yellow },
    ["@function.builtin"] = { fg = colors.yellow },
    ["@function.call"] = { fg = colors.yellow },
    ["@function.macro"] = { fg = colors.yellow },
    ["@method"] = { fg = colors.yellow },
    ["@method.call"] = { fg = colors.yellow },
    ["@constructor"] = { fg = colors.yellow },
    ["@parameter"] = { fg = colors.blue },

    -- Keywords
    ["@keyword"] = { fg = colors.cyan },
    ["@keyword.function"] = { fg = colors.cyan },
    ["@keyword.operator"] = { fg = colors.cyan },
    ["@keyword.return"] = { fg = colors.cyan },
    ["@conditional"] = { fg = colors.cyan },
    ["@repeat"] = { fg = colors.cyan },
    ["@debug"] = { fg = colors.orange },
    ["@label"] = { fg = colors.cyan },
    ["@include"] = { fg = colors.cyan },
    ["@exception"] = { fg = colors.cyan },

    -- Types
    ["@type"] = { fg = colors.cyan },
    ["@type.builtin"] = { fg = colors.cyan },
    ["@type.definition"] = { fg = colors.cyan },
    ["@type.qualifier"] = { fg = colors.cyan },
    ["@storageclass"] = { fg = colors.cyan },
    ["@attribute"] = { fg = colors.cyan },
    ["@field"] = { fg = colors.blue },
    ["@property"] = { fg = colors.blue },

    -- Identifiers
    ["@variable"] = { fg = colors.blue },
    ["@variable.builtin"] = { fg = colors.blue },
    ["@constant"] = { fg = colors.purple },
    ["@constant.builtin"] = { fg = colors.purple },
    ["@constant.macro"] = { fg = colors.purple },
    ["@namespace"] = { fg = colors.fg },
    ["@symbol"] = { fg = colors.purple },

    -- Text
    ["@text"] = { fg = colors.fg },
    ["@text.strong"] = { bold = true },
    ["@text.emphasis"] = { italic = true },
    ["@text.underline"] = { underline = true },
    ["@text.strike"] = { strikethrough = true },
    ["@text.title"] = { fg = colors.yellow, bold = true },
    ["@text.literal"] = { fg = colors.pink },
    ["@text.uri"] = { fg = colors.cyan, underline = true },
    ["@text.math"] = { fg = colors.purple },
    ["@text.environment"] = { fg = colors.cyan },
    ["@text.environment.name"] = { fg = colors.yellow },
    ["@text.reference"] = { fg = colors.blue },
    ["@text.todo"] = { link = "Todo" },
    ["@text.note"] = { fg = colors.bg, bg = colors.info },
    ["@text.warning"] = { fg = colors.bg, bg = colors.warning },
    ["@text.danger"] = { fg = colors.bg, bg = colors.error },

    -- Tags
    ["@tag"] = { fg = colors.cyan },
    ["@tag.attribute"] = { fg = colors.blue },
    ["@tag.delimiter"] = { fg = colors.fg },

    -- LSP Semantic Tokens
    ["@lsp.type.class"] = { fg = colors.cyan },
    ["@lsp.type.decorator"] = { fg = colors.yellow },
    ["@lsp.type.enum"] = { fg = colors.cyan },
    ["@lsp.type.enumMember"] = { fg = colors.purple },
    ["@lsp.type.function"] = { fg = colors.yellow },
    ["@lsp.type.interface"] = { fg = colors.cyan },
    ["@lsp.type.macro"] = { fg = colors.yellow },
    ["@lsp.type.method"] = { fg = colors.yellow },
    ["@lsp.type.namespace"] = { fg = colors.fg },
    ["@lsp.type.parameter"] = { fg = colors.blue },
    ["@lsp.type.property"] = { fg = colors.blue },
    ["@lsp.type.struct"] = { fg = colors.cyan },
    ["@lsp.type.type"] = { fg = colors.cyan },
    ["@lsp.type.typeParameter"] = { fg = colors.cyan },
    ["@lsp.type.variable"] = { fg = colors.blue },

    -- Diagnostics
    DiagnosticError = { fg = colors.error },
    DiagnosticWarn = { fg = colors.warning },
    DiagnosticInfo = { fg = colors.info },
    DiagnosticHint = { fg = colors.hint },
    DiagnosticUnderlineError = { undercurl = true, sp = colors.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = colors.warning },
    DiagnosticUnderlineInfo = { undercurl = true, sp = colors.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = colors.hint },
    DiagnosticVirtualTextError = { fg = colors.error, bg = "#2d1f1f" },
    DiagnosticVirtualTextWarn = { fg = colors.warning, bg = "#2d2a1f" },
    DiagnosticVirtualTextInfo = { fg = colors.info, bg = "#1f2d3d" },
    DiagnosticVirtualTextHint = { fg = colors.hint, bg = "#1f2d1f" },

    -- Git
    GitSignsAdd = { fg = colors.git_add },
    GitSignsChange = { fg = colors.git_change },
    GitSignsDelete = { fg = colors.git_delete },

    -- Telescope
    TelescopeNormal = { fg = colors.fg, bg = colors.bg_dark },
    TelescopeBorder = { fg = colors.border, bg = colors.bg_dark },
    TelescopePromptNormal = { fg = colors.fg, bg = colors.bg_lighter },
    TelescopePromptBorder = { fg = colors.bg_lighter, bg = colors.bg_lighter },
    TelescopePromptTitle = { fg = colors.bg, bg = colors.cyan },
    TelescopePreviewTitle = { fg = colors.bg, bg = colors.green },
    TelescopeResultsTitle = { fg = colors.bg, bg = colors.purple },
    TelescopeSelection = { fg = colors.fg, bg = colors.selection },
    TelescopeMatching = { fg = colors.yellow, bold = true },

    -- NeoTree
    NeoTreeNormal = { fg = colors.fg, bg = colors.bg_dark },
    NeoTreeNormalNC = { fg = colors.fg, bg = colors.bg_dark },
    NeoTreeDirectoryName = { fg = colors.fg },
    NeoTreeDirectoryIcon = { fg = colors.cyan },
    NeoTreeRootName = { fg = colors.cyan, bold = true },
    NeoTreeFileName = { fg = colors.fg },
    NeoTreeFileIcon = { fg = colors.fg },
    NeoTreeFileNameOpened = { fg = colors.cyan },
    NeoTreeIndentMarker = { fg = colors.fg_gutter },
    NeoTreeGitAdded = { fg = colors.git_add },
    NeoTreeGitConflict = { fg = colors.error },
    NeoTreeGitDeleted = { fg = colors.git_delete },
    NeoTreeGitIgnored = { fg = colors.fg_gutter },
    NeoTreeGitModified = { fg = colors.git_change },
    NeoTreeGitUntracked = { fg = colors.git_add },
    NeoTreeTitleBar = { fg = colors.bg, bg = colors.cyan },

    -- Indent Blankline
    IblIndent = { fg = colors.bg_highlight },
    IblScope = { fg = colors.fg_gutter },

    -- Which Key
    WhichKey = { fg = colors.cyan },
    WhichKeyGroup = { fg = colors.purple },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeySeparator = { fg = colors.fg_gutter },
    WhichKeyFloat = { bg = colors.bg_dark },
    WhichKeyBorder = { fg = colors.border, bg = colors.bg_dark },

    -- Noice
    NoiceCmdline = { fg = colors.fg, bg = colors.bg_dark },
    NoiceCmdlinePopup = { fg = colors.fg, bg = colors.bg_dark },
    NoiceCmdlinePopupBorder = { fg = colors.border },
    NoiceCmdlineIcon = { fg = colors.cyan },

    -- Cmp
    CmpItemAbbr = { fg = colors.fg },
    CmpItemAbbrDeprecated = { fg = colors.fg_gutter, strikethrough = true },
    CmpItemAbbrMatch = { fg = colors.yellow, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = colors.yellow, bold = true },
    CmpItemKind = { fg = colors.purple },
    CmpItemMenu = { fg = colors.fg_dark },
    CmpItemKindClass = { fg = colors.cyan },
    CmpItemKindColor = { fg = colors.pink },
    CmpItemKindConstant = { fg = colors.purple },
    CmpItemKindConstructor = { fg = colors.yellow },
    CmpItemKindEnum = { fg = colors.cyan },
    CmpItemKindEnumMember = { fg = colors.purple },
    CmpItemKindEvent = { fg = colors.orange },
    CmpItemKindField = { fg = colors.blue },
    CmpItemKindFile = { fg = colors.fg },
    CmpItemKindFolder = { fg = colors.cyan },
    CmpItemKindFunction = { fg = colors.yellow },
    CmpItemKindInterface = { fg = colors.cyan },
    CmpItemKindKeyword = { fg = colors.cyan },
    CmpItemKindMethod = { fg = colors.yellow },
    CmpItemKindModule = { fg = colors.fg },
    CmpItemKindOperator = { fg = colors.fg },
    CmpItemKindProperty = { fg = colors.blue },
    CmpItemKindReference = { fg = colors.blue },
    CmpItemKindSnippet = { fg = colors.orange },
    CmpItemKindStruct = { fg = colors.cyan },
    CmpItemKindText = { fg = colors.fg },
    CmpItemKindTypeParameter = { fg = colors.cyan },
    CmpItemKindUnit = { fg = colors.purple },
    CmpItemKindValue = { fg = colors.purple },
    CmpItemKindVariable = { fg = colors.blue },

    -- Bufferline
    BufferLineFill = { bg = colors.bg_dark },
    BufferLineBackground = { fg = colors.fg_dark, bg = colors.bg_dark },
    BufferLineBuffer = { fg = colors.fg_dark, bg = colors.bg_dark },
    BufferLineBufferSelected = { fg = colors.fg, bg = colors.bg, bold = true },
    BufferLineBufferVisible = { fg = colors.fg_dark, bg = colors.bg_dark },
    BufferLineCloseButton = { fg = colors.fg_gutter, bg = colors.bg_dark },
    BufferLineCloseButtonSelected = { fg = colors.error, bg = colors.bg },
    BufferLineCloseButtonVisible = { fg = colors.fg_gutter, bg = colors.bg_dark },
    BufferLineIndicatorSelected = { fg = colors.cyan, bg = colors.bg },
    BufferLineModified = { fg = colors.git_change },
    BufferLineModifiedSelected = { fg = colors.git_change, bg = colors.bg },
    BufferLineModifiedVisible = { fg = colors.git_change, bg = colors.bg_dark },
    BufferLineSeparator = { fg = colors.bg_dark, bg = colors.bg_dark },
    BufferLineSeparatorSelected = { fg = colors.bg_dark, bg = colors.bg },
    BufferLineSeparatorVisible = { fg = colors.bg_dark, bg = colors.bg_dark },
    BufferLineTab = { fg = colors.fg_dark, bg = colors.bg_dark },
    BufferLineTabSelected = { fg = colors.fg, bg = colors.bg },
    BufferLineTabClose = { fg = colors.error, bg = colors.bg_dark },

    -- Lualine
    lualine_a_normal = { fg = colors.bg, bg = colors.cyan, bold = true },
    lualine_b_normal = { fg = colors.fg, bg = colors.bg_lighter },
    lualine_c_normal = { fg = colors.fg_dark, bg = colors.bg_dark },

    -- Lazy
    LazyNormal = { fg = colors.fg, bg = colors.bg_dark },
    LazyButton = { fg = colors.fg, bg = colors.bg_highlight },
    LazyButtonActive = { fg = colors.bg, bg = colors.cyan },
    LazyH1 = { fg = colors.bg, bg = colors.cyan, bold = true },
    LazyH2 = { fg = colors.cyan, bold = true },
    LazySpecial = { fg = colors.purple },
    LazyCommit = { fg = colors.green },
    LazyReasonPlugin = { fg = colors.yellow },
    LazyReasonFt = { fg = colors.cyan },
    LazyReasonCmd = { fg = colors.orange },
    LazyReasonEvent = { fg = colors.purple },
    LazyReasonKeys = { fg = colors.pink },

    -- Mason
    MasonNormal = { fg = colors.fg, bg = colors.bg_dark },
    MasonHeader = { fg = colors.bg, bg = colors.cyan, bold = true },
    MasonHeaderSecondary = { fg = colors.bg, bg = colors.purple, bold = true },
    MasonHighlight = { fg = colors.cyan },
    MasonHighlightBlock = { fg = colors.bg, bg = colors.cyan },
    MasonHighlightBlockBold = { fg = colors.bg, bg = colors.cyan, bold = true },
    MasonMuted = { fg = colors.fg_gutter },
    MasonMutedBlock = { fg = colors.fg, bg = colors.bg_highlight },

    -- Dashboard
    DashboardHeader = { fg = colors.cyan },
    DashboardCenter = { fg = colors.fg },
    DashboardShortcut = { fg = colors.purple },
    DashboardFooter = { fg = colors.fg_dark, italic = true },
  }

  -- Apply highlights
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

return M
