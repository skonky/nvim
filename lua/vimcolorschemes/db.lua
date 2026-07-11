local M = {}

M.path = vim.fn.stdpath("config") .. "/vimcolorschemes.db"

local function run(sql)
	local result = vim.system({ "sqlite3", "-json", M.path, sql }, { text = true }):wait()
	if result.code ~= 0 then
		error("sqlite3 failed: " .. (result.stderr or ""))
	end
	local out = result.stdout or ""
	if out == "" or out:match("^%s*$") then
		return {}
	end
	return vim.json.decode(out)
end

M.run = run

-- Groups used as preview swatches in the picker list.
M.SWATCH_GROUPS = {
	"NormalBg",
	"vimStringFg",
	"vimFuncNameFg",
	"vimCommandFg",
	"vimLineCommentFg",
	"vimNumberFg",
}

function M.list_themes()
	local themes = run([[
		SELECT
			r.id AS repo_id, r.owner_name, r.name AS repo_name,
			r.github_url, r.description, r.stargazers_count AS stars,
			r.has_dark, r.has_light,
			c.id AS scheme_id, c.name AS scheme_name
		FROM repositories r
		JOIN colorschemes c ON c.repository_id = r.id
		WHERE r.is_eligible = 1
		ORDER BY r.stargazers_count DESC;
	]])

	local swatch_in = "'" .. table.concat(M.SWATCH_GROUPS, "','") .. "'"
	local swatches = run(string.format(
		[[SELECT colorscheme_id, background, name, hex_code
		  FROM colorscheme_groups
		  WHERE name IN (%s);]],
		swatch_in
	))

	local by_id = {}
	for _, t in ipairs(themes) do
		t.swatches = { dark = {}, light = {} }
		by_id[t.scheme_id] = t
	end
	for _, row in ipairs(swatches) do
		local t = by_id[row.colorscheme_id]
		if t then
			t.swatches[row.background][row.name] = row.hex_code
		end
	end
	return themes
end

function M.palette(scheme_id, background)
	local rows = run(string.format(
		"SELECT name, hex_code FROM colorscheme_groups WHERE colorscheme_id=%d AND background='%s';",
		scheme_id,
		background
	))
	local palette = {}
	for _, r in ipairs(rows) do
		palette[r.name] = r.hex_code
	end
	return palette
end

return M
