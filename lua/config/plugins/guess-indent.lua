-- [nfnl] fnl/config/plugins/guess-indent.fnl
vim.pack.add({"https://github.com/nmac427/guess-indent.nvim"})
local guess_indent = require("guess-indent")
local function setup()
  return guess_indent.setup({})
end
return {setup = setup}
