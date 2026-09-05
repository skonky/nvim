-- [nfnl] fnl/config/plugins/oil.fnl
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
local oil = require("oil")
local function setup()
	return oil.setup({})
end
return { setup = setup }
