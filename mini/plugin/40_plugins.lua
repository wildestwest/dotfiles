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

	-- Define languages which will have parsers installed and auto enabled
	local languages = {
		-- These are already pre-installed with Neovim. Used as an example.
		"lua",
		"vimdoc",
		"markdown",
		-- Additional languages for LSP support
		"python",
		"rust",
		"go",
		"typescript",
		"javascript",
		"tsx",
		"bash",
		"yaml",
		"dockerfile",
		-- Add here more languages with which you want to use tree-sitter
		-- To see available languages:
		-- - Execute `:=require('nvim-treesitter').get_available()`
		-- - Visit 'SUPPORTED_LANGUAGES.md' file at
		--   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
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

	-- Setup Mason for managing LSP servers, formatters, and linters
	require("mason").setup()

	-- Setup mason-lspconfig to automatically install LSP servers
	require("mason-lspconfig").setup({
		-- Automatically install these language servers
		ensure_installed = {
			"basedpyright", -- Python
			"rust_analyzer", -- Rust
			"gopls", -- Go
			"ts_ls", -- TypeScript/JavaScript
			"bashls", -- Bash
			"yamlls", -- YAML
			"helm_ls", -- Helm
			"dockerls", -- Dockerfile
			"marksman", -- Markdown
			"ansiblels", -- Ansible
		},
		automatic_installation = true,
	})

	-- Automatically install formatters and linters
	require("mason-tool-installer").setup({
		ensure_installed = {
			-- Formatters
			"isort",
			"ruff",
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
		},
		auto_update = false,
		run_on_start = true,
	})

	-- Enable language servers using modern Neovim LSP API
	-- This uses the default configs provided by nvim-lspconfig
	vim.lsp.enable({
		"basedpyright",
		"rust_analyzer",
		"gopls",
		"ts_ls",
		"bashls",
		"yamlls",
		"helm_ls",
		"dockerls",
		"marksman",
		"ansiblels",
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
			python = { "isort", "ruff" },
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

-- Honorable mentions =========================================================

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- MiniDeps.now(function()
--   -- Install only those that you need
--   add('sainnhe/everforest')
--   add('Shatur/neovim-ayu')
--   add('ellisonleao/gruvbox.nvim')
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)
