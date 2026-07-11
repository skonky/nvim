local M = {}

function M.set_opts(opts)
	for k, v in pairs(opts) do
		vim.opt[k] = v
	end
end

function M.set_globals(globals)
	for k, v in pairs(globals) do
		vim.g[k] = v
	end
end

function M.set_keymap(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(mode, lhs, rhs, opts)
end

function M.quickfixtextfunc(info)
	local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
	local lines = {}
	for i = info.start_idx, info.end_idx do
		local item = items[i]
		local fname = ""
		if item.bufnr > 0 then
			local fullpath = vim.api.nvim_buf_get_name(item.bufnr)
			local parts = vim.split(fullpath, "/", { plain = true })
			if #parts >= 2 then
				fname = parts[#parts - 1] .. "/" .. parts[#parts]
			else
				fname = parts[#parts] or fullpath
			end
			local icon, _ = require("mini.icons").get("file", fullpath)
			fname = icon .. " " .. fname
		end
		local pos = item.lnum > 0 and (":" .. item.lnum) or ""
		local text = item.text ~= "" and ("  " .. vim.trim(item.text)) or ""
		table.insert(lines, fname .. pos .. text)
	end
	return lines
end

local qf_ns = vim.api.nvim_create_namespace("qf_highlights")

function M.highlight_qf()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, qf_ns, 0, -1)
	local items = vim.fn.getqflist({ items = 1 }).items
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for idx, line in ipairs(lines) do
		local item = items[idx]
		if item and item.bufnr > 0 then
			local fullpath = vim.api.nvim_buf_get_name(item.bufnr)
			local _, icon_hl = require("mini.icons").get("file", fullpath)

			-- icon (first 2-3 bytes)
			local icon_end = line:find(" ")
			if icon_end and icon_hl then
				vim.api.nvim_buf_set_extmark(buf, qf_ns, idx - 1, 0, {
					end_col = icon_end - 1,
					hl_group = icon_hl,
				})
			end

			-- path + position in Directory color
			local text_start = line:find("  ", icon_end)
			local path_end = text_start or #line
			if icon_end then
				vim.api.nvim_buf_set_extmark(buf, qf_ns, idx - 1, icon_end, {
					end_col = path_end,
					hl_group = "Directory",
				})
			end

			-- match text in default fg (Comment for subtle, or just leave unhighlighted)
			if text_start then
				vim.api.nvim_buf_set_extmark(buf, qf_ns, idx - 1, text_start + 2, {
					end_col = #line,
					hl_group = "Normal",
				})
			end
		end
	end
end

return M
