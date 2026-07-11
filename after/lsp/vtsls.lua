return {
	handlers = {
		["textDocument/publishDiagnostics"] = require("biome").filter_diagnostics,
	},
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
		},
	},
}
