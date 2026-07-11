local M = {}

function M.open()
	local projects = {
		"~/.config",
		"~/.config/nvim",
		"~/.config/kitty/",
		"~/Code/ahold/gambit-frontend.git",
		"~/Code/playground/",
	}

	local items = {}
	for _, p in ipairs(projects) do
		local expanded = vim.fn.expand(p)
		table.insert(items, { text = vim.fn.fnamemodify(expanded, ":~"), path = expanded })
	end

	require("mini.pick").start({
		source = {
			name = "Projects",
			items = items,
			choose = function(item)
				local path = item.path
				vim.schedule(function()
					local unsaved = {}
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.bo[buf].modified then
							table.insert(unsaved, vim.api.nvim_buf_get_name(buf))
						end
					end

					if #unsaved > 0 then
						local names = {}
						for _, name in ipairs(unsaved) do
							table.insert(names, "  " .. vim.fn.fnamemodify(name, ":~:."))
						end
						local choice = vim.fn.confirm(
							"Unsaved changes in:\n" .. table.concat(names, "\n") .. "\n\nDiscard changes?",
							"&Yes\n&No",
							2
						)
						if choice ~= 1 then
							return
						end
					end

					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) then
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end

					vim.cmd("cd " .. vim.fn.fnameescape(path))
					vim.cmd("Oil " .. vim.fn.fnameescape(path))
				end)
			end,
		},
	})
end

return M
