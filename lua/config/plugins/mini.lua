-- [nfnl] fnl/config/plugins/mini.fnl
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
vim.pack.add({ "https://github.com/nvim-mini/mini-git" })
local mini_pick = require("mini.pick")
local mini_completion = require("mini.completion")
local mini_comment = require("mini.comment")
local mini_diff = require("mini.diff")
local mini_extra = require("mini.extra")
local function setup()
	mini_pick.setup({})
	mini_completion.setup({})
	mini_comment.setup({})
	mini_diff.setup({})
	return mini_extra.setup({})
end
return { setup = setup }
