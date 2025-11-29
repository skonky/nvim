local vim = vim
local utils = require("utils")
local set_opts = utils.set_opts
local set_globals = utils.set_globals
local set_keymap = utils.set_keymap

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
	foldmethod = "indent",
})

set_globals({
	neovide_theme = "auto",
	neovide_padding_left = 50,
	neovide_padding_right = 50,
	neovide_padding_top = 50,
	neovide_padding_bottom = 50,
	mapleader = " ",
	adwaita_darker = true,
	maplocalleader = " ",
})

vim.schedule(function()
	vim.opt.clipboard:append("unnamedplus")
end)

set_keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
set_keymap("n", "<C-s>", ":write<CR>", { desc = "Save" })
set_keymap("n", "<leader>so", ":update<CR> :source<CR>", { desc = "Source config" })
set_keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
set_keymap("n", "<leader>n", function()
	if vim.opt.number:get() or vim.opt.relativenumber:get() then
		vim.opt.number = false
		vim.opt.relativenumber = false
	else
		vim.opt.number = true
		vim.opt.relativenumber = true
	end
end, { desc = "Toggle line numbers" })

set_keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
set_keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
set_keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
set_keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
set_keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
set_keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

set_keymap("n", "-", ":foldclose<CR>", { desc = "Close fold" })
set_keymap("n", "+", ":foldopen<CR>", { desc = "Open fold" })

set_keymap("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set_keymap("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
set_keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
set_keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

set_keymap("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })
set_keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
set_keymap("n", "gD", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
set_keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
set_keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

set_keymap("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })
set_keymap("n", "<leader>e", ":Oil<CR>", { desc = "Open Oil file explorer" })
set_keymap("n", "<leader>pp", "<cmd>NeovimProjectDiscover<CR>", { desc = "Discover projects" })
set_keymap("n", "<leader>sf", ":Pick files<CR>", { desc = "Search files" })
set_keymap("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Live grep" })
set_keymap("n", "<leader>/", ":Pick buf_lines<CR>", { desc = "Search buffer lines" })
set_keymap("n", "<leader><leader>", ":Pick buffers<CR>", { desc = "Search buffers" })
set_keymap("n", "<leader>gs", ":Pick git_hunks<CR>", { desc = "Git hunks" })
set_keymap("n", "<leader>km", ":Pick keymaps<CR>", { desc = "Show keymaps" })
set_keymap("n", "<D-x>", ":Pick commands<CR>", { desc = "See all commands" })

set_keymap("n", "<leader>td", ":tabclose<CR>", { desc = "Close terminal tab" })

vim.pack.add({
	"https://github.com/rktjmp/hotpot.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/maxmx03/solarized.nvim",
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
	"https://github.com/navarasu/onedark.nvim",
	"https://github.com/mistweaverco/kulala.nvim",
	"https://github.com/twenty9-labs/frisch.nvim",
	"https://github.com/sainnhe/everforest",
	"https://github.com/Mofiqul/adwaita.nvim",
	"https://github.com/zootedb0t/citruszest.nvim",
	"https://github.com/bluz71/vim-moonfly-colors",
	"https://github.com/blazkowolf/gruber-darker.nvim",
	"https://github.com/miikanissi/modus-themes.nvim",
	"https://github.com/slugbyte/lackluster.nvim",
	"https://github.com/rockerBOO/boo-colorscheme-nvim",
	"https://github.com/github/copilot.vim",
})

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

require("mini.icons").setup()
require("mini.comment").setup()
require("mini.surround").setup()
require("mini.pairs").setup()

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
require("mini.completion").setup()

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

require("oil").setup({
	columns = { "icon" },
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
		"~/Code/adhese/sdk_typescript.git",
		"~/Code/adhese/gambit-design-system",
		"~/FennelProjects/second-game",
		"~/Code/nord-wallpaper-maker/frischer",
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
		vim.keymap.set("n", "]g", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
		vim.keymap.set("n", "[g", gs.prev_hunk, { buffer = bufnr, desc = "Previous git hunk" })
	end,
})

require("neogit")

require("citruszest").setup({
	option = {
		transparent = true,
		bold = false,
		italic = true,
	},
})

vim.cmd("colorscheme solarized")

vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss", "eslint", "fennel_language_server" })

local term_numbers = {}

vim.keymap.set("n", "<leader>tt", function()
	local num = 1
	while term_numbers[num] do
		num = num + 1
	end

	vim.cmd("tabnew")
	vim.cmd("term")
	vim.cmd("file term-" .. num)

	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buflisted = false
	term_numbers[num] = buf

	vim.api.nvim_create_autocmd("BufHidden", {
		buffer = buf,
		once = true,
		callback = function()
			term_numbers[num] = nil
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end)
		end,
	})
end, { desc = "Open terminal in new tab" })

vim.o.tabline = "%!v:lua.MyTabLine()"

function _G.MyTabLine()
	local title = ""

	for i = 1, vim.fn.tabpagenr("$") do
		local buflist = vim.fn.tabpagebuflist(i)
		local winnr = vim.fn.tabpagewinnr(i)
		local bufnr = buflist[winnr]
		local bufname = vim.fn.bufname(bufnr)

		if i == vim.fn.tabpagenr() then
			title = title .. "%#TabLineSel#"
		else
			title = title .. "%#TabLine#"
		end

		title = title .. " " .. i .. " "

		if bufname ~= "" then
			title = title .. vim.fn.fnamemodify(bufname, ":t")
		else
			title = title .. "[No Name]"
		end

		title = title .. " "
	end

	title = title .. "%#TabLineFill#%T"
	return title
end

vim.filetype.add({ extension = { http = "http" } })

vim.env.TMPDIR = vim.fn.expand("~/.cache/nvim/tmp")
vim.fn.mkdir(vim.env.TMPDIR, "p")

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.cmd("hi StatusLine guibg=NONE ctermbg=NONE")
	end,
})
