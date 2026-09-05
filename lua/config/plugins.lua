-- [nfnl] fnl/config/plugins.fnl
local oil = require("config.plugins.oil")
local mini = require("config.plugins.mini")
local treesitter = require("config.plugins.treesitter")
local conform = require("config.plugins.conform")
local guess_indent = require("config.plugins.guess-indent")
local rainbow = require(".config.plugins.rainbow")
local colors = require(".config.plugins.colorscheme")
local function setup()
  oil.setup()
  treesitter.setup()
  mini.setup()
  conform.setup()
  rainbow.setup()
  colors.setup()
  return guess_indent.setup()
end
return {setup = setup}
