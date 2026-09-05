-- [nfnl] fnl/config/plugins/colorscheme.fnl
vim.pack.add({"https://github.com/ThorstenRhau/token"})
local colors = require("token")
local name = "token-meridian"
local opts = {plugins = {all = true}}
local function setup()
  colors.setup(opts)
  return vim.cmd.colorscheme(name)
end
return {setup = setup}
