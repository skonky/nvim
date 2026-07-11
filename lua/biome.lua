local M = {}

local biome_files = { "biome.json", "biome.jsonc" }

--- Check if biome is configured for the given buffer
function M.active(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	return vim.fs.find(biome_files, { path = bufname, upward = true })[1] ~= nil
end

--- LSP handler that drops "Unnecessary"-tagged TS diagnostics when biome handles linting
function M.filter_diagnostics(err, result, ctx)
	local bufnr = vim.uri_to_bufnr(result.uri)
	if #vim.lsp.get_clients({ bufnr = bufnr, name = "biome" }) > 0 then
		result.diagnostics = vim.tbl_filter(function(d)
			-- LSP DiagnosticTag: 1 = Unnecessary, 2 = Deprecated
			if d.tags then
				for _, tag in ipairs(d.tags) do
					if tag == 1 then
						return false
					end
				end
			end
			return true
		end, result.diagnostics)
	end
	return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
end

return M
