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

-- Keymaps =====================================================================

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "H", "<cmd>bprev<CR>")
vim.keymap.set("n", "L", "<cmd>bnext<CR>")

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

-- Autocmds ====================================================================

vim.api.nvim_create_autocmd("TermClose", {
	callback = function(ev)
		if vim.bo[ev.buf].buftype == "terminal" then
			vim.api.nvim_buf_delete(ev.buf, { force = true })
		end
	end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
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

-- Terminal & Command Runner ===================================================

local term_bufnr = nil

local function open_right_split()
	local width = math.floor(vim.o.columns / 3)
	vim.cmd("rightbelow vsplit")
	vim.cmd("vertical resize " .. width)
end

local toggle_right_terminal = function()
	if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
		local term_win = vim.fn.bufwinid(term_bufnr)
		if term_win ~= -1 then
			vim.api.nvim_win_close(term_win, false)
		else
			open_right_split()
			vim.api.nvim_set_current_buf(term_bufnr)
			vim.cmd("startinsert")
		end
	else
		open_right_split()
		vim.cmd("terminal")
		term_bufnr = vim.api.nvim_get_current_buf()
		vim.bo[term_bufnr].buflisted = false
		vim.cmd("startinsert")
	end
end
vim.keymap.set({ "n", "t", "i" }, "<C-t>", toggle_right_terminal, { desc = "Terminal (vertical)" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

local command_output_win = nil

local run_command_in_bottom_terminal = function(command)
	local height = math.floor(vim.o.lines / 4)
	local current_win = vim.api.nvim_get_current_win()

	vim.cmd("botright split")
	vim.cmd("resize " .. height)
	vim.cmd("terminal " .. command)

	local buf = vim.api.nvim_get_current_buf()
	command_output_win = vim.api.nvim_get_current_win()

	vim.bo[buf].buflisted = false
	vim.cmd("normal! G")
	vim.api.nvim_set_current_win(current_win)
end

local dismiss_command_output = function()
	if command_output_win and vim.api.nvim_win_is_valid(command_output_win) then
		vim.api.nvim_win_close(command_output_win, false)
		command_output_win = nil
	end
end

local activate_venv = vim.o.shell:find("fish") and "source .venv/bin/activate.fish" or "source .venv/bin/activate"

vim.keymap.set("n", "<leader>cpv", function()
	run_command_in_bottom_terminal(
		"rm -rf .venv && python3 -m venv .venv && " .. activate_venv .. " && pip install -r requirements.txt -r requirements-testing.txt"
	)
end, { desc = "[C]ommand [P]ython clean [V]env and install" })
vim.keymap.set("n", "<leader>cpt", function()
	run_command_in_bottom_terminal(activate_venv .. " && python -m pytest")
end, { desc = "[C]ommand [P]ython run [T]ests" })
vim.keymap.set("n", "<leader>ckd", function()
	run_command_in_bottom_terminal(
		"helm upgrade -i wes$(basename \"$(pwd)\" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) printf substr($i,1,1)}') helm-charts/$(basename \"$(pwd)\" | tr '_' '-') -f intvalues.yaml --set image.tag=$(git rev-parse --abbrev-ref HEAD | tr '/' '_')"
	)
end, { desc = "[C]ommand [K]ubernetes [D]eploy" })
vim.keymap.set("n", "<leader>cd", dismiss_command_output, { desc = "[C]lose [D]ismiss command output" })

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>cr", function()
	for _, client in ipairs(vim.lsp.get_clients()) do
		client:stop()
	end
	vim.cmd("edit")
end, { desc = "[C]ommand LSP [R]estart" })

-- Plugins (vim.pack) ==========================================================

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
vim.pack.add({ "https://github.com/folke/snacks.nvim" })
vim.pack.add({ "https://github.com/rose-pine/neovim" })
vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })
vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
vim.pack.add({ "https://github.com/saghen/blink.cmp" })

-- Build blink.cmp's Rust fuzzy matcher (replaces lazy.nvim's build step)
local function build_blink_cmp()
	local paths = vim.api.nvim_get_runtime_file("lua/blink/cmp/init.lua", false)
	if #paths == 0 then return end
	local root = vim.fn.fnamemodify(paths[1], ":h:h:h:h")
	vim.notify("[blink.cmp] building fuzzy matcher (requires cargo)...")
	vim.system({ "cargo", "build", "--release" }, { cwd = root }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("[blink.cmp] build complete — restart Neovim to activate")
			else
				vim.notify("[blink.cmp] build failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
			end
		end)
	end)
end

do
	local paths = vim.api.nvim_get_runtime_file("lua/blink/cmp/init.lua", false)
	if #paths > 0 then
		local root = vim.fn.fnamemodify(paths[1], ":h:h:h:h")
		local lib = root .. "/target/release/libblink_cmp_fuzzy."
			.. (jit.os == "OSX" and "dylib" or "so")
		if vim.fn.filereadable(lib) == 0 then
			build_blink_cmp()
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "PackChanged",
	callback = function(ev)
		if ev.data.spec.name == "blink.cmp" and ev.data.kind == "update" then
			build_blink_cmp()
		end
	end,
	desc = "Rebuild blink.cmp after update",
})
vim.pack.add({ "https://github.com/L3MON4D3/LuaSnip" })
vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" })
vim.pack.add({ "https://github.com/folke/flash.nvim" })

-- Colorscheme =================================================================

require("rose-pine").setup()
vim.cmd.colorscheme("rose-pine-main")

-- Mini modules ================================================================

require("mini.extra").setup()

require("mini.ai").setup({
		n_lines = 500,
		-- 'mini.ai' can be extended with custom textobjects from treesitter
		custom_textobjects = {
			F = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			D = require("mini.ai").gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
			B = require("mini.extra").gen_ai_spec.buffer(),
			C = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			L = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
		},
})

require("mini.surround").setup()
require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })
require("mini.notify").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup()
require("mini.trailspace").setup()
require("mini.diff").setup()
require("mini.cmdline").setup()
require("mini.misc").setup()
require("mini.icons").setup()
require("mini.files").setup({ windows = { preview = true } })
vim.keymap.set("n", "<leader>e", "<Cmd>lua MiniFiles.open()<CR>", { desc = "Explore Directory" })

MiniMisc.setup_auto_root()
MiniIcons.mock_nvim_web_devicons()
MiniMisc.setup_restore_cursor()
MiniMisc.setup_termbg_sync()

-- mini.clue (replaces which-key) ----------------------------------------------

local miniclue = require("mini.clue")
miniclue.setup({
	clues = {
		{ mode = "n", keys = "<Leader>c", desc = "+Command" },
		{ mode = "n", keys = "<Leader>cp", desc = "+Command Python" },
		{ mode = "n", keys = "<Leader>ck", desc = "+Command Kubernetes" },
		{ mode = { "n", "v" }, keys = "<Leader>h", desc = "+Git Hunk" },
		{ mode = "n", keys = "<Leader>s", desc = "+Search" },
		{ mode = "n", keys = "<Leader>sg", desc = "+Search Git" },
		{ mode = "n", keys = "<Leader>t", desc = "+Toggle" },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows({ submode_resize = true }),
		miniclue.gen_clues.z(),
	},
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "z" },
		{ mode = { "n", "x" }, keys = "[" },
		{ mode = { "n", "x" }, keys = "]" },
	},
	window = { delay = 200 },
})

-- mini.visits (replaces grapple) ----------------------------------------------

require("mini.visits").setup()

-- Named slot labels (a, e, i, c) — each slot holds one file, like grapple
local slot_labels = { a = "slot_a", e = "slot_e", i = "slot_i", c = "slot_c" }

for key, label in pairs(slot_labels) do
	-- Alt+Shift to TAG a file with a slot label (clears old file first)
	vim.keymap.set("n", "<A-" .. key:upper() .. ">", function()
		local cwd = vim.fn.getcwd()
		local existing = MiniVisits.list_paths(cwd, { filter = label })
		for _, path in ipairs(existing) do
			MiniVisits.remove_label(label, path, cwd)
		end
		MiniVisits.add_label(label)
		vim.notify("Tagged file with slot: " .. key)
	end, { desc = "Tag file as slot " .. key })

	-- Alt to NAVIGATE to a file with a slot label
	vim.keymap.set("n", "<A-" .. key .. ">", function()
		local paths = MiniVisits.list_paths(vim.fn.getcwd(), { filter = label })
		if #paths > 0 then
			vim.cmd("edit " .. vim.fn.fnameescape(paths[1]))
		else
			vim.notify("No file tagged with slot: " .. key, vim.log.levels.WARN)
		end
	end, { desc = "Go to slot " .. key })
end

-- Snacks picker  ============================================

require("snacks").setup({
	picker = { enabled = true },
})

vim.keymap.set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>sp", function() Snacks.picker.pickers() end, { desc = "[S]earch [P]ickers" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>s/", function() Snacks.picker.grep() end, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", function() Snacks.picker.resume() end, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", function() Snacks.picker.recent() end, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader>sb", function() Snacks.picker.buffers() end, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>/", function() Snacks.picker.lines() end, { desc = "[/] Search in current buffer" })
vim.keymap.set("n", "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "[S]earch [N]eovim files" })
vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "[S]earch [S]ymbols in current buffer" })
vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "[S]earch [W]orkspace symbols" })
vim.keymap.set("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "[S]earch [U]ndo history" })
vim.keymap.set("n", "<leader>sgd", function() Snacks.picker.git_status() end, { desc = "Search [G]it [D]iff" })
vim.keymap.set("n", "<leader>sgl", function() Snacks.picker.git_log() end, { desc = "Search [G]it [L]og" })
vim.keymap.set("n", "<leader>sm", function() Snacks.picker.man() end, { desc = "Search [M]an" })

-- Treesitter ==================================================================

local languages = {
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
	"python",
	"fish",
}

local missing = vim.tbl_filter(function(lang)
	return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
end, languages)
if #missing > 0 then
	require("nvim-treesitter").install(missing)
end

-- Enable treesitter highlighting for all configured languages
local filetypes = {}
for _, lang in ipairs(languages) do
	for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
		table.insert(filetypes, ft)
	end
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function(ev)
		vim.treesitter.start(ev.buf)
	end,
	desc = "Start tree-sitter",
})

-- LSP =========================================================================

require("mason").setup()

-- Declarative auto-install: all tools installed on new machines
local ensure_installed = {
	"ty",
	"bash-language-server",
	"ansible-language-server",
	"dockerfile-language-server",
	"docker-compose-language-service",
	"helm-ls",
	"marksman",
	"typescript-language-server",
	"yaml-language-server",
	"lua-language-server",
}
local registry = require("mason-registry")
registry.refresh(function()
	for _, name in ipairs(ensure_installed) do
		local ok, pkg = pcall(registry.get_package, name)
		if ok and not pkg:is_installed() then
			vim.notify("[mason] installing " .. name)
			pkg:install()
		end
	end
end)

-- Remove Neovim's default global LSP keymaps that conflict with ours
for _, key in ipairs({ "grr", "grn", "gri", "grt", "grx" }) do
	pcall(vim.keymap.del, "n", key)
end
pcall(vim.keymap.del, { "n", "x" }, "gra")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local buf = event.buf
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = buf, desc = "LSP: " .. desc })
		end
		map("gn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("ga", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
		map("gi", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
		map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("gt", function() Snacks.picker.lsp_type_definitions() end, "[G]oto [T]ype Definition")
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
		end, "[T]oggle Inlay [H]ints")

		MiniClue.ensure_buf_triggers()
	end,
})

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
			return diagnostic.message
		end,
	},
})

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

vim.lsp.enable({
	"ty",
	"bashls",
	"ansiblels",
	"dockerls",
	"docker_compose_language_service",
	"helm_ls",
	"marksman",
	"ts_ls",
	"yamlls",
	"lua_ls",
})

-- Completion ==================================================================

require("luasnip.loaders.from_vscode").lazy_load()

--- @type blink.cmp.Config
require("blink.cmp").setup({
	keymap = {
		preset = "default",
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
	},

	sources = {
		default = { "lsp", "snippets", "path" },
	},

	snippets = { preset = "luasnip" },

	fuzzy = { implementation = "prefer_rust_with_warning" },

	signature = { enabled = true },
})

-- Formatting (commented out) ==================================================
-- vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
-- require("conform").setup({
-- 	formatters_by_ft = {
-- 		rust = { "rustfmt" },
-- 		javascript = { "prettier" },
-- 		typescript = { "prettier" },
-- 		javascriptreact = { "prettier" },
-- 		typescriptreact = { "prettier" },
-- 		bash = { "shfmt" },
-- 		sh = { "shfmt" },
-- 		yaml = { "prettier" },
-- 		helm = {},
-- 		markdown = { "prettier" },
-- 		ansible = { "prettier" },
-- 		python = { "isort", "black" },
-- 	},
-- 	format_on_save = {
-- 		timeout_ms = 5000,
-- 		lsp_fallback = true,
-- 	},
-- })
-- vim.keymap.set("n", "<leader>f", function()
-- 	require("conform").format()
-- end, { desc = "run format on current buffer" })

-- Linting (commented out) =====================================================
-- vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })
-- local lint = require("lint")
-- lint.linters_by_ft = {
-- 	python = { "flake8" },
-- 	javascript = { "eslint" },
-- 	typescript = { "eslint" },
-- 	javascriptreact = { "eslint" },
-- 	typescriptreact = { "eslint" },
-- 	bash = { "shellcheck" },
-- 	sh = { "shellcheck" },
-- 	yaml = { "yamllint" },
-- 	dockerfile = { "hadolint" },
-- 	markdown = { "markdownlint" },
-- 	ansible = { "ansible_lint" },
-- }
-- local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
-- 	group = lint_augroup,
-- 	callback = function()
-- 		lint.try_lint()
-- 	end,
-- })

-- Flash =======================================================================

require("flash").setup({
	labels = "hatesincludowykmgp",
	search = {
		mode = function(str)
			return "\\<" .. str
		end,
	},
	label = {
		uppercase = false,
	},
})
vim.keymap.set({ "n", "x", "o" }, "<BS>", function()
	require("flash").jump()
end, { desc = "Flash" })

-- VimEnter ====================================================================

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argv(0) == "" then
			Snacks.picker.smart()
		end
	end,
})

-- vim: ts=2 sts=2 sw=2 et
