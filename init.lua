local utils = require("utils")
local set_opts = utils.set_opts
local set_globals = utils.set_globals
local set_keymap = utils.set_keymap
local biome = require("biome")
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- ============================================================================
-- GLOBALS & OPTIONS
-- ============================================================================

set_globals({
	mapleader = " ",
	maplocalleader = " ",
	neovide_padding_left = 20,
	neovide_padding_right = 20,
	neovide_padding_top = 20,
	neovide_padding_bottom = 20,
})

set_opts({
	termguicolors = true,
	number = false,
	relativenumber = false,
	signcolumn = "yes",
	cursorline = true,
	scrolloff = 10,
	splitright = true,
	splitbelow = true,
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
	-- list = true, -- show/hide whitespace characters
	listchars = { tab = "» ", trail = "·", nbsp = "␣" },
	foldenable = true,
	foldlevelstart = 99,
	foldlevel = 99,
	foldmethod = "expr",
	foldexpr = "v:lua.vim.treesitter.foldexpr()",
	wildmenu = true,
	wildmode = "longest:full,full",
	tabstop = 2,
	shiftwidth = 2,
	expandtab = false,
	laststatus = 3,
	completeopt = "menuone,noselect,popup",
})

vim.schedule(function()
	vim.opt.clipboard:append("unnamedplus")
end)

vim.env.TMPDIR = vim.fn.expand("~/.cache/nvim/tmp")
vim.fn.mkdir(vim.env.TMPDIR, "p")

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	"https://github.com/Yohannfra/edge.vim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/NMAC427/guess-indent.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/github/copilot.vim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/twenty9-labs/neotone.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/afonsofrancof/worktrees.nvim",
	"https://github.com/folke/ts-comments.nvim",
	"https://github.com/Goose97/timber.nvim",
	"https://github.com/dmmulroy/ts-error-translator.nvim",
	"https://github.com/akinsho/bufferline.nvim",
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},
})

-- ============================================================================
-- PLUGIN CONFIG
-- ============================================================================

-- UI ---
require("trouble").setup({})

-- require("neotone").setup({
-- 	mode = "system",
-- 	themes = {
-- 		dark = "retrobox",
-- 		light = "off",
-- 	},
-- })

require("lualine").setup({
	options = {
		icons_enabled = true,
		section_separators = { left = "", right = "" },
		component_separators = { left = "|", right = "|" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "" },
		lualine_y = { "diff", "diagnostics" },
		lualine_z = { "" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
})

require("bufferline").setup({})

require("which-key").setup({
	preset = "helix",
	delay = 200,
	icons = {
		mappings = true,
		rules = {},
	},
	spec = {
		{ "<leader>b", group = "Buffer", icon = { icon = "󱂬", color = "cyan" } },
		{ "<leader>d", group = "Delete / Duplicate", icon = { icon = "󰧧", color = "red" } },
		{ "<leader>f", group = "Find", icon = { icon = "󰍉", color = "green" } },
		{ "<leader>g", group = "Git", icon = { icon = "󰊢", color = "orange" } },
		{ "<leader>l", group = "LSP", icon = { icon = "󱜙", color = "blue" } },
		{ "<leader>o", icon = { icon = "󰸉", color = "azure" } },
		{ "<leader>p", group = "Project / Path", icon = { icon = "󱉭", color = "purple" } },
		{ "<leader>s", group = "Search / Source", icon = { icon = "󰍉", color = "azure" } },
		{ "<leader>t", group = "Tabs", icon = { icon = "󰓩", color = "cyan" } },
		{ "<leader>w", group = "Worktrees", icon = { icon = "󰙅", color = "orange" } },
		{ "<leader>x", group = "Execute", icon = { icon = "󰜎", color = "yellow" } },
	},
})

require("mini.icons").setup()

-- Editor ---
require("oil").setup({
	columns = { "icon" },
})

require("mini.surround").setup()
require("mini.pairs").setup()
require("ts-comments").setup()
require("timber").setup()

require("guess-indent").setup({
	auto_cmd = true,
})

-- Picker ---
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

require("mini.extra").setup()

-- Git ---
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		set_keymap("n", "]g", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
		set_keymap("n", "[g", gs.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
	end,
})

require("worktrees").setup({
	mappings = {
		create = "<leader>wtc",
		delete = "<leader>wtd",
		switch = "<leader>wts",
	},
})

-- Custom modules ---
require("projects")
-- require("glimpse")
require("notes")
require("opacity").setup()
require("spill")
require("vimcolorschemes")
require("chroma").setup()

-- ============================================================================
-- TREESITTER
-- ============================================================================

require("nvim-treesitter").setup()

local parsers = {
	"lua",
	"markdown",
	"markdown_inline",
	"typescript",
	"javascript",
	"tsx",
	"graphql",
	"yaml",
	"json",
	"css",
	"html",
	"regex",
	"bash",
}

require("nvim-treesitter").install(parsers, { summary = false, highlight = true }):wait(30000)

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = parsers,
	callback = function(args)
		vim.treesitter.start(args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- ============================================================================
-- FORMATTING
-- ============================================================================

local function js_formatter(bufnr)
	if biome.active(bufnr) then
		return { "biome" }
	end
	return { "prettierd" }
end

require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = js_formatter,
		typescript = js_formatter,
		typescriptreact = js_formatter,
		json = js_formatter,
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function(args)
		if not biome.active(args.buf) then
			return
		end
		vim.lsp.buf.code_action({
			context = {
				---@diagnostic disable-next-line: assign-type-mismatch
				only = { "source.organizeImports.biome", "source.fixAll.biome" },
				diagnostics = {},
			},
			apply = true,
		})
	end,
})

-- ============================================================================
-- LSP
-- ============================================================================

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	signs = true,
	underline = true,
})

-- Explicit call needed to override lspconfig's before_init (which scans the
-- entire project tree for CSS files and causes a delay on tsx open).
vim.lsp.config("tailwindcss", {
	before_init = function(_, config)
		if not config.settings then
			config.settings = {}
		end
		if not config.settings.editor then
			config.settings.editor = {}
		end
		if not config.settings.editor.tabSize then
			config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
		end
	end,
})

vim.lsp.enable({
	"lua_ls",
	"bashls",
	"vtsls",
	"tailwindcss",
	"eslint",
	"jsonls",
	"html",
	"cssls",
	"biome",
	"graphql",
	"marksman",
})

set_keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })

set_keymap("n", "<leader>q", function()
	require("trouble").toggle("diagnostics", { filter = { buf = 0 } })
end, { desc = "Buffer diagnostics (Trouble)" })

set_keymap("n", "<leader>Q", function()
	require("trouble").toggle("diagnostics")
end, { desc = "All diagnostics (Trouble)" })

-- ============================================================================
-- QUICKFIX
-- ============================================================================

vim.o.quickfixtextfunc = "v:lua.require'utils'.quickfixtextfunc"

vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	pattern = "quickfix",
	callback = function()
		require("utils").highlight_qf()
	end,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- ============================================================================
-- KEYMAPS: EDITING
-- ============================================================================

set_keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
set_keymap("n", "<C-s>", ":write<CR>", { desc = "Save" })
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

set_keymap("n", "-", ":foldclose<CR>", { desc = "Close fold" })
set_keymap("n", "+", ":foldopen<CR>", { desc = "Open fold" })

set_keymap("n", "gx", function()
	local url = string.match(vim.fn.expand("<cWORD>"), "https?://[%w-_%.%?%.:/%+=&]+[^ >\"',;`]*")
	if url then
		vim.ui.open(url)
	end
end)

-- ============================================================================
-- KEYMAPS: WINDOWS, BUFFERS & TABS
-- ============================================================================

set_keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height" })
set_keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height" })
set_keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
set_keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })
set_keymap("n", "<leader>td", ":tabclose<CR>", { desc = "Close tab" })
set_keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
set_keymap("n", "<leader>tk", ":tabnext<CR>", { desc = "Next tab" })
set_keymap("n", "<leader>tj", ":tabprevious<CR>", { desc = "Prev tab" })

set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal" })

set_keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
set_keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
set_keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- ============================================================================
-- KEYMAPS: TOOLS
-- ============================================================================

set_keymap("n", "<leader>e", ":Oil<CR>", { desc = "File explorer" })
set_keymap("n", "<leader>E", ":Neotree reveal_force_cwd<CR>", { desc = "File tree" })
set_keymap("n", "<leader>ff", ":Pick files<CR>", { desc = "Search files" })
set_keymap("n", "<leader>fg", ":Pick grep_live<CR>", { desc = "Search grep" })
set_keymap("n", "<leader>/", ":Pick buf_lines<CR>", { desc = "Buffer search" })
set_keymap("n", "H", "<cmd>Pick help<CR>", { desc = "Help" })

set_keymap("n", "<leader><leader>", function()
	require("spill").open()
end, { desc = "Buffer list" })

set_keymap("n", "<leader>pp", function()
	require("projects").open()
end, { desc = "Projects" })

set_keymap("n", "<M-p>", function()
	require("projects").open()
end, { desc = "Projects" })

set_keymap("n", "<leader>n", function()
	local enabled = vim.o.number or vim.o.relativenumber
	vim.opt.number = not enabled
	vim.opt.relativenumber = not enabled
end, { desc = "Toggle line numbers" })

set_keymap("n", "<leader>o", function()
	require("opacity").toggle()
end, { desc = "Toggle transparent background" })

set_keymap("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("file: " .. path)
end, { desc = "Copy file path" })

set_keymap("n", "<leader>so", ":update<CR> :source<CR>", { desc = "Source config" })

local tsx_term_winid = nil

set_keymap("n", "<leader>xx", function()
	local tmp = vim.fn.tempname() .. ".ts"
	vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), tmp)
	local cmd = "terminal tsx " .. vim.fn.shellescape(tmp)

	local origin = vim.api.nvim_get_current_win()

	if tsx_term_winid and vim.api.nvim_win_is_valid(tsx_term_winid) then
		local old_buf = vim.api.nvim_win_get_buf(tsx_term_winid)
		vim.api.nvim_set_current_win(tsx_term_winid)
		vim.cmd(cmd)
		vim.api.nvim_buf_delete(old_buf, { force = true })
	else
		vim.cmd("botright 15split | " .. cmd)
		tsx_term_winid = vim.api.nvim_get_current_win()
	end

	vim.api.nvim_set_current_win(origin)
end, { desc = "Run buffer with tsx" })

local git_changes = function()
	local MiniPick = require("mini.pick")
	local MiniIcons = require("mini.icons")
	local items = {}
	local seen = {}
	local cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

	local diff = vim.fn.systemlist("git diff --name-only")
	for _, f in ipairs(diff) do
		seen[f] = true
		local icon, _ = MiniIcons.get("file", f)
		table.insert(items, {
			text = icon .. " " .. f,
			path = cwd .. "/" .. f,
			lnum = 1,
		})
	end

	local untracked = vim.fn.systemlist("git ls-files --others --exclude-standard")
	for _, f in ipairs(untracked) do
		if not seen[f] then
			local icon, _ = MiniIcons.get("file", f)
			table.insert(items, {
				text = icon .. " " .. f .. " [new]",
				path = cwd .. "/" .. f,
				lnum = 1,
			})
		end
	end

	local show = function(buf_id, items_to_show, query)
		MiniPick.default_show(buf_id, items_to_show, query)

		local ns = vim.api.nvim_create_namespace("pick_icons")
		vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

		for i, item in ipairs(items_to_show) do
			if type(item) == "table" and item.path then
				local _, hl = MiniIcons.get("file", item.path)
				if hl then
					vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, 0, {
						end_col = #(MiniIcons.get("file", item.path)) + #" ",
						hl_group = hl,
					})
				end
			end
		end
	end

	local preview = function(buf_id, item)
		local rel = vim.fn.fnamemodify(item.path, ":.")
		if item.text:match("%[new%]$") then
			local lines = vim.fn.readfile(item.path)
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
			local ft = vim.filetype.match({ buf = buf_id, filename = item.path })
			if ft then
				vim.bo[buf_id].filetype = ft
			end
		else
			local lines = vim.fn.systemlist("git diff -- " .. vim.fn.shellescape(rel))
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
			vim.bo[buf_id].filetype = "diff"
		end
	end

	MiniPick.start({
		source = {
			name = "Git changes",
			items = items,
			show = show,
			preview = preview,
		},
	})
end

set_keymap("n", "<leader>gs", git_changes, { desc = "Git changes" })

local pick_commands = function()
	local cmds = vim.tbl_deep_extend("force", vim.api.nvim_get_commands({}), vim.api.nvim_buf_get_commands(0, {}))
	local items = {}
	for _, name in ipairs(vim.fn.getcompletion("", "command")) do
		if name:match("^%a") then
			local desc = cmds[name] and cmds[name].definition or ""
			if desc:match("^<Lua") then
				desc = ""
			end
			local display = desc ~= "" and string.format("%-30s %s", name, desc) or name
			table.insert(items, display)
		end
	end
	require("mini.pick").start({
		source = {
			name = "Commands",
			items = items,
			choose = function(item)
				local cmd = item:match("^(%S+)")
				vim.schedule(function()
					vim.cmd(cmd)
				end)
			end,
		},
	})
end

set_keymap("n", "<M-d>", pick_commands, { desc = "Commands" })

require("lsp")
require("ts-error-translator").setup()

vim.keymap.set("n", "<leader>uC", function()
	require("fzf-lua").colorschemes({ live_preview = true })
end, { desc = "Select Color Scheme with Preview" })

vim.keymap.set("n", "<leader>uT", function()
	require("vimcolorschemes").open()
end, { desc = "Browse + install themes (vimcolorschemes)" })

vim.keymap.set("n", "<leader>uw", function()
	require("chroma").generate({ notify = true })
end, { desc = "Regenerate colorscheme from wallpaper (chroma)" })

vim.keymap.set("n", "<leader>ub", function()
	require("chroma").toggle()
end, { desc = "Toggle chroma dark/light" })

vim.cmd.colorscheme("chroma")
