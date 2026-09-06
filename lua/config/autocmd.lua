-- [nfnl] fnl/config/autocmd.fnl
local function _1_()
  return vim.treesitter.start()
end
vim.api.nvim_create_autocmd("FileType", {pattern = {"lua", "fennel", "typescript", "graphql", "typescriptreact"}, callback = _1_})
local function _2_()
  return vim.hl.on_yank()
end
return vim.api.nvim_create_autocmd("TextYankPost", {desc = "Highlight when yanking text", group = vim.api.nvim_create_augroup("highlight-yank", {clear = true}), callback = _2_})
