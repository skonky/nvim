return {
	handlers = {
		["textDocument/publishDiagnostics"] = function(err, result, ctx)
			-- Skip unused-variable codes when eslint already covers them
			local dominated = { [6133] = true, [6196] = true }
			local bufnr = vim.uri_to_bufnr(result.uri)
			if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
				result.diagnostics = vim.tbl_filter(function(d)
					return not dominated[d.code]
				end, result.diagnostics)
			end
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
}
