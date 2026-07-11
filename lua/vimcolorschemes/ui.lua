local M = {}

local data = require("vimcolorschemes.data")
local preview = require("vimcolorschemes.preview")
local install = require("vimcolorschemes.install")

local state = {
	themes = nil,
	filtered = {},
	query = "",
	background = "dark",
	cursor = 1,
	picker_buf = nil,
	picker_win = nil,
	prompt_buf = nil,
	prompt_win = nil,
	help_buf = nil,
	help_win = nil,
	installing = false,
}

local list_ns = vim.api.nvim_create_namespace("vimcolorschemes_list")

local function variant(theme)
	if state.background == "dark" then
		return theme.has_dark == 1 and "dark" or "light"
	end
	return theme.has_light == 1 and "light" or "dark"
end

local function fmt_stars(n)
	n = n or 0
	if n >= 1000 then
		return string.format("%.1fk", n / 1000)
	end
	return tostring(n)
end

local function format_row(theme)
	local mark = install.is_installed(theme) and "● " or "  "
	return string.format(
		"%s%-26s %6s★  %s/%s",
		mark,
		theme.scheme_name,
		fmt_stars(theme.stars),
		theme.owner_name,
		theme.repo_name
	)
end

local function apply_filter()
	if not state.themes then
		state.filtered = {}
		return
	end
	local q = state.query:lower()
	state.filtered = {}
	for _, t in ipairs(state.themes) do
		local hay = (t.scheme_name or "")
			.. " "
			.. (t.repo_name or "")
			.. " "
			.. (t.owner_name or "")
			.. " "
			.. (t.description or "")
		if q == "" or hay:lower():find(q, 1, true) then
			table.insert(state.filtered, t)
		end
	end
	if state.cursor > #state.filtered then
		state.cursor = math.max(1, #state.filtered)
	end
end

local function swatch_hl(hex)
	local clean = hex:gsub("#", ""):upper()
	local name = "VCSwatch_" .. clean
	vim.api.nvim_set_hl(0, name, { fg = hex, bg = hex })
	return name
end

-- Re-register every VCSwatch_* group used by the current list. Needed after
-- `preview.apply` calls `hi clear`.
local function reapply_swatch_hls()
	if not state.filtered then
		return
	end
	local groups = data.swatch_groups()
	for _, t in ipairs(state.filtered) do
		local pal = t.swatches[variant(t)]
		if pal then
			for _, name in ipairs(groups) do
				local hex = pal[name]
				if hex then
					swatch_hl(hex)
				end
			end
		end
	end
end

local function render_list()
	if not (state.picker_buf and vim.api.nvim_buf_is_valid(state.picker_buf)) then
		return
	end
	local lines = {}
	for i, t in ipairs(state.filtered) do
		lines[i] = format_row(t)
	end
	if #lines == 0 then
		lines = { "  (no matches)" }
	end

	vim.bo[state.picker_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.picker_buf, 0, -1, false, lines)
	vim.bo[state.picker_buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(state.picker_buf, list_ns, 0, -1)

	local groups = data.swatch_groups()
	for i, t in ipairs(state.filtered) do
		local pal = t.swatches[variant(t)] or {}
		local virt = {}
		for _, name in ipairs(groups) do
			local hex = pal[name]
			if hex then
				table.insert(virt, { "██", swatch_hl(hex) })
			end
		end
		if #virt > 0 then
			table.insert(virt, 1, { "  " })
			vim.api.nvim_buf_set_extmark(state.picker_buf, list_ns, i - 1, 0, {
				virt_text = virt,
				virt_text_pos = "eol",
			})
		end
	end

	if #state.filtered > 0 then
		local row = math.max(1, math.min(state.cursor, #state.filtered))
		vim.api.nvim_win_set_cursor(state.picker_win, { row, 0 })
		state.cursor = row
	end
end

local function update_prompt()
	if not (state.prompt_buf and vim.api.nvim_buf_is_valid(state.prompt_buf)) then
		return
	end
	local total = state.themes and #state.themes or 0
	local label = string.format(
		"  %s   [%s]   %d/%d",
		state.query == "" and "type to filter" or state.query,
		state.background,
		#state.filtered,
		total
	)
	vim.bo[state.prompt_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.prompt_buf, 0, -1, false, { label })
	vim.bo[state.prompt_buf].modifiable = false
end

local function current_theme()
	return state.filtered[state.cursor]
end

local function preview_current()
	local theme = current_theme()
	if not theme then
		return
	end
	local bg = variant(theme)
	local palette = data.palette(theme, bg)
	preview.apply(palette, bg)
	reapply_swatch_hls()
end

local function close_window(win)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

local function close(opts)
	opts = opts or {}
	close_window(state.picker_win)
	close_window(state.prompt_win)
	close_window(state.help_win)
	state.picker_win, state.picker_buf = nil, nil
	state.prompt_win, state.prompt_buf = nil, nil
	state.help_win, state.help_buf = nil, nil
	if opts.restore ~= false then
		preview.restore()
	end
end

local function move(delta)
	if #state.filtered == 0 then
		return
	end
	state.cursor = math.max(1, math.min(#state.filtered, state.cursor + delta))
	vim.api.nvim_win_set_cursor(state.picker_win, { state.cursor, 0 })
	preview_current()
end

local function toggle_background()
	state.background = state.background == "dark" and "light" or "dark"
	render_list()
	update_prompt()
	preview_current()
end

local function install_current()
	local theme = current_theme()
	if not theme then
		return
	end
	local bg = variant(theme)
	state.installing = true
	preview.commit() -- the soon-to-be-applied colorscheme replaces the preview
	close({ restore = false })
	install.install(theme, function(ok)
		state.installing = false
		if ok then
			install.apply(theme, bg)
		else
			-- nothing to restore from since we committed; just warn
		end
	end)
end

local function preview_only()
	-- Already previewing on cursor move; this just confirms current preview and
	-- closes without installing. The preview persists until the user picks a
	-- different colorscheme.
	preview.commit()
	close({ restore = false })
	vim.notify("Previewing — not installed. :colorscheme <name> may not work yet.")
end

local function open_github()
	local theme = current_theme()
	if theme and theme.github_url then
		vim.ui.open(theme.github_url)
	end
end

local function prompt_filter()
	vim.ui.input({ prompt = "Filter: ", default = state.query }, function(input)
		if input == nil then
			return
		end
		state.query = input
		state.cursor = 1
		apply_filter()
		render_list()
		update_prompt()
		preview_current()
	end)
end

local HELP_TEXT = {
	"j/k or arrows  move (live preview)",
	"<Tab>          toggle dark/light",
	"/              filter",
	"<CR>           install + apply",
	"P              keep preview, don't install",
	"gx             open repo in browser",
	"?              toggle this help",
	"q / <Esc>      close (restore theme)",
}

local function toggle_help()
	if state.help_win and vim.api.nvim_win_is_valid(state.help_win) then
		close_window(state.help_win)
		state.help_win, state.help_buf = nil, nil
		return
	end
	state.help_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.help_buf].buftype = "nofile"
	vim.bo[state.help_buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_lines(state.help_buf, 0, -1, false, HELP_TEXT)
	vim.bo[state.help_buf].modifiable = false

	local width = 42
	local height = #HELP_TEXT
	state.help_win = vim.api.nvim_open_win(state.help_buf, false, {
		relative = "editor",
		row = vim.o.lines - height - 4,
		col = 2,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " keys ",
		focusable = false,
	})
end

local function render_loading(msg)
	if not (state.picker_buf and vim.api.nvim_buf_is_valid(state.picker_buf)) then
		return
	end
	vim.bo[state.picker_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.picker_buf, 0, -1, false, { "", "  " .. msg, "" })
	vim.bo[state.picker_buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(state.picker_buf, list_ns, 0, -1)
end

function M.refresh()
	if state.picker_buf and vim.api.nvim_buf_is_valid(state.picker_buf) then
		render_loading("Refreshing from vimcolorschemes.com...")
	else
		vim.notify("Refreshing vimcolorschemes cache...")
	end
	data.refresh(function(themes, err)
		if err then
			vim.notify("vimcolorschemes refresh failed: " .. tostring(err), vim.log.levels.ERROR)
			return
		end
		state.themes = themes or {}
		apply_filter()
		if state.picker_buf and vim.api.nvim_buf_is_valid(state.picker_buf) then
			render_list()
			update_prompt()
			preview_current()
		else
			vim.notify(string.format("Cached %d themes from vimcolorschemes", #state.themes))
		end
	end)
end

function M.open()
	if state.picker_win and vim.api.nvim_win_is_valid(state.picker_win) then
		return
	end

	state.themes = nil
	state.filtered = {}
	state.background = vim.o.background == "light" and "light" or "dark"
	state.cursor = 1
	state.query = ""
	state.installing = false

	local width = math.max(56, math.floor(vim.o.columns * 0.45))
	local height = math.max(10, math.floor(vim.o.lines * 0.7))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = vim.o.columns - width - 2

	state.picker_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.picker_buf].buftype = "nofile"
	vim.bo[state.picker_buf].bufhidden = "wipe"
	vim.bo[state.picker_buf].filetype = "vimcolorschemes"

	state.picker_win = vim.api.nvim_open_win(state.picker_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height - 3,
		style = "minimal",
		border = "rounded",
		title = " vimcolorschemes ",
		title_pos = "center",
	})
	vim.wo[state.picker_win].cursorline = true
	vim.wo[state.picker_win].winhl = "CursorLine:PmenuSel"

	state.prompt_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.prompt_buf].buftype = "nofile"
	vim.bo[state.prompt_buf].bufhidden = "wipe"

	state.prompt_win = vim.api.nvim_open_win(state.prompt_buf, false, {
		relative = "editor",
		row = row + height - 2,
		col = col,
		width = width,
		height = 1,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})

	render_loading("Loading themes...")
	update_prompt()

	data.list_themes(function(themes, err)
		if err then
			render_loading("Failed: " .. tostring(err))
			return
		end
		state.themes = themes or {}
		apply_filter()
		render_list()
		update_prompt()
		preview_current()
	end)

	local function map(lhs, fn)
		vim.keymap.set("n", lhs, fn, {
			buffer = state.picker_buf,
			nowait = true,
			silent = true,
		})
	end

	map("j", function() move(1) end)
	map("k", function() move(-1) end)
	map("<Down>", function() move(1) end)
	map("<Up>", function() move(-1) end)
	map("<C-d>", function() move(10) end)
	map("<C-u>", function() move(-10) end)
	map("gg", function() move(-1e9) end)
	map("G", function() move(1e9) end)
	map("<Tab>", toggle_background)
	map("<CR>", install_current)
	map("P", preview_only)
	map("gx", open_github)
	map("/", prompt_filter)
	map("?", toggle_help)
	map("q", function() close() end)
	map("<Esc>", function() close() end)

	-- Mouse / cursor-line tracking
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = state.picker_buf,
		callback = function()
			if not (state.picker_win and vim.api.nvim_win_is_valid(state.picker_win)) then
				return
			end
			local row = vim.api.nvim_win_get_cursor(state.picker_win)[1]
			if row ~= state.cursor and row <= #state.filtered then
				state.cursor = row
				preview_current()
			end
		end,
	})

	-- If the picker window closes by any other means, clean up.
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(state.picker_win),
		once = true,
		callback = function()
			if state.installing then
				return
			end
			vim.schedule(function() close() end)
		end,
	})
end

return M
