-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Drop kitty's window padding while nvim is open, restore it on exit.
-- KITTY_LISTEN_ON is only set when kitty has remote control enabled, so this
-- is also the guard against running outside kitty.
if vim.env.KITTY_LISTEN_ON then
  -- Waits on exit paths: nvim can die before an async job ever reaches kitty.
  local function kitty_padding(value, wait)
    local proc = vim.system({ "kitty", "@", "set-spacing", "padding=" .. value })
    if wait then
      proc:wait(1000)
    end
  end

  local group = vim.api.nvim_create_augroup("kitty_padding", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = function()
      kitty_padding("0")
    end,
  })

  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
      kitty_padding("10", true)
    end,
  })
end
