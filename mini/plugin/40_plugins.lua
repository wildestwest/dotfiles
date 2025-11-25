-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use `main` branch since `master` branch is frozen, yet still default
		checkout = "main",
		-- Update tree-sitter parser after plugin is updated
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		-- Same logic as for 'nvim-treesitter'
		checkout = "main",
	})
	require("nvim-treesitter").setup({
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
			"fish",
		},
		auto_install = true,
	})
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
later(function()
	add("neovim/nvim-lspconfig")
	add("williamboman/mason.nvim")
	add("williamboman/mason-lspconfig.nvim")
	add("WhoIsSethDaniel/mason-tool-installer.nvim")

	-- Mason setup
	require("mason").setup()

	local servers = {
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
		"stylua",
		-- Formatters
		"isort",
		"rustfmt",
		"goimports",
		"prettier",
		"shfmt",
		-- Linters
		"flake8",
		"golangci-lint",
		"eslint_d",
		"shellcheck",
		"yamllint",
		"hadolint",
		"markdownlint",
		"ansible-lint",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	require("mason-lspconfig").setup({
		ensure_installed = {},
		automatic_installation = false,
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end)

now_if_args(function()
	-- Configure Helm file detection
	-- Detect Helm chart files and set filetype to 'helm' instead of 'yaml'
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = {
			"*/templates/*.yaml",
			"*/templates/*.tpl",
			"*/templates/*.yml",
			"**/templates/*.yaml",
			"**/templates/*.tpl",
			"**/templates/*.yml",
		},
		callback = function()
			vim.bo.filetype = "helm"
		end,
		desc = "Set filetype to helm for Helm chart templates",
	})

	-- Also detect by checking for Chart.yaml in parent directories
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = { "*.yaml", "*.yml" },
		callback = function()
			local path = vim.fn.expand("%:p")
			if path:match("/templates/") and vim.fn.findfile("Chart.yaml", vim.fn.expand("%:p:h") .. ";") ~= "" then
				vim.bo.filetype = "helm"
			end
		end,
		desc = "Detect Helm charts by Chart.yaml presence",
	})
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
	add("stevearc/conform.nvim")

	-- See also:
	-- - `:h Conform`
	-- - `:h conform-options`
	-- - `:h conform-formatters`
	require("conform").setup({
		-- Map of filetype to formatters
		-- Make sure that necessary CLI tool is available
		formatters_by_ft = {
			rust = { "rustfmt" },
			go = { "goimports", "gofmt" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			yaml = { "prettier" },
			helm = {}, -- Helm LSP handles formatting
			markdown = { "prettier" },
			ansible = { "prettier" },
		},
		-- Format on save (optional, remove if you prefer manual formatting)
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})
end)

later(function()
	add("MeanderingProgrammer/render-markdown.nvim")
	require("render-markdown").setup({
		lsp = { enabled = true },
	})
end)

-- Linting ====================================================================

-- Linters analyze code for potential errors and style issues.
-- The 'mfussenegger/nvim-lint' plugin provides easy linter integration.
later(function()
	add("mfussenegger/nvim-lint")

	local lint = require("lint")

	-- Configure linters by filetype
	lint.linters_by_ft = {
		python = { "flake8" },
		go = { "golangcilint" },
		javascript = { "eslint" },
		typescript = { "eslint" },
		javascriptreact = { "eslint" },
		typescriptreact = { "eslint" },
		bash = { "shellcheck" },
		sh = { "shellcheck" },
		yaml = { "yamllint" },
		dockerfile = { "hadolint" },
		markdown = { "markdownlint" },
		ansible = { "ansible_lint" },
	}

	-- Auto-lint on save and text change
	local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			lint.try_lint()
		end,
	})
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
	add("rafamadriz/friendly-snippets")
end)

add("rose-pine/neovim")
vim.cmd("color rose-pine-main")
-- end)
