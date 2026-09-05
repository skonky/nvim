-- [nfnl] fnl/config/plugins/rainbow.fnl
vim.pack.add({"https://github.com/hiphish/rainbow-delimiters.nvim"})
local rainbow = require("rainbow-delimiters.setup")
local function setup()
  return rainbow.setup({})
end
return {setup = setup}
