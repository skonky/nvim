-- [nfnl] fnl/config/autocmd.fnl
local function _1_()
  return vim.treesitter.start()
end
return vim.api.nvim_create_autocmd("FileType", {pattern = {"lua", "fennel"}, callback = _1_})
