local notes_dir = vim.fn.expand("~/notes")
vim.fn.mkdir(notes_dir, "p")

vim.keymap.set("n", "<leader>sn", function()
	require("mini.pick").builtin.files(nil, { source = { cwd = notes_dir } })
end, { desc = "Search notes" })

vim.keymap.set("n", "<leader>nn", function()
	vim.ui.input({ prompt = "Note name: " }, function(name)
		if name and name ~= "" then
			vim.cmd("edit " .. notes_dir .. "/" .. name .. ".md")
		end
	end)
end, { desc = "New note" })
