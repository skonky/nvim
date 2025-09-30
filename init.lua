local vim = vim -- reduce the warning about missing global to this line only

-- ============================================================================
-- OPTIONS
-- ============================================================================

-- UI
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.opt.termguicolors = true
vim.o.winborder = "rounded"

-- Splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- Editing
vim.o.mouse = "a"
vim.o.breakindent = true
vim.o.undofile = true
vim.cmd([[set noswapfile]])
vim.o.confirm = true

-- Tabs & Indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Timing
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Folding
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "preview" }

-- Clipboard (scheduled to avoid startup issues)
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>qq", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Write" })
vim.keymap.set("n", "<C-s>", ":write<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>so", ":update<CR> :source<CR>", { desc = "Source config" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

-- Folding
vim.keymap.set("n", "-", ":foldclose<CR>", { desc = "Close fold" })
vim.keymap.set("n", "+", ":foldopen<CR>", { desc = "Open fold" })

-- Visual mode
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- LSP
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Plugin keymaps
vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Open Oil file explorer" })
vim.keymap.set("n", "<leader>pp", "<cmd>NeovimProjectDiscover<CR>", { desc = "Discover projects" })
vim.keymap.set("n", "<leader>sf", ":Pick files<CR>", { desc = "Search files" })
vim.keymap.set("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader><leader>", ":Pick buffers<CR>", { desc = "Search buffers" })
vim.keymap.set("n", "<leader>gs", ":Pick git_hunks<CR>", { desc = "Git hunks" })
vim.keymap.set("n", "<D-x>", ":Pick commands<CR>", { desc = "See all commands" })

-- Terminal tabs
vim.keymap.set("n", "<leader>td", ":tabclose<CR>", { desc = "Close terminal tab" })

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/NMAC427/guess-indent.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/echasnovski/mini.pick",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/coffebar/neovim-project",
	"https://github.com/Shatur/neovim-session-manager",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-mini/mini.extra",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/tpope/vim-surround",
	"https://github.com/tpope/vim-repeat",
	"https://github.com/NeogitOrg/neogit",
})

-- ============================================================================
-- PLUGIN CONFIGURATION
-- ============================================================================

require("mini.icons").setup()

require("mini.pick").setup({
	mappings = {
		choose_all = {
			char = "<C-q>",
			func = function()
				local miniPick = require("mini.pick")
				local mappings = miniPick.get_picker_opts().mappings
				vim.api.nvim_input(mappings.mark_all .. mappings.choose_marked)
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

require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua", lsp_format = "lua_ls" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
	},
})

require("oil").setup({
	columns = {
		"icon",
	},
})

require("guess-indent").setup({
	auto_cmd = true,
})

require("neovim-project").setup({
	projects = {
		"~/.config",
		"~/.config/nvim",
		"~/.config/ghostty/",
		"~/Code/adhese/cloud",
		"~/Code/adhese/mcb-frontend",
		"~/Code/adhese/sdk_typescript.git",
		"~/Code/adhese/gambit-design-system",
		"~/Code/adhese/playwright-tests",
	},
	picker = {
		type = "fzf-lua",
	},
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

vim.cmd("colorscheme tokyonight")

-- ============================================================================
-- LSP CONFIGURATION
-- ============================================================================

vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss", "eslint" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		-- without this the autosuggest will reset after typing one of the chars below
		if client.name == "tailwindcss" then
			vim.opt_local.iskeyword:append("-")
			vim.opt_local.iskeyword:append(".") -- for arbitrary values like w-[50.5rem]
			vim.opt_local.iskeyword:append("/") -- for opacity like bg-black/50
			vim.opt_local.iskeyword:append("[") -- for arbitrary values like w-[100px]
			vim.opt_local.iskeyword:append("]")
		end

		-- Completion setup
		if client:supports_method("textDocument/completion") then
			if client.server_capabilities.completionProvider then
				client.server_capabilities.completionProvider.resolveProvider = true
			end

			-- Trigger autocompletion on every keypress
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end

		-- Completion accept
		vim.keymap.set("i", "<C-y>", function()
			if vim.fn.pumvisible() == 1 then
				return "<C-y>"
			end
			return "<C-y>"
		end, { expr = true, buffer = args.buf })
	end,
})

-- ============================================================================
-- TERMINAL MANAGEMENT
-- open a terminal in a new tab with <leader>tt
-- ============================================================================

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

-- ============================================================================
-- CUSTOM TABLINE
-- ============================================================================
vim.o.tabline = "%!v:lua.MyTabLine()"

function _G.MyTabLine()
	local title = ""
	for i = 1, vim.fn.tabpagenr("$") do
		local buflist = vim.fn.tabpagebuflist(i)
		local winnr = vim.fn.tabpagewinnr(i)
		local bufnr = buflist[winnr]
		local bufname = vim.fn.bufname(bufnr)

		-- Highlight
		if i == vim.fn.tabpagenr() then
			title = title .. "%#TabLineSel#"
		else
			title = title .. "%#TabLine#"
		end

		-- Tab number
		title = title .. " " .. i .. " "

		-- Filename only (no path)
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
