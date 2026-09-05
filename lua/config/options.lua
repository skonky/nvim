-- [nfnl] fnl/config/options.fnl
local leader = " "
local function setup()
  vim.g.mapleader = leader
  vim.g.localleader = leader
  vim.o.number = true
  vim.o.signcolumn = "yes"
  vim.o.cursorline = true
  vim.o.winborder = "rounded"
  vim.o.scrolloff = 10
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.inccommand = "split"
  vim.o.mouse = "a"
  vim.o.breakindent = true
  vim.o.undofile = true
  vim.o.swapfile = false
  vim.o.confirm = true
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.o.expandtab = true
  vim.o.list = true
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.opt.listchars = {tab = "\194\187 ", trail = "\194\183", nbsp = "\226\144\163"}
  vim.opt.foldenable = true
  vim.opt.foldlevelstart = 99
  vim.opt.foldlevel = 99
  vim.opt.foldmethod = "indent"
  vim.opt.completeopt = {"menu", "menuone", "noselect", "popup", "preview"}
  local function _1_()
    vim.o.clipboard = "unnamedplus"
    return nil
  end
  return vim.schedule(_1_)
end
return {setup = setup}
