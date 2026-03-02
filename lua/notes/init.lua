local notes_dir = vim.fn.expand("~/notes")
vim.fn.mkdir(notes_dir, "p")

local function open_in_float(path)
	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = true

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
		title_pos = "center",
	})
end

vim.keymap.set("n", "<leader>sn", function()
	require("mini.pick").builtin.files(nil, {
		source = {
			cwd = notes_dir,
			choose = function(item)
				vim.schedule(function()
					open_in_float(notes_dir .. "/" .. item)
				end)
			end,
		},
	})
end, { desc = "Search notes" })

vim.keymap.set("n", "<leader>nn", function()
	vim.ui.input({ prompt = "Note name: " }, function(name)
		if name and name ~= "" then
			open_in_float(notes_dir .. "/" .. name .. ".md")
		end
	end)
end, { desc = "New note" })
