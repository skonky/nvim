-- [nfnl] fnl/config/plugins/treesitter.fnl
vim.pack.add({"https://github.com/nvim-treesitter/nvim-treesitter"})
local nvim_treesitter = require("nvim-treesitter")
local lang = {"fennel", "typescript", "tsx", "markdown", "graphql", "css", "html", "lua", "yaml", "javascript"}
local function setup()
  nvim_treesitter.setup({})
  return nvim_treesitter.install(lang)
end
return {setup = setup}
