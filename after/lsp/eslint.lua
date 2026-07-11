local biome = require("biome")

local root_markers = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

return {
	root_markers = root_markers,
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, root_markers)
		if not root then
			return
		end
		-- Don't attach eslint when biome owns the project
		if not biome.active(bufnr) then
			on_dir(root)
		end
	end,
	reuse_client = function(client, config)
		if not config.root_dir then
			return false
		end
		return client.root_dir == config.root_dir
	end,
	settings = {
		workingDirectories = { mode = "auto" },
	},
}
