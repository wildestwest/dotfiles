vim.g.mapleader = " "

vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 15
vim.o.confirm = true

-- Get rid of swapfile warning
vim.o.swapfile = false

-- Ruler
vim.o.colorcolumn = "90"

-- Auto-reload files changed on disk
vim.o.autoread = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- move highlighted text with capital J K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Highlighted text" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Highlighted text" })

-- keep cursor where it is when J
vim.keymap.set("n", "J", "mzJ`z")

-- Cursor in middle when page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Cursor in middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Keep current paste buffer
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste maintain buffer" })

-- paste sys clipboard
vim.keymap.set("n", "<leader>P", [["+p]], { desc = "Paste sys clipboard" })

-- to yank into system clipboard vs vim clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "copy to sys" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "copy to vim" })

-- delete to void buffer
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void buffer" })

-- format file
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "run format on current buffer" })

vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    -- Get the buffer that triggered the event
    local buf_nr = vim.api.nvim_get_current_buf()
    -- Get the type of buffer (e.g., 'terminal', 'help')
    local buf_type = vim.api.nvim_buf_get_option(buf_nr, "buftype")

    -- Check if it's a terminal buffer before deleting
    if buf_type == "terminal" then
      vim.cmd("bdelete! " .. buf_nr)
    end
  end
})
local term_bufnr = nil

local toggle_right_terminal = function()
  -- Check if terminal buffer exists and is valid
  if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
    local term_win = vim.fn.bufwinid(term_bufnr)
    if term_win ~= -1 then
      -- Terminal is visible, close it
      vim.api.nvim_win_close(term_win, false)
    else
      -- Terminal exists but not visible, show it
      local width = math.floor(vim.o.columns / 3)
      vim.cmd('rightbelow vsplit')
      vim.cmd('vertical resize ' .. width)
      vim.api.nvim_set_current_buf(term_bufnr)
      vim.cmd('startinsert')
    end
  else
    -- Create new terminal
    local width = math.floor(vim.o.columns / 3)
    vim.cmd('rightbelow vsplit')
    vim.cmd('vertical resize ' .. width)
    vim.cmd('terminal')
    term_bufnr = vim.api.nvim_get_current_buf()
    -- Mark buffer as unlisted so it doesn't show in buffer list
    vim.bo[term_bufnr].buflisted = false
    vim.cmd('startinsert')
  end
end
vim.keymap.set({ "n", "t", "i" }, "<C-.>", toggle_right_terminal, { desc = "Terminal (vertical)" })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- hotkeyed commands

local command_output_bufnr = nil
local command_output_win = nil

local run_command_in_bottom_terminal = function(command)
  local height = math.floor(vim.o.lines / 4)
  local current_win = vim.api.nvim_get_current_win()

  -- Open split at the bottom
  vim.cmd('botright split')
  vim.cmd('resize ' .. height)

  -- Open terminal and run command
  vim.cmd('terminal ' .. command)

  command_output_bufnr = vim.api.nvim_get_current_buf()
  command_output_win = vim.api.nvim_get_current_win()

  -- Mark as unlisted so it doesn't show in buffer list
  vim.bo[command_output_bufnr].buflisted = false

  -- Scroll to bottom once so it auto-scrolls
  vim.cmd('normal! G')

  -- Return focus to original window
  vim.api.nvim_set_current_win(current_win)
end

local dismiss_command_output = function()
  if command_output_win and vim.api.nvim_win_is_valid(command_output_win) then
    vim.api.nvim_win_close(command_output_win, false)
    command_output_win = nil
  end
end

-- specific Python venv setup command
vim.keymap.set('n', '<leader>cpv', function()
  run_command_in_bottom_terminal(
    'rm -rf .venv && python3 -m venv .venv && source .venv/bin/activate.fish && pip install -r requirements.txt -r requirements-testing.txt')
end, { desc = '[C]ommand [P]ython clean [V]env and install' })
vim.keymap.set("n", "<leader>cpt",
  function() run_command_in_bottom_terminal("source .venv/bin/activate.fish && python -m pytest") end,
  { desc = "[C]ommand [P]ython run [T]ests" })
vim.keymap.set('n', '<leader>cd', dismiss_command_output, { desc = '[C]lose [D]ismiss command output' })

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      require("snacks.picker").smart()
    end
  end,
})

vim.filetype.add({
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.txt"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml.gotmpl"] = "helm",
    ["values.*%.yaml"] = "yaml.helm-values",
  },
  filename = {
    ["Chart.yaml"] = "yaml.helm-chartfile",
  },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    opts = {
      preset = "helix",
      delay = 200,
      icons = {
        mappings = vim.g.have_nerd_font,
      },
      spec = {
        { "<leader>c",  group = "[C]ommand" },
        { "<leader>cp", group = "[C]ommand [P]ython" },
        { "<leader>h",  group = "Git [H]unk",        mode = { "n", "v" } },
        { "<leader>l",  group = "[L]azy" },
        { "<leader>s",  group = "[S]earch" },
        { "<leader>t",  group = "[T]oggle" },
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = {
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },

    -- Two important keymaps to use while in a picker are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    ---@type snacks.Config
    opts = {
      picker = {},
    },

    -- See `:help snacks-pickers-sources`
    keys = {
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "[S]earch [H]elp",
      },
      {
        "<leader>sk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "[S]earch [K]eymaps",
      },
      {
        "<leader><leader>",
        function()
          Snacks.picker.smart()
        end,
        desc = "[S]earch [F]iles",
      },
      {
        "<leader>sp",
        function()
          Snacks.picker.pickers()
        end,
        desc = "[S]earch [Pickers]",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.grep_word()
        end,
        desc = "[S]earch current [W]ord",
        mode = { "n", "x" },
      },
      {
        "<leader>s/",
        function()
          Snacks.picker.grep()
        end,
        desc = "[S]earch by [G]rep",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "[S]earch [D]iagnostics",
      },
      {
        "<leader>sr",
        function()
          Snacks.picker.resume()
        end,
        desc = "[S]earch [R]esume",
      },
      {
        "<leader>s.",
        function()
          Snacks.picker.recent()
        end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      {
        "<leader>sb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "[S]earch [B]uffers",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.lines({})
        end,
        desc = "[/] Fuzzily search in current buffer",
      },
      -- Shortcut for searching your Neovim configuration files
      {
        "<leader>sn",
        function()
          Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "[S]earch [N]eovim files",
      },
      {
        "<leader>ss",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "[S]earch [S]ymblos in current buffer",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "[S]earch [W]orkspace symbols",
      },
      {
        "<leader>su",
        function()
          Snacks.picker.undo()
        end,
        desc = "Search [U]ndo history",
      },
      {
        "<leader>sgd",
        function()
          Snacks.picker.git_diff()
        end,
        desc = "Search [G]it [D]iff",
      },
      {
        "<leader>sgl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Search [Git] [L]og",
      },
      {
        "<leader>sm",
        function()
          Snacks.picker.man()
        end,
        desc = "Search [M]an",
      }
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
         end
          map("gn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("ga", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
          map("gr", require("snacks").picker.lsp_references, "[G]oto [R]eferences")
          map("gi", require("snacks").picker.lsp_implementations, "[G]oto [I]mplementation")
          map("gd", require("snacks").picker.lsp_definitions, "[G]oto [D]efinition")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("gt", require("snacks").picker.lsp_type_definitions, "[G]oto [T]ype Definition")
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "[T]oggle Inlay [H]ints")
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          severity = vim.diagnostic.severity.ERROR,
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        basedpyright = {},
        ansiblels = {},
        dockerls = {},
        docker_compose_language_service = {},
        helm_ls = {},
        marksman = {},
        rust_analyzer = { enabled = false },
        ts_ls = {},
        yamlls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
  { -- Autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      -- Snippet Engine
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
      "folke/lazydev.nvim",
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        preset = "default",
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { "lsp", "snippets", "path", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },

      snippets = { preset = "luasnip" },

      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  {
    "rose-pine/neovim",
    priority = 1000,
    config = function()
      -- enable builtin undotree
      vim.cmd('packadd nvim.undotree')
      require("rose-pine").setup()
      vim.cmd.colorscheme("rose-pine-main")
    end,
  },
  {
    "nvim-mini/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({
        n_lines = 500,
        -- 'mini.ai' can be extended with custom textobjects from treesitter
        custom_textobjects = {
          F = require('mini.extra').gen_ai_spec.buffer(),
          f = require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
          h = require('mini.ai').gen_spec.treesitter({ a = '@function.call.outer', i = '@function.call.inner' }),
          C = require('mini.ai').gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
          L = require('mini.ai').gen_spec.treesitter({ a = '@loop.outer', i = '@loop.inner' }),
          D = require('mini.ai').gen_spec.treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
        },

      })
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })
      require("mini.pairs").setup()
      require("mini.notify").setup()
      require("mini.extra").setup()
      require("mini.cursorword").setup()
      require("mini.indentscope").setup()
      require("mini.trailspace").setup()
      require("mini.diff").setup()
    end,
  },
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "rust",
        "ron",
        "ninja",
        "rst",
        "nu",
        "dockerfile",
        "helm",
        "regex",
        "yaml",
        "toml",
        "typescript",
        "sway",
        "requirements",
        "nix",
        "javascript",
        "helm",
        "fish"
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
  },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "hatesinclumg",
      search = {
        mode = function(str)
          return "\\<" .. str
        end,
      },
      label = {
        uppercase = false,
      },
      jump = {
        autojump = true,
      },
      treesitter = {
        labels = 'hatesincludowymgp'
      }
    },
    -- stylua: ignore
    keys = {
      { "<BS>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" }
    },
  },
  {
    "cbochs/grapple.nvim",
    opts = {
      scope = "git_branch",
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = {
      { "<leader>m", "<cmd>Grapple toggle<cr>",          desc = "Grapple toggle tag" },
      { "<leader>M", "<cmd>Grapple toggle_tags<cr>",     desc = "Grapple open tags window" },
      { "<A-a>",     "<cmd>Grapple select index=1<cr>",  desc = "Grapple Select first tag" },
      { "<A-e>",     "<cmd>Grapple select index=2<cr>",  desc = "Grapple Select second tag" },
      { "<A-i>",     "<cmd>Grapple select index=3<cr>",  desc = "Grapple Select third tag" },
      { "<A-c>",     "<cmd>Grapple select index=4<cr>",  desc = "Grapple Select fourth tag" },
      { "<A-h>",     "<cmd>Grapple select index=5scr>",  desc = "Grapple Select fith tag" },
      { "<A-t>",     "<cmd>Grapple select index=6<cr>",  desc = "Grapple Select sixth tag" },
      { "<A-s>",     "<cmd>Grapple select index=7<cr>",  desc = "Grapple Select seventh tag" },
      { "<A-n>",     "<cmd>Grapple select index=8<cr>",  desc = "Grapple Select eighth tag" },
      { "<A-]>",     "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
      { "<A-[>",     "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      completions = {
        -- Settings for blink.cmp completions source
        blink = { enabled = true },
        -- Settings for in-process language server completions
        lsp = { enabled = true },
    },
    },
  },
})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
