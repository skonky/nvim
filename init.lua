local utils = require("utils")
local set_opts = utils.set_opts
local set_globals = utils.set_globals
local set_keymap = utils.set_keymap

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
	list = true,
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
})

vim.schedule(function()
	vim.opt.clipboard:append("unnamedplus")
end)

vim.filetype.add({ extension = { http = "http" } })

-- ts_ls writes to /tmp which can cause issues on some systems
vim.env.TMPDIR = vim.fn.expand("~/.cache/nvim/tmp")
vim.fn.mkdir(vim.env.TMPDIR, "p")

-- ============================================================================
-- AUTOCOMMAND
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", {})

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

set_keymap("n", "s", function()
	require("flash").jump()
end, { desc = "Flash jump" })

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
set_keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertical" })
set_keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontal" })

set_keymap("n", "<leader>td", ":tabclose<CR>", { desc = "Close tab" })
set_keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
set_keymap("n", "<leader>tk", ":tabnext<CR>", { desc = "Next tab" })
set_keymap("n", "<leader>tj", ":tabprevious<CR>", { desc = "Prev tab" })

set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal" })

set_keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
set_keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
set_keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- ============================================================================
-- KEYMAPS: LSP
-- ============================================================================

set_keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
set_keymap("n", "gD", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
set_keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
set_keymap("n", "gr", vim.lsp.buf.references, { desc = "References" })
set_keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ============================================================================
-- KEYMAPS: TOOLS
-- ============================================================================

set_keymap("n", "<leader>e", ":Oil<CR>", { desc = "File explorer" })
set_keymap("n", "<leader>gg", ":Neogit<CR>", { desc = "Neogit" })
set_keymap("n", "<leader>pp", "<cmd>NeovimProjectDiscover<CR>", { desc = "Projects" })

set_keymap("n", "<leader>sf", ":Pick files<CR>", { desc = "Search files" })
set_keymap("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Search grep" })
set_keymap("n", "<leader>/", ":Pick buf_lines<CR>", { desc = "Buffer search" })
set_keymap("n", "<leader><leader>", ":Pick buffers<CR>", { desc = "Select buffer" })
set_keymap("n", "<leader>gs", ":Pick git_hunks<CR>", { desc = "Git hunks" })

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
set_keymap("n", "H", "<cmd>Pick help<CR>", { desc = "Help" })

set_keymap("n", "<leader>n", function()
	local enabled = vim.o.number or vim.o.relativenumber
	vim.opt.number = not enabled
	vim.opt.relativenumber = not enabled
end, { desc = "Toggle line numbers" })

set_keymap("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("file: " .. path)
end, { desc = "Copy file path" })

set_keymap("n", "<leader>so", ":update<CR> :source<CR>", { desc = "Source config" })

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	"https://github.com/folke/which-key.nvim",
	"https://github.com/OXY2DEV/helpview.nvim",
	"https://github.com/OXY2DEV/markview.nvim",
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
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/folke/noice.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/twenty9-labs/neotone.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/b0o/incline.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/folke/flash.nvim",
})

-- ============================================================================
-- PLUGIN CONFIG
-- ============================================================================

require("which-key").setup({
	preset = "helix",
	delay = 200,
	icons = {
		mappings = true,
		rules = {},
	},
	spec = {
		{ "<leader>b", group = "Buffer", icon = "󰈔" },
		{ "<leader>c", group = "Code", icon = "󰌗" },
		{ "<leader>d", group = "Delete / Duplicate", icon = "󰆴" },
		{ "<leader>g", group = "Git", icon = "󰊢" },
		{ "<leader>l", group = "LSP", icon = "󰅩" },
		{ "<leader>p", group = "Project / Path", icon = "󰉋" },
		{ "<leader>r", group = "Rename", icon = "󰑕" },
		{ "<leader>R", group = "HTTP requests", icon = "󰌗" },
		{ "<leader>s", group = "Search / Split", icon = "󰢶" },
		{ "<leader>t", group = "Tabs", icon = "󰓫" },
	},
})

local helpers = require("incline.helpers")
local devicons = require("nvim-web-devicons")
require("incline").setup({
	window = {
		padding = 0,
	},
	render = function(props)
		local bufname = vim.api.nvim_buf_get_name(props.buf)
		if bufname == "" then
			return { " ", "[No Name]", " " }
		end

		local filename = vim.fn.fnamemodify(bufname, ":t")
		local ft_icon, ft_color = devicons.get_icon_color(filename)
		local modified = vim.bo[props.buf].modified

		local path = vim.fn.fnamemodify(bufname, ":~:.:h")
		local parts = {}
		if path ~= "." then
			for part in path:gmatch("[^/]+") do
				table.insert(parts, part)
			end
			for i = 1, #parts - 1 do
				parts[i] = parts[i]:sub(1, 1)
			end
		end

		local dir = #parts > 0 and (table.concat(parts, "/") .. "/") or ""

		return {
			ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
			" ",
			#dir > 0 and { dir, group = "Comment" } or "",
			{ filename, gui = modified and "bold,italic" or "bold" },
			" ",
			group = "Visual",
		}
	end,
})

require("lualine").setup({
	options = {
		icons_enabled = true,
		section_separators = { left = "", right = "" },
		component_separators = { left = "|", right = "|" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "" },
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

require("neotone").setup({
	mode = "system",
	themes = {
		dark = "tokyonight-night",
		light = "tokyonight-day",
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
		"~/Code/ahold/gambit-mcb",
		"~/Code/monorepos/nest-stack",
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
		"tsx",
		"javascript",
		"graphql",
		"yaml",
		"json",
		"css",
		"html",
		"vimdoc",
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

require("noice").setup({
	cmdline = {
		enabled = true,
	},
	messages = {
		enabled = true,
	},
	popupmenu = {
		enabled = false,
	},
	notify = {
		enabled = false,
	},
	lsp = {
		progress = {
			enabled = false,
		},
		hover = {
			enabled = false,
		},
		signature = {
			enabled = false,
		},
		message = {
			enabled = false,
		},
	},
})

require("glimpse")

-- ============================================================================
-- LSP
-- ============================================================================

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	signs = true,
	underline = true,
})

vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss", "eslint", "jsonls", "html", "cssls" })
