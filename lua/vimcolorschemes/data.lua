local M = {}

local cfg = { source = "api" }

function M.configure(opts)
	cfg = vim.tbl_extend("force", cfg, opts or {})
end

function M.swatch_groups()
	if cfg.source == "sqlite" then
		return require("vimcolorschemes.db").SWATCH_GROUPS
	end
	return require("vimcolorschemes.api").SWATCH_GROUPS
end

-- on_done(themes, err). May be synchronous (cache or sqlite) or async (API fetch).
function M.list_themes(on_done)
	if cfg.source == "sqlite" then
		local ok, themes = pcall(require("vimcolorschemes.db").list_themes)
		if not ok then
			return on_done(nil, tostring(themes))
		end
		return on_done(themes, nil)
	end

	local api = require("vimcolorschemes.api")
	local cached = api.read_cache()
	if cached then
		return on_done(cached, nil)
	end
	api.refresh(on_done)
end

function M.palette(theme, background)
	if theme.full_palette and theme.full_palette[background] then
		return theme.full_palette[background]
	end
	-- sqlite fallback
	return require("vimcolorschemes.db").palette(theme.scheme_id, background)
end

function M.refresh(on_done)
	if cfg.source == "sqlite" then
		return on_done(nil, "refresh not applicable for sqlite source")
	end
	require("vimcolorschemes.api").refresh(on_done)
end

return M
