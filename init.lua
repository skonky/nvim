local utils = require("utils")
local set_opts = utils.set_opts
local set_globals = utils.set_globals
local set_keymap = utils.set_keymap

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- ============================================================================
-- OPTIONS
-- ============================================================================

set_opts({
	termguicolors = true,
	number = false,
	relativenumber = false,
	signcolumn = "yes",
	cursorline = true,
	scrolloff = 10,
	splitright = true,
	splitbelow = true,
	hlsearch = false,
	ignorecase = true,
	smartcase = true,
	inccommand = "split",
	swapfile = false,
	mouse = "a",
	breakindent = true,
	undofile = true,
	confirm = true,
	updatetime = 250,
	timeoutlen = 300,
	list = true,
	listchars = { tab = "» ", trail = "·", nbsp = "␣" },
	foldenable = true,
	foldlevelstart = 99,
	foldlevel = 99,
	foldmethod = "indent",
	wildmenu = true,
	wildmode = "longest:full,full",
})

set_globals({
	mapleader = " ",
	maplocalleader = " ",
	neovide_theme = "auto",
	neovide_padding_left = 50,
	neovide_padding_right = 50,
	neovide_padding_top = 50,
	neovide_padding_bottom = 50,
	adwaita_darker = true,
})

vim.schedule(function()
	vim.opt.clipboard:append("unnamedplus")
end)

-- ============================================================================
-- KEYMAPS: EDITING
-- ============================================================================

set_keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
set_keymap("n", "<C-s>", ":write<CR>", { desc = "Save" })
set_keymap("n", "Y", "y$", { desc = "Yank to end of line" })
set_keymap("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
set_keymap("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
set_keymap({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

set_keymap("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set_keymap("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
set_keymap("v", "<", "<gv", { desc = "Indent left" })
set_keymap("v", ">", ">gv", { desc = "Indent right" })

-- ============================================================================
-- KEYMAPS: NAVIGATION
-- ============================================================================

set_keymap("n", "<C-d>", "<C-d>zz", { desc = "Page down (centered)" })
set_keymap("n", "<C-u>", "<C-u>zz", { desc = "Page up (centered)" })
set_keymap("n", "n", "nzzzv", { desc = "Next match (centered)" })
set_keymap("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

set_keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Window left" })
set_keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Window right" })
set_keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Window down" })
set_keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Window up" })

set_keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
set_keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
set_keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

set_keymap("n", "-", ":foldclose<CR>", { desc = "Close fold" })
set_keymap("n", "+", ":foldopen<CR>", { desc = "Open fold" })

-- ============================================================================
-- KEYMAPS: LSP
-- ============================================================================

set_keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
set_keymap("n", "gD", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
set_keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
set_keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ============================================================================
-- KEYMAPS: TOOLS
-- ============================================================================

set_keymap("n", "<leader>e", ":Oil<CR>", { desc = "File explorer" })
set_keymap("n", "<leader>gg", ":Neogit<CR>", { desc = "Neogit" })
set_keymap("n", "<leader>pp", "<cmd>NeovimProjectDiscover<CR>", { desc = "Projects" })

set_keymap("n", "<leader>sf", ":Pick files<CR>", { desc = "Find files" })
set_keymap("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Live grep" })
set_keymap("n", "<leader>/", ":Pick buf_lines<CR>", { desc = "Buffer lines" })
set_keymap("n", "<leader><leader>", ":Pick buffers<CR>", { desc = "Buffers" })
set_keymap("n", "<leader>gs", ":Pick git_hunks<CR>", { desc = "Git hunks" })
set_keymap("n", "<leader>km", ":Pick keymaps<CR>", { desc = "Keymaps" })
set_keymap("n", "<D-x>", ":Pick commands<CR>", { desc = "Commands" })

set_keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertical" })
set_keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontal" })
set_keymap("n", "<leader>td", ":tabclose<CR>", { desc = "Close tab" })

set_keymap("n", "<leader>n", function()
	local enabled = vim.opt.number:get() or vim.opt.relativenumber:get()
	vim.opt.number = not enabled
	vim.opt.relativenumber = not enabled
end, { desc = "Toggle line numbers" })

set_keymap("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy file path" })

set_keymap("n", "<leader>so", ":update<CR> :source<CR>", { desc = "Source config" })

set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal" })

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	"https://github.com/rktjmp/hotpot.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/NMAC427/guess-indent.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/coffebar/neovim-project",
	"https://github.com/Shatur/neovim-session-manager",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/NeogitOrg/neogit",
	"https://github.com/mistweaverco/kulala.nvim",
	"https://github.com/github/copilot.vim",
})

-- ============================================================================
-- PLUGIN CONFIG
-- ============================================================================

require("mini.icons").setup()
require("mini.comment").setup()
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.extra").setup()
require("mini.completion").setup()

require("mini.pick").setup({
	mappings = {
		send_to_qflist = {
			char = "<C-q>",
			func = function()
				local MiniPick = require("mini.pick")
				local matches = MiniPick.get_picker_matches()
				MiniPick.default_choose_marked(matches.all)
				MiniPick.stop()
			end,
		},
	},
	window = {
		config = function()
			local height = math.floor(vim.o.lines * 0.9)
			local width = math.floor(vim.o.columns * 0.9)
			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor((vim.o.lines - height) / 2),
				col = math.floor((vim.o.columns - width) / 2),
			}
		end,
	},
})

require("oil").setup({
	columns = { "icon" },
})

require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
	},
})

require("guess-indent").setup({
	auto_cmd = true,
})

require("neovim-project").setup({
	projects = {
		"~/.config",
		"~/.config/nvim",
		"~/.config/kitty/",
		"~/scripts/kulala",
		"~/Code/adhese/cloud",
		"~/Code/adhese/mcb-frontend.git",
		"~/Code/adhese/gambit-design-system.git",
		"~/Code/adhese/sdk_typescript",
		"~/Code/adhese/playwright-tests",
	},
	picker = { type = "fzf-lua" },
})

require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	ensure_installed = {
		"lua",
		"markdown",
		"markdown_inline",
		"typescript",
		"javascript",
		"graphql",
		"yaml",
		"json",
		"css",
		"html",
		"fennel",
		"clojure",
	},
})

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		set_keymap("n", "]g", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
		set_keymap("n", "[g", gs.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
	end,
})

require("neogit")

require("kulala").setup({
	ft = { "http" },
	global_keymaps = {
		["Send request"] = {
			"<C-c><C-c>",
			function()
				require("kulala").run()
			end,
			{ mode = { "n", "v" }, desc = "Send request" },
		},
		["Send all requests"] = {
			"<leader>Ra",
			function()
				require("kulala").run_all()
			end,
			{ mode = { "n", "v" }, ft = "http" },
		},
		["Replay the last request"] = {
			"<leader>Rr",
			function()
				require("kulala").replay()
			end,
			{ ft = { "http", "rest" } },
		},
		["Find request"] = false,
	},
})

-- ============================================================================
-- LSP
-- ============================================================================

vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss", "eslint", "fennel_language_server" })

-- ============================================================================
-- FILETYPE & COLORSCHEME
-- ============================================================================

vim.filetype.add({ extension = { http = "http" } })
vim.cmd("colorscheme habamax")

-- ts_ls writes to /tmp which can cause issues on some systems
vim.env.TMPDIR = vim.fn.expand("~/.cache/nvim/tmp")
vim.fn.mkdir(vim.env.TMPDIR, "p")
