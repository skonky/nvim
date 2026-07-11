local M = {}

function M.setup(opts)
	require("vimcolorschemes.data").configure(opts)
end

function M.open()
	require("vimcolorschemes.ui").open()
end

function M.refresh()
	require("vimcolorschemes.ui").refresh()
end

vim.api.nvim_create_user_command("Themes", function()
	M.open()
end, { desc = "Interactive theme installer (vimcolorschemes)" })

vim.api.nvim_create_user_command("ThemesRefresh", function()
	M.refresh()
end, { desc = "Refresh vimcolorschemes cache from the live API" })

return M
