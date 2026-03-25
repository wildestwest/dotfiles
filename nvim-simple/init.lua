-- =============================================================================
--  init.lua — Zed Editor (vim_mode: true) for Neovim 0.9+ (no plugins)
-- =============================================================================
--  Replicates Zed's vim mode experience using only Neovim built-in features.
--  Compatible with Neovim 0.9+. On 0.10+ you get native commenting (gc/gcc),
--  default [d/]d diagnostics, and treesitter folding automatically.
--
--  Usage: cp init.lua ~/.config/nvim/init.lua
-- =============================================================================

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  1. LEADER KEY                                                          │
-- └───────────────────────────────────────────────────────────────────────────┘

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.keymap.set('n', '<Space>', '<Nop>', { silent = true })

-- Neovim version check (0.10 adds native commenting, getregion, etc.)
local nvim_10 = vim.fn.has('nvim-0.10') == 1

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  2. CORE OPTIONS                                                        │
-- └───────────────────────────────────────────────────────────────────────────┘

local o = vim.o

-- Files & buffers
o.hidden = true
o.autoread = true
o.backup = false
o.writebackup = false
o.swapfile = false
o.confirm = true
o.undofile = true
o.undolevels = 10000

-- Timing
o.updatetime = 250
o.timeoutlen = 1000
o.ttimeoutlen = 10

-- Mouse & clipboard: on_yank only (y goes to system, d/c/x stay local)
o.mouse = 'a'

-- Misc
o.backspace = 'indent,eol,start'

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  3. APPEARANCE                                                          │
-- └───────────────────────────────────────────────────────────────────────────┘

o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = 'yes'
o.scrolloff = 8                        -- your vertical_scroll_margin
o.sidescrolloff = 8
o.colorcolumn = '80,120'               -- your wrap_guides
o.showmatch = true
o.laststatus = 2
o.showcmd = true
o.showmode = false
o.cmdheight = 1
o.shortmess = vim.o.shortmess .. 'cI'
o.termguicolors = true
o.background = 'dark'
o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkon0'  -- no blink
o.wrap = false
o.linebreak = true
o.breakindent = true
o.fillchars = 'vert:│,fold:─,eob:~'
o.list = true
o.listchars = 'tab:→ ,trail:·,extends:»,precedes:«,nbsp:␣'
o.showtabline = 2
o.splitbelow = true
o.splitright = true

-- Toggle relative numbers by mode (your toggle_relative_line_numbers: true)
vim.api.nvim_create_autocmd('InsertEnter', {
  callback = function() vim.wo.relativenumber = false end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function() vim.wo.relativenumber = true end,
})

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  4. INDENTATION                                                         │
-- └───────────────────────────────────────────────────────────────────────────┘

o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smarttab = true
o.autoindent = true
o.smartindent = true
o.shiftround = true

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'css', 'scss', 'less', 'javascript', 'typescript',
    'json', 'yaml', 'vue', 'svelte', 'jsx', 'tsx', 'ruby', 'elixir',
    'typescriptreact', 'javascriptreact' },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'make' },
  callback = function() vim.bo.expandtab = false end,
})

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  5. SEARCH                                                              │
-- └───────────────────────────────────────────────────────────────────────────┘

o.incsearch = true
o.hlsearch = true
o.ignorecase = true
o.smartcase = true

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  6. COMPLETION                                                          │
-- └───────────────────────────────────────────────────────────────────────────┘

if nvim_10 then
  o.completeopt = 'menuone,noinsert,noselect,popup'
else
  o.completeopt = 'menuone,noinsert,noselect'
end
o.pumheight = 12
o.wildmenu = true
o.wildmode = 'longest:full,full'
o.wildoptions = 'pum'
o.wildignore = '*.o,*.obj,*.pyc,*~,*.class,node_modules/**,.git/**,target/**,build/**'
o.omnifunc = 'syntaxcomplete#Complete'
o.path = vim.o.path .. ',**'

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  7. FOLDING  (treesitter-based when available, indent fallback)         │
-- └───────────────────────────────────────────────────────────────────────────┘

o.foldmethod = 'expr'
o.foldlevelstart = 99
o.foldnestmax = 10
o.foldcolumn = '1'
if nvim_10 then
  o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- Fallback for buffers without treesitter
  vim.api.nvim_create_autocmd('FileType', {
    callback = function()
      if not pcall(vim.treesitter.start) then
        vim.wo.foldmethod = 'indent'
      end
    end,
  })
else
  o.foldmethod = 'indent'
end

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  8. NETRW  (Project Panel)                                              │
-- └───────────────────────────────────────────────────────────────────────────┘

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  9. TERMINAL  (right side, 33% width)                                   │
-- └───────────────────────────────────────────────────────────────────────────┘

vim.api.nvim_create_user_command('Term', function(opts)
  local width = math.floor(vim.o.columns / 3)
  vim.cmd('vertical botright ' .. width .. 'split | terminal ' .. (opts.args or ''))
end, { nargs = '*' })

local term_buf = -1
local function toggle_terminal()
  if term_buf ~= -1 and vim.api.nvim_buf_is_valid(term_buf) then
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(w) == term_buf then
        vim.api.nvim_win_hide(w)
        return
      end
    end
  end
  local width = math.floor(vim.o.columns / 3)
  vim.cmd('vertical botright ' .. width .. 'split')
  if term_buf ~= -1 and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_set_current_buf(term_buf)
  else
    vim.cmd('terminal')
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd('startinsert')
end

-- =============================================================================
--
--  ROSÉ PINE COLORSCHEME  (inline, no plugins)
--  Palette: https://rosepinetheme.com/palette
--
-- =============================================================================

local p = {
  base           = '#191724',
  surface        = '#1f1d2e',
  overlay        = '#26233a',
  muted          = '#6e6a86',
  subtle         = '#908caa',
  text           = '#e0def4',
  love           = '#eb6f92',
  gold           = '#f6c177',
  rose           = '#ebbcba',
  pine           = '#31748f',
  foam           = '#9ccfd8',
  iris           = '#c4a7e7',
  highlight_low  = '#21202e',
  highlight_med  = '#403d52',
  highlight_high = '#524f67',
}

local function apply_rosepine()
  vim.cmd('highlight clear')
  vim.g.colors_name = 'rosepine'

  local bg = p.base
  -- Set g:rosepine_transparent = true before sourcing for transparent bg
  if vim.g.rosepine_transparent then bg = 'NONE' end

  local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

  -- UI
  hl('Normal',        { fg = p.text, bg = bg })
  hl('NormalFloat',   { fg = p.text, bg = p.surface })
  hl('FloatBorder',   { fg = p.highlight_med, bg = p.surface })
  hl('CursorLine',    { bg = p.highlight_low })
  hl('CursorColumn',  { bg = p.highlight_low })
  hl('ColorColumn',   { bg = p.highlight_low })
  hl('LineNr',        { fg = p.muted })
  hl('CursorLineNr',  { fg = p.text, bold = true })
  hl('SignColumn',    { fg = p.muted })
  hl('FoldColumn',    { fg = p.muted })
  hl('VertSplit',     { fg = p.highlight_med })
  hl('WinSeparator',  { fg = p.highlight_med })
  hl('StatusLine',    { fg = p.text, bg = p.surface })
  hl('StatusLineNC',  { fg = p.subtle, bg = p.surface })
  hl('WildMenu',     { fg = p.text, bg = p.overlay })
  hl('Folded',       { fg = p.muted, bg = p.surface, italic = true })
  hl('NonText',      { fg = p.highlight_med })
  hl('SpecialKey',   { fg = p.highlight_med })
  hl('EndOfBuffer',  { fg = p.base })
  hl('Conceal',      { fg = p.subtle })

  -- Tabs
  hl('TabLine',      { fg = p.subtle, bg = p.surface })
  hl('TabLineSel',   { fg = p.text, bg = p.overlay, bold = true })
  hl('TabLineFill',  { bg = p.base })

  -- Popup menu
  hl('Pmenu',        { fg = p.subtle, bg = p.surface })
  hl('PmenuSel',     { fg = p.text, bg = p.overlay })
  hl('PmenuSbar',    { bg = p.highlight_low })
  hl('PmenuThumb',   { bg = p.highlight_med })

  -- Search & visual
  hl('Search',       { fg = p.base, bg = p.rose })
  hl('IncSearch',    { fg = p.base, bg = p.love })
  hl('CurSearch',    { fg = p.base, bg = p.love, bold = true })
  hl('Visual',       { bg = p.highlight_med })
  hl('VisualNOS',    { bg = p.highlight_med })
  hl('MatchParen',   { fg = p.text, bg = p.highlight_med, bold = true })

  -- Messages
  hl('ErrorMsg',     { fg = p.love, bold = true })
  hl('WarningMsg',   { fg = p.gold, bold = true })
  hl('MoreMsg',      { fg = p.foam })
  hl('Question',     { fg = p.gold })
  hl('ModeMsg',      { fg = p.subtle, bold = true })

  -- Diff
  hl('DiffAdd',      { bg = p.pine })
  hl('DiffChange',   { bg = p.overlay })
  hl('DiffDelete',   { fg = p.love })
  hl('DiffText',     { bg = p.highlight_med, bold = true })

  -- Spell
  hl('SpellBad',     { sp = p.love, undercurl = true })
  hl('SpellCap',     { sp = p.iris, undercurl = true })
  hl('SpellLocal',   { sp = p.foam, undercurl = true })
  hl('SpellRare',    { sp = p.gold, undercurl = true })

  -- Syntax
  hl('Comment',      { fg = p.muted, italic = true })
  hl('Constant',     { fg = p.gold })
  hl('String',       { fg = p.gold })
  hl('Character',    { fg = p.gold })
  hl('Number',       { fg = p.gold })
  hl('Boolean',      { fg = p.rose })
  hl('Float',        { fg = p.gold })
  hl('Identifier',   { fg = p.rose })
  hl('Function',     { fg = p.foam })
  hl('Statement',    { fg = p.pine, bold = true })
  hl('Conditional',  { fg = p.pine })
  hl('Repeat',       { fg = p.pine })
  hl('Label',        { fg = p.pine })
  hl('Operator',     { fg = p.subtle })
  hl('Keyword',      { fg = p.pine })
  hl('Exception',    { fg = p.pine })
  hl('PreProc',      { fg = p.iris })
  hl('Include',      { fg = p.iris })
  hl('Define',       { fg = p.iris })
  hl('Macro',        { fg = p.iris })
  hl('PreCondit',    { fg = p.iris })
  hl('Type',         { fg = p.foam })
  hl('StorageClass', { fg = p.foam })
  hl('Structure',    { fg = p.foam })
  hl('Typedef',      { fg = p.foam })
  hl('Special',      { fg = p.rose })
  hl('SpecialChar',  { fg = p.love })
  hl('Tag',          { fg = p.foam })
  hl('Delimiter',    { fg = p.subtle })
  hl('SpecialComment', { fg = p.iris })
  hl('Debug',        { fg = p.love })
  hl('Underlined',   { fg = p.iris, underline = true })
  hl('Ignore',       { fg = p.muted })
  hl('Error',        { fg = p.love, bold = true })
  hl('Todo',         { fg = p.rose, bold = true })
  hl('Title',        { fg = p.iris, bold = true })
  hl('Directory',    { fg = p.foam, bold = true })

  -- Treesitter (Neovim 0.10 uses @capture highlight groups)
  hl('@variable',          { fg = p.text })
  hl('@variable.builtin',  { fg = p.love })
  hl('@variable.parameter',{ fg = p.iris })
  hl('@constant',          { fg = p.gold })
  hl('@constant.builtin',  { fg = p.gold })
  hl('@function',          { fg = p.foam })
  hl('@function.builtin',  { fg = p.foam })
  hl('@function.call',     { fg = p.foam })
  hl('@method',            { fg = p.foam })
  hl('@method.call',       { fg = p.foam })
  hl('@constructor',       { fg = p.foam })
  hl('@keyword',           { fg = p.pine })
  hl('@keyword.function',  { fg = p.pine })
  hl('@keyword.return',    { fg = p.pine })
  hl('@keyword.operator',  { fg = p.subtle })
  hl('@conditional',       { fg = p.pine })
  hl('@repeat',            { fg = p.pine })
  hl('@exception',         { fg = p.pine })
  hl('@include',           { fg = p.iris })
  hl('@type',              { fg = p.foam })
  hl('@type.builtin',      { fg = p.foam })
  hl('@type.definition',   { fg = p.foam })
  hl('@namespace',         { fg = p.iris })
  hl('@string',            { fg = p.gold })
  hl('@string.escape',     { fg = p.love })
  hl('@string.regex',      { fg = p.love })
  hl('@number',            { fg = p.gold })
  hl('@boolean',           { fg = p.rose })
  hl('@float',             { fg = p.gold })
  hl('@comment',           { fg = p.muted, italic = true })
  hl('@punctuation',       { fg = p.subtle })
  hl('@punctuation.bracket',{ fg = p.subtle })
  hl('@punctuation.delimiter',{ fg = p.subtle })
  hl('@operator',          { fg = p.subtle })
  hl('@property',          { fg = p.iris })
  hl('@field',             { fg = p.foam })
  hl('@parameter',         { fg = p.iris })
  hl('@attribute',         { fg = p.iris })
  hl('@tag',               { fg = p.foam })
  hl('@tag.attribute',     { fg = p.iris })
  hl('@tag.delimiter',     { fg = p.subtle })

  -- Diagnostics
  hl('DiagnosticError',           { fg = p.love })
  hl('DiagnosticWarn',            { fg = p.gold })
  hl('DiagnosticInfo',            { fg = p.foam })
  hl('DiagnosticHint',            { fg = p.iris })
  hl('DiagnosticUnderlineError',  { sp = p.love, undercurl = true })
  hl('DiagnosticUnderlineWarn',   { sp = p.gold, undercurl = true })
  hl('DiagnosticUnderlineInfo',   { sp = p.foam, undercurl = true })
  hl('DiagnosticUnderlineHint',   { sp = p.iris, undercurl = true })

  -- LSP
  hl('LspReferenceText',  { bg = p.highlight_low })
  hl('LspReferenceRead',  { bg = p.highlight_low })
  hl('LspReferenceWrite', { bg = p.highlight_med })
  hl('LspInlayHint',      { fg = p.muted, bg = p.highlight_low, italic = true })

  -- Netrw
  hl('netrwDir',       { fg = p.foam })
  hl('netrwClassify',  { fg = p.subtle })
  hl('netrwLink',      { fg = p.iris })
  hl('netrwSymLink',   { fg = p.iris, italic = true })
  hl('netrwExe',       { fg = p.love })
  hl('netrwTreeBar',   { fg = p.muted })

  -- Git signs
  hl('Added',   { fg = p.foam })
  hl('Changed', { fg = p.rose })
  hl('Removed', { fg = p.love })

  -- Quickfix
  hl('qfLineNr',   { fg = p.foam })
  hl('qfFileName',  { fg = p.iris })

  -- Terminal ANSI
  vim.g.terminal_color_0  = p.overlay
  vim.g.terminal_color_1  = p.love
  vim.g.terminal_color_2  = p.pine
  vim.g.terminal_color_3  = p.gold
  vim.g.terminal_color_4  = p.foam
  vim.g.terminal_color_5  = p.iris
  vim.g.terminal_color_6  = p.rose
  vim.g.terminal_color_7  = p.text
  vim.g.terminal_color_8  = p.muted
  vim.g.terminal_color_9  = p.love
  vim.g.terminal_color_10 = p.pine
  vim.g.terminal_color_11 = p.gold
  vim.g.terminal_color_12 = p.foam
  vim.g.terminal_color_13 = p.iris
  vim.g.terminal_color_14 = p.rose
  vim.g.terminal_color_15 = p.text
end

apply_rosepine()


-- =============================================================================
--
--  KEYBINDINGS — Zed vim_mode: true
--
-- =============================================================================

local map = vim.keymap.set

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  CLIPBOARD  (use_system_clipboard: "on_yank")                           │
-- └───────────────────────────────────────────────────────────────────────────┘

map('n', 'y',  '"+y',  { desc = 'Yank to system clipboard' })
map('v', 'y',  '"+y',  { desc = 'Yank to system clipboard' })
map('n', 'yy', '"+yy', { desc = 'Yank line to system clipboard' })
map('n', 'Y',  '"+y$', { desc = 'Yank to EOL to system clipboard' })
map('n', '<leader>v', '"+p', { desc = 'Paste from system clipboard' })
map('n', '<leader>V', '"+P', { desc = 'Paste from system clipboard above' })
map('v', '<leader>v', '"+p', { desc = 'Paste from system clipboard' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  LSP NAVIGATION  (Zed: gd, gD, gy, gA, gs, gh, g., cd)                │
-- └───────────────────────────────────────────────────────────────────────────┘
-- In Neovim 0.10, K → hover and [d/]d → diagnostics are already defaults.
-- We add Zed-specific bindings via LspAttach for buffer-local LSP maps.

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local b = { buffer = ev.buf }
    map('n', 'gd', vim.lsp.buf.definition,      vim.tbl_extend('force', b, { desc = 'Go to definition' }))
    map('n', 'gD', vim.lsp.buf.declaration,      vim.tbl_extend('force', b, { desc = 'Go to declaration' }))
    map('n', 'gy', vim.lsp.buf.type_definition,  vim.tbl_extend('force', b, { desc = 'Go to type definition' }))
    map('n', 'gI', vim.lsp.buf.implementation,   vim.tbl_extend('force', b, { desc = 'Go to implementation' }))
    map('n', 'gA', vim.lsp.buf.references,       vim.tbl_extend('force', b, { desc = 'Find all references' }))
    map('n', 'gs', vim.lsp.buf.document_symbol,  vim.tbl_extend('force', b, { desc = 'Document symbols' }))
    map('n', 'gS', vim.lsp.buf.workspace_symbol, vim.tbl_extend('force', b, { desc = 'Workspace symbols' }))
    map('n', 'gh', vim.lsp.buf.hover,            vim.tbl_extend('force', b, { desc = 'Hover info' }))
    map('n', 'g.', vim.lsp.buf.code_action,      vim.tbl_extend('force', b, { desc = 'Code actions' }))
    map('n', 'cd', vim.lsp.buf.rename,           vim.tbl_extend('force', b, { desc = 'Rename symbol' }))
    map('i', '<C-s>', vim.lsp.buf.signature_help,vim.tbl_extend('force', b, { desc = 'Signature help' }))
    -- Go to definition in split (Zed: Ctrl-W gd)
    map('n', '<C-w>gd', function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end, vim.tbl_extend('force', b, { desc = 'Definition in split' }))
  end,
})

-- Diagnostic navigation ([d/]d are default in 0.10, explicit for 0.9)
map('n', 'g]', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', 'g[', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
if not nvim_10 then
  map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
  map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
  map('n', '<C-w>d', vim.diagnostic.open_float, { desc = 'Diagnostic float' })
end

-- Configure diagnostic display (Zed-style inline hints)
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  COMMENTING  (Built-in in Neovim 0.10 — gc/gcc just work!)             │
-- └───────────────────────────────────────────────────────────────────────────┘
-- Native in 0.10+. For 0.9 we provide a Lua implementation.

if not nvim_10 then
  local comment_strings = {
    c = '//', cpp = '//', java = '//', javascript = '//', typescript = '//',
    go = '//', rust = '//', swift = '//', kotlin = '//', scala = '//',
    php = '//', css = '//', scss = '//', dart = '//', zig = '//',
    typescriptreact = '//', javascriptreact = '//', jsonc = '//',
    python = '#', ruby = '#', perl = '#', bash = '#', sh = '#', zsh = '#',
    fish = '#', yaml = '#', toml = '#', conf = '#', make = '#', cmake = '#',
    dockerfile = '#', r = '#', nim = '#', elixir = '#', julia = '#',
    vim = '"', lua = '--', haskell = '--', sql = '--',
    lisp = ';', scheme = ';', clojure = ';',
  }

  local function get_cs()
    local ft = vim.bo.filetype
    if comment_strings[ft] then return comment_strings[ft] end
    local cs = vim.bo.commentstring
    if cs and cs:match('%%s') then return cs:gsub('%s*%%s.*', '') end
    return '#'
  end

  local function toggle_comment_lines(first, last)
    local cs = get_cs()
    local esc = vim.pesc(cs)
    local pat = '^(%s*)' .. esc .. '%s?'
    local all_commented = true
    for lnum = first, last do
      local line = vim.fn.getline(lnum)
      if line:match('%S') and not line:match(pat) then
        all_commented = false
        break
      end
    end
    for lnum = first, last do
      local line = vim.fn.getline(lnum)
      if all_commented then
        vim.fn.setline(lnum, line:gsub(pat, '%1', 1))
      elseif line:match('%S') then
        vim.fn.setline(lnum, line:gsub('^(%s*)', '%1' .. cs .. ' ', 1))
      end
    end
  end

  map('n', 'gcc', function()
    toggle_comment_lines(vim.fn.line('.'), vim.fn.line('.'))
  end, { desc = 'Toggle comment' })

  _G._comment_op = function(_)
    toggle_comment_lines(vim.fn.line("'["), vim.fn.line("']"))
  end

  map('n', 'gc', function()
    vim.o.operatorfunc = 'v:lua._comment_op'
    return 'g@'
  end, { expr = true, desc = 'Comment operator' })

  map('v', 'gc', function()
    toggle_comment_lines(vim.fn.line("'<"), vim.fn.line("'>"))
  end, { desc = 'Toggle comment (visual)' })
end

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  SURROUND  (Zed built-in: ys, cs, ds, visual s/S)                      │
-- └───────────────────────────────────────────────────────────────────────────┘

local surround_pairs = {
  ['('] = { '(', ')' }, [')'] = { '(', ')' },
  ['['] = { '[', ']' }, [']'] = { '[', ']' },
  ['{'] = { '{', '}' }, ['}'] = { '{', '}' },
  ['<'] = { '<', '>' }, ['>'] = { '<', '>' },
  ["'"] = { "'", "'" }, ['"'] = { '"', '"' }, ['`'] = { '`', '`' },
}

local function get_pair(c)
  return surround_pairs[c] or { c, c }
end

-- ds{char} — delete surrounding
map('n', 'ds', function()
  local c = vim.fn.nr2char(vim.fn.getchar())
  local open, close = unpack(get_pair(c))
  if open == close then
    -- Quotes: search on current line
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local left, right = nil, nil
    for i = col, 0, -1 do
      if line:sub(i + 1, i + 1) == open then left = i; break end
    end
    for i = col + 2, #line do
      if line:sub(i, i) == close and i - 1 ~= left then right = i - 1; break end
    end
    if left and right then
      local new = line:sub(1, left) .. line:sub(left + 2, right) .. line:sub(right + 2)
      vim.api.nvim_set_current_line(new)
    end
  else
    vim.cmd('normal! va' .. c)
    vim.cmd('normal! \\<Esc>')
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    -- Delete close first so positions don't shift
    vim.api.nvim_win_set_cursor(0, { e[2], e[3] - 1 })
    vim.cmd('normal! x')
    vim.api.nvim_win_set_cursor(0, { s[2], s[3] - 1 })
    vim.cmd('normal! x')
  end
end, { desc = 'Delete surrounding' })

-- cs{old}{new} — change surrounding
map('n', 'cs', function()
  local old = vim.fn.nr2char(vim.fn.getchar())
  local new = vim.fn.nr2char(vim.fn.getchar())
  local nopen, nclose = unpack(get_pair(new))
  -- Use ds then add new surround manually
  local oopen, oclose = unpack(get_pair(old))
  if oopen == oclose then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local left, right = nil, nil
    for i = col, 0, -1 do
      if line:sub(i + 1, i + 1) == oopen then left = i + 1; break end
    end
    for i = col + 2, #line do
      if line:sub(i, i) == oclose and (i ~= left) then right = i; break end
    end
    if left and right then
      local new_line = line:sub(1, left - 1) .. nopen .. line:sub(left + 1, right - 1) .. nclose .. line:sub(right + 1)
      vim.api.nvim_set_current_line(new_line)
    end
  else
    vim.cmd('normal! va' .. old)
    vim.cmd('normal! \\<Esc>')
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    vim.api.nvim_win_set_cursor(0, { e[2], e[3] - 1 })
    vim.cmd('normal! r' .. nclose)
    vim.api.nvim_win_set_cursor(0, { s[2], s[3] - 1 })
    vim.cmd('normal! r' .. nopen)
  end
end, { desc = 'Change surrounding' })

-- ys{motion}{char} — add surrounding via operatorfunc
_G._surround_char = nil
_G._surround_add = function(type)
  local open, close = unpack(get_pair(_G._surround_char))
  local s = vim.fn.getpos("'[")
  local e = vim.fn.getpos("']")
  if type == 'line' then
    for lnum = e[2], s[2], -1 do
      local line = vim.fn.getline(lnum)
      vim.fn.setline(lnum, open .. line .. close)
    end
  else
    vim.api.nvim_win_set_cursor(0, { e[2], e[3] - 1 })
    vim.cmd('normal! a' .. close)
    vim.api.nvim_win_set_cursor(0, { s[2], s[3] - 1 })
    vim.cmd('normal! i' .. open)
  end
end

map('n', 'ys', function()
  _G._surround_char = vim.fn.nr2char(vim.fn.getchar())
  vim.o.operatorfunc = 'v:lua._surround_add'
  return 'g@'
end, { expr = true, desc = 'Add surround' })

map('n', 'yss', function()
  _G._surround_char = vim.fn.nr2char(vim.fn.getchar())
  local open, close = unpack(get_pair(_G._surround_char))
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(open .. line .. close)
end, { desc = 'Surround whole line' })

-- Visual s / S to surround
local function visual_surround()
  local c = vim.fn.nr2char(vim.fn.getchar())
  local open, close = unpack(get_pair(c))
  vim.cmd('normal! \\<Esc>')
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  vim.api.nvim_win_set_cursor(0, { e[2], e[3] - 1 })
  vim.cmd('normal! a' .. close)
  vim.api.nvim_win_set_cursor(0, { s[2], s[3] - 1 })
  vim.cmd('normal! i' .. open)
end

map('v', 'S', visual_surround, { desc = 'Surround selection' })
map('v', 's', visual_surround, { desc = 'Surround selection' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  EXCHANGE  (Zed built-in: cx{motion}, cxx, cxc)                        │
-- └───────────────────────────────────────────────────────────────────────────┘

local exchange_state = {}
-- Helper to get text between two positions (0.9 compat, no vim.fn.getregion)
local function get_text_range(s, e)
  local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
  if #lines == 0 then return {} end
  if #lines == 1 then
    lines[1] = lines[1]:sub(s[3], e[3])
  else
    lines[1] = lines[1]:sub(s[3])
    lines[#lines] = lines[#lines]:sub(1, e[3])
  end
  return lines
end

_G._exchange_op = function(type)
  local s = vim.fn.getpos("'[")
  local e = vim.fn.getpos("']")
  if vim.tbl_isempty(exchange_state) then
    exchange_state = { s = s, e = e, type = type }
    vim.api.nvim_echo({ { 'Exchange: select second region with cx{motion}', 'Comment' } }, false, {})
  else
    local r1_s, r1_e = exchange_state.s, exchange_state.e
    local r2_s, r2_e = s, e
    local t1 = get_text_range(r1_s, r1_e)
    local t2 = get_text_range(r2_s, r2_e)
    -- Replace second region first so positions stay valid
    vim.api.nvim_win_set_cursor(0, { r2_s[2], r2_s[3] - 1 })
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { r2_e[2], r2_e[3] - 1 })
    vim.cmd('normal! "xc' .. table.concat(t1, '\n'))
    vim.api.nvim_win_set_cursor(0, { r1_s[2], r1_s[3] - 1 })
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { r1_e[2], r1_e[3] - 1 })
    vim.cmd('normal! "xc' .. table.concat(t2, '\n'))
    exchange_state = {}
  end
end

map('n', 'cx', function()
  vim.o.operatorfunc = 'v:lua._exchange_op'
  return 'g@'
end, { expr = true, desc = 'Exchange' })

map('n', 'cxx', function()
  vim.o.operatorfunc = 'v:lua._exchange_op'
  return 'g@_'
end, { expr = true, desc = 'Exchange line' })

map('n', 'cxc', function()
  exchange_state = {}
  vim.api.nvim_echo({ { 'Exchange cancelled', 'Comment' } }, false, {})
end, { desc = 'Cancel exchange' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  TREE-SITTER MOTIONS  (Zed: ]m, [m, ]], [[, ]/, [/)                   │
-- └───────────────────────────────────────────────────────────────────────────┘
-- Regex-based since we can't rely on treesitter queries being installed.

local function search_motion(pattern, flags)
  return function() vim.fn.search(pattern, flags) end
end

map('n', ']m', search_motion([[\v^\s*(pub\s+)?(fn|function|def|func)\s]], 'W'),  { desc = 'Next function' })
map('n', '[m', search_motion([[\v^\s*(pub\s+)?(fn|function|def|func)\s]], 'bW'), { desc = 'Prev function' })
map('n', ']M', search_motion([[\v^\s*\}]], 'W'),  { desc = 'Next function end' })
map('n', '[M', search_motion([[\v^\s*\}]], 'bW'), { desc = 'Prev function end' })
map('n', ']]', search_motion([[\v^\s*(pub\s+)?(class|struct|enum|impl|module|interface|trait)\s]], 'W'),  { desc = 'Next class' })
map('n', '[[', search_motion([[\v^\s*(pub\s+)?(class|struct|enum|impl|module|interface|trait)\s]], 'bW'), { desc = 'Prev class' })
map('n', ']/', search_motion([[\v(\/\/|#|--)\s]], 'W'),  { desc = 'Next comment' })
map('n', '[/', search_motion([[\v(\/\/|#|--)\s]], 'bW'), { desc = 'Prev comment' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  TEXT OBJECTS  (Zed: af/if, ac/ic, ii/ai/aI, ia/aa)                    │
-- └───────────────────────────────────────────────────────────────────────────┘

-- ii / ai / aI — indent text objects
local function select_indent(include_above, include_below)
  return function()
    local indent = vim.fn.indent(vim.fn.line('.'))
    if indent == 0 then
      vim.cmd('normal! VG')
      return
    end
    local start_line = vim.fn.line('.')
    local end_line = vim.fn.line('.')
    while start_line > 1 and vim.fn.indent(start_line - 1) >= indent do
      start_line = start_line - 1
    end
    while end_line < vim.fn.line('$') and vim.fn.indent(end_line + 1) >= indent do
      end_line = end_line + 1
    end
    if include_above and start_line > 1 then start_line = start_line - 1 end
    if include_below and end_line < vim.fn.line('$') then end_line = end_line + 1 end
    vim.cmd('normal! ' .. start_line .. 'GV' .. end_line .. 'G')
  end
end

for _, mode in ipairs({ 'v', 'o' }) do
  map(mode, 'ii', select_indent(false, false), { desc = 'Inside indent' })
  map(mode, 'ai', select_indent(true, false),  { desc = 'Around indent (above)' })
  map(mode, 'aI', select_indent(true, true),   { desc = 'Around indent (both)' })
end

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  TERMINAL                                                               │
-- └───────────────────────────────────────────────────────────────────────────┘

map('n', '<C-`>',  toggle_terminal, { desc = 'Toggle terminal', silent = true })
map('t', '<C-`>',  function() vim.cmd('hide') end, { desc = 'Hide terminal', silent = true })
map('t', '<Esc>',  '<C-\\><C-n>', { desc = 'Terminal normal mode' })
map('t', '<C-w>h', '<C-\\><C-n><C-w>h', { desc = 'Pane left from terminal' })
map('t', '<C-w>j', '<C-\\><C-n><C-w>j', { desc = 'Pane down from terminal' })
map('t', '<C-w>k', '<C-\\><C-n><C-w>k', { desc = 'Pane up from terminal' })
map('t', '<C-w>l', '<C-\\><C-n><C-w>l', { desc = 'Pane right from terminal' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  PANE NAVIGATION  (Ctrl-h/j/k/l and Ctrl-arrows)                       │
-- └───────────────────────────────────────────────────────────────────────────┘

map('n', '<C-h>',     '<C-w>h', { desc = 'Pane left' })
map('n', '<C-j>',     '<C-w>j', { desc = 'Pane down' })
map('n', '<C-k>',     '<C-w>k', { desc = 'Pane up' })
map('n', '<C-l>',     '<C-w>l', { desc = 'Pane right' })
map('n', '<C-Left>',  '<C-w>h', { desc = 'Pane left' })
map('n', '<C-Right>', '<C-w>l', { desc = 'Pane right' })
map('n', '<C-Up>',    '<C-w>k', { desc = 'Pane up' })
map('n', '<C-Down>',  '<C-w>j', { desc = 'Pane down' })
map('t', '<C-Left>',  '<C-\\><C-n><C-w>h')
map('t', '<C-Right>', '<C-\\><C-n><C-w>l')
map('t', '<C-Up>',    '<C-\\><C-n><C-w>k')
map('t', '<C-Down>',  '<C-\\><C-n><C-w>j')

map('n', '<C-w>c', '<cmd>close<cr>', { desc = 'Close pane' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  CENTERED SCROLLING                                                     │
-- └───────────────────────────────────────────────────────────────────────────┘

map('n', 'n',     'nzzzv', { desc = 'Next match centered' })
map('n', 'N',     'Nzzzv', { desc = 'Prev match centered' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down centered' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up centered' })
map('n', '<C-o>', '<C-o>zz', { desc = 'Jump back centered' })
map('n', '<C-i>', '<C-i>zz', { desc = 'Jump forward centered' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  YANK HIGHLIGHT  (native Neovim! highlight_on_yank_duration: 400)       │
-- └───────────────────────────────────────────────────────────────────────────┘

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ timeout = 400 }) end,
})

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  AUTO-BEHAVIORS                                                         │
-- └───────────────────────────────────────────────────────────────────────────┘

-- Auto-save on focus lost
vim.api.nvim_create_autocmd('FocusLost', {
  command = 'silent! wall',
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Clear search highlight on Escape
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- ┌───────────────────────────────────────────────────────────────────────────┐
-- │  YOUR CUSTOM BINDINGS  (from your Zed keymap.json)                      │
-- └───────────────────────────────────────────────────────────────────────────┘

-- Leader mappings
map('n', '<leader><leader>', ':find ', { desc = 'Find file' })
map('n', '<leader>p',  '<cmd>browse oldfiles<cr>',     { desc = 'Recent files' })
map('n', '<leader>e',  '<cmd>Lexplore<cr>',             { desc = 'Toggle explorer' })
map('n', '<leader>t',  ':!',                             { desc = 'Run shell command' })
map('n', '<leader>lg', '<cmd>tab terminal lazygit<cr>', { desc = 'Lazygit' })
map('n', '<leader>k',  '<cmd>tab terminal k9s<cr>',    { desc = 'k9s' })
map('n', '<leader>ckd', '<cmd>!deploy<cr>',             { desc = 'Deploy' })
map('n', '<leader>cpv', '<cmd>!python -m venv .venv<cr>', { desc = 'Python venv' })
map('n', '<leader>cpt', '<cmd>!pytest<cr>',             { desc = 'Pytest' })

-- Harpoon-style global marks
map('n', '<A-S-a>', 'mA', { desc = 'Set mark A' })
map('n', '<A-S-e>', 'mE', { desc = 'Set mark E' })
map('n', '<A-S-i>', 'mI', { desc = 'Set mark I' })
map('n', '<A-S-c>', 'mC', { desc = 'Set mark C' })
map('n', '<A-a>',   '`A', { desc = 'Jump to mark A' })
map('n', '<A-e>',   '`E', { desc = 'Jump to mark E' })
map('n', '<A-i>',   '`I', { desc = 'Jump to mark I' })
map('n', '<A-c>',   '`C', { desc = 'Jump to mark C' })

-- g/ project-wide search
map('n', 'g/', ':vimgrep //j **/*<Left><Left><Left><Left><Left><Left>', { desc = 'Project search' })


-- =============================================================================
--  QUICK REFERENCE  (Compatible with Neovim 0.9+, best on 0.10+)
-- =============================================================================
--
--  Built-in (native in 0.10, shimmed for 0.9):
--    gc/gcc         Commenting (native 0.10, Lua fallback 0.9)
--    [d / ]d        Prev/next diagnostic (native 0.10, mapped 0.9)
--    K              Hover (native when LSP active)
--    gx             Open URL under cursor
--    <C-w>d         Open diagnostic float
--
--  LSP (active when server attached):
--    gd             Definition              gD             Declaration
--    gy             Type definition          gI             Implementation
--    gA             References               gs             Document symbols
--    gS             Workspace symbols        gh             Hover info
--    g.             Code actions             cd             Rename
--    <C-s>          Signature help (insert)  <C-w>gd        Def in split
--
--  Surround:
--    ys{m}{c}       Add surround             yss{c}         Surround line
--    cs{o}{n}       Change surround          ds{c}          Delete surround
--    s/S            Surround (visual)
--
--  Exchange:
--    cx{m}          Mark for exchange         cxx            Exchange line
--    cxc            Cancel exchange
--
--  Navigation:
--    ]m / [m        Next/prev function       ]] / [[        Next/prev class
--    ]/ / [/        Next/prev comment         g] / g[        Next/prev diag
--    g/             Project search
--
--  Text objects:
--    ii / ai / aI   Indent levels
--
--  Your bindings:
--    <Space><Space>  Find file               <Space>p       Recent files
--    <Space>e        Explorer                <Space>t       Shell command
--    <Space>lg       Lazygit                 <Space>k       k9s
--    <Space>cpt      Pytest                  <Space>cpv     Venv
--    Alt-Shift-A/E/I/C  Set harpoon mark    Alt-A/E/I/C    Jump to mark
--    <Space>v/V      Paste from clipboard
--    Ctrl-`          Toggle terminal (right, 33%)
-- =============================================================================
