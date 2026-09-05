-- [nfnl] fnl/config/init.fnl
local options = require("config.options")
local keymaps = require("config.keymaps")
local plugins = require("config.plugins")
require("config.lsp")
require("config.autocmd")
local function setup()
  options.setup()
  plugins.setup()
  return keymaps.setup()
end
return {setup = setup}
