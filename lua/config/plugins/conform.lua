-- [nfnl] fnl/config/plugins/conform.fnl
vim.pack.add({"https://github.com/stevearc/conform.nvim"})
local conform = require("conform")
local ft = {lua = {"stylua"}, javascript = {"biome"}, javascriptreact = {"biome"}, typescript = {"biome"}, typescriptreact = {"biome"}, fennel = {"fnlfmt"}}
local function on_save(_bufnr)
  return {timeout_ms = 500, lsp_format = "never"}
end
local function setup()
  return conform.setup({formatters_by_ft = ft, format_on_save = on_save})
end
return {setup = setup}
