local vim = vim

local M = {}

function M.set_opts(opts)
	for k, v in pairs(opts) do
		vim.opt[k] = v
	end
end

function M.set_globals(globals)
	for k, v in pairs(globals) do
		vim.g[k] = v
	end
end

function M.set_keymap(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
