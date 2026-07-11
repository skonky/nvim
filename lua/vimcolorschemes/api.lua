local M = {}

M.endpoint = "https://vimcolorschemes.com/api/repositories"
M.cache_path = vim.fn.stdpath("cache") .. "/vimcolorschemes.json"
M.cache_ttl = 86400 -- seconds (matches the API's own s-maxage)
M.page_size = 24

local SWATCH_GROUPS = {
	"NormalBg",
	"vimStringFg",
	"vimFuncNameFg",
	"vimCommandFg",
	"vimLineCommentFg",
	"vimNumberFg",
}

M.SWATCH_GROUPS = SWATCH_GROUPS

local function fetch_page(page, cb)
	local url = string.format(
		"%s?sort=trending&background=both&page=%d",
		M.endpoint,
		page
	)
	vim.system(
		{ "curl", "-sSL", "--fail", "-A", "vimcolorschemes.nvim/1.0", url },
		{ text = true },
		function(result)
			if result.code ~= 0 then
				return cb(nil, "curl page " .. page .. ": " .. (result.stderr or "failed"))
			end
			local ok, data = pcall(vim.json.decode, result.stdout)
			if not ok then
				return cb(nil, "json decode page " .. page)
			end
			cb(data, nil)
		end
	)
end

-- vim.json.decode may return userdata (vim.empty_dict / vim.NIL) for empty
-- objects or JSON null — those are truthy, so `or {}` doesn't catch them.
local function tarr(x)
	return type(x) == "table" and x or {}
end

local function normalize(repos)
	local themes = {}
	local next_id = 1
	for _, r in ipairs(tarr(repos)) do
		for _, s in ipairs(tarr(r.vimColorSchemes)) do
			local has_dark, has_light = 0, 0
			for _, bg in ipairs(tarr(s.backgrounds)) do
				if bg == "dark" then
					has_dark = 1
				elseif bg == "light" then
					has_light = 1
				end
			end
			local full = { dark = {}, light = {} }
			for _, bg in ipairs({ "dark", "light" }) do
				for _, c in ipairs(tarr(tarr(s.data)[bg])) do
					if type(c) == "table" and c.name and c.hexCode then
						full[bg][c.name] = c.hexCode
					end
				end
			end
			local swatches = { dark = {}, light = {} }
			for _, bg in ipairs({ "dark", "light" }) do
				for _, name in ipairs(SWATCH_GROUPS) do
					if full[bg][name] then
						swatches[bg][name] = full[bg][name]
					end
				end
			end
			table.insert(themes, {
				scheme_id = next_id,
				owner_name = (r.owner and r.owner.name) or "",
				repo_name = r.name,
				github_url = r.githubURL,
				description = r.description,
				stars = r.stargazersCount or 0,
				has_dark = has_dark,
				has_light = has_light,
				scheme_name = s.name,
				swatches = swatches,
				full_palette = full,
			})
			next_id = next_id + 1
		end
	end
	return themes
end

function M.read_cache()
	if vim.fn.filereadable(M.cache_path) ~= 1 then
		return nil
	end
	local stat = vim.uv and vim.uv.fs_stat(M.cache_path) or vim.loop.fs_stat(M.cache_path)
	if not stat then
		return nil
	end
	if (os.time() - stat.mtime.sec) > M.cache_ttl then
		return nil
	end
	local content = table.concat(vim.fn.readfile(M.cache_path), "\n")
	if content == "" then
		return nil
	end
	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data
end

local function write_cache(themes)
	vim.fn.mkdir(vim.fn.fnamemodify(M.cache_path, ":h"), "p")
	local ok, encoded = pcall(vim.json.encode, themes)
	if ok then
		vim.fn.writefile({ encoded }, M.cache_path)
	end
end

function M.refresh(on_done)
	if vim.fn.executable("curl") ~= 1 then
		return on_done(nil, "curl not on PATH")
	end
	fetch_page(1, function(first, err)
		if err then
			return vim.schedule(function() on_done(nil, err) end)
		end
		local count = first.count or #(first.repositories or {})
		local total_pages = math.max(1, math.ceil(count / M.page_size))
		local pages = { [1] = first.repositories or {} }

		if total_pages == 1 then
			local themes = normalize(pages[1])
			vim.schedule(function()
				write_cache(themes)
				on_done(themes, nil)
			end)
			return
		end

		local pending = total_pages - 1
		local errored = false
		for p = 2, total_pages do
			fetch_page(p, function(data, perr)
				if errored then
					return
				end
				if perr then
					errored = true
					return vim.schedule(function() on_done(nil, perr) end)
				end
				pages[p] = data.repositories or {}
				pending = pending - 1
				if pending == 0 then
					local flat = {}
					for i = 1, total_pages do
						for _, r in ipairs(pages[i] or {}) do
							table.insert(flat, r)
						end
					end
					local themes = normalize(flat)
					vim.schedule(function()
						write_cache(themes)
						on_done(themes, nil)
					end)
				end
			end)
		end
	end)
end

return M
