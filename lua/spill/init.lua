local M = {}

local function get_listed_buffers(exclude_buf)
	local bufs = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[b].buflisted and b ~= exclude_buf then
			table.insert(bufs, {
				bufnr = b,
				name = vim.api.nvim_buf_get_name(b),
				modified = vim.bo[b].modified,
			})
		end
	end
	return bufs
end

local devicons = require("nvim-web-devicons")

local function format_line(entry)
	local name = entry.name
	local icon, hl
	if name == "" then
		name = "[No Name]"
		icon = " "
	else
		name = vim.fn.fnamemodify(name, ":~:.")
		local filename = vim.fn.fnamemodify(entry.name, ":t")
		icon, hl = devicons.get_icon(filename, nil, { default = true })
	end
	if entry.modified then
		name = name .. " [+]"
	end
	return icon .. " " .. name, hl
end

function M.open()
	local origin_buf = vim.api.nvim_get_current_buf()
	local bv_buf = vim.api.nvim_create_buf(false, true)

	vim.bo[bv_buf].buftype = "nofile"
	vim.bo[bv_buf].bufhidden = "wipe"
	vim.bo[bv_buf].swapfile = false
	vim.bo[bv_buf].buflisted = false

	local entries = get_listed_buffers(bv_buf)
	if #entries < 2 then
		vim.api.nvim_buf_delete(bv_buf, { force = true })
		vim.notify("No other buffers open", vim.log.levels.INFO)
		return
	end

	local line_to_buf = {}
	local lines = {}
	local highlights = {}
	local cursor_line = 1

	for i, entry in ipairs(entries) do
		local text, hl = format_line(entry)
		lines[i] = text
		highlights[i] = hl
		line_to_buf[i] = entry.bufnr
		if entry.bufnr == origin_buf then
			cursor_line = i
		end
	end

	local spill_ns = vim.api.nvim_create_namespace("spill")

	local function render()
		vim.bo[bv_buf].modifiable = true
		vim.api.nvim_buf_set_lines(bv_buf, 0, -1, false, lines)
		vim.bo[bv_buf].modifiable = false
		vim.api.nvim_buf_clear_namespace(bv_buf, spill_ns, 0, -1)
		for i, hl in ipairs(highlights) do
			if hl then
				vim.api.nvim_buf_set_extmark(bv_buf, spill_ns, i - 1, 0, {
					end_col = #lines[i]:match("^%S+"),
					hl_group = hl,
				})
			end
		end
	end

	render()

	vim.api.nvim_set_current_buf(bv_buf)
	if #lines > 0 then
		vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })
	end

	local function close_bufview(target)
		if target and vim.api.nvim_buf_is_valid(target) and vim.bo[target].buflisted then
			vim.api.nvim_set_current_buf(target)
		elseif #line_to_buf > 0 then
			vim.api.nvim_set_current_buf(line_to_buf[1])
		else
			vim.cmd("enew")
		end
	end

	local function delete_buffer_at_cursor()
		local row = vim.api.nvim_win_get_cursor(0)[1]
		local target = line_to_buf[row]
		if not target then
			return
		end

		if vim.bo[target].modified then
			local choice = vim.fn.confirm("Buffer has unsaved changes. Close anyway?", "&Yes\n&No", 2)
			if choice ~= 1 then
				return
			end
		end

		vim.api.nvim_buf_delete(target, { force = true })
		table.remove(line_to_buf, row)
		table.remove(lines, row)
		table.remove(highlights, row)

		render()

		if #lines == 0 then
			close_bufview(nil)
			return
		end
		local new_row = math.min(row, #lines)
		vim.api.nvim_win_set_cursor(0, { new_row, 0 })
	end

	vim.keymap.set("n", "<CR>", function()
		local row = vim.api.nvim_win_get_cursor(0)[1]
		local target = line_to_buf[row]
		if target then
			close_bufview(target)
		end
	end, { buffer = bv_buf, silent = true })

	vim.keymap.set("n", "dd", delete_buffer_at_cursor, { buffer = bv_buf, silent = true })

	vim.keymap.set("n", "q", function()
		close_bufview(origin_buf)
	end, { buffer = bv_buf, silent = true })

	-- Intercept :q and :q! via BufLeave + autocmd approach won't work cleanly,
	-- so use an abbreviation to remap :q to close_bufview
	vim.api.nvim_buf_create_user_command(bv_buf, "Q", function()
		close_bufview(origin_buf)
	end, { bang = true })

	vim.cmd.cnoreabbrev("<buffer> q Q")
	vim.cmd.cnoreabbrev("<buffer> q! Q!")
end

return M
