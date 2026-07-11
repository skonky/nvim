local M = {}

local function pack_dir()
	return vim.fn.stdpath("data") .. "/site/pack/vimcolorschemes/start"
end

local function target(theme)
	return pack_dir() .. "/" .. theme.repo_name
end

function M.is_installed(theme)
	return vim.fn.isdirectory(target(theme)) == 1
end

function M.install(theme, on_done)
	on_done = on_done or function() end
	local dir = target(theme)
	vim.fn.mkdir(pack_dir(), "p")

	if M.is_installed(theme) then
		on_done(true)
		return
	end

	vim.notify(string.format("Cloning %s/%s...", theme.owner_name, theme.repo_name))
	vim.system(
		{ "git", "clone", "--depth=1", theme.github_url, dir },
		{ text = true },
		function(result)
			vim.schedule(function()
				if result.code == 0 then
					vim.notify("Installed " .. theme.repo_name)
					pcall(vim.cmd, "packloadall!")
					on_done(true)
				else
					vim.notify(
						"Install failed: " .. (result.stderr or "unknown error"),
						vim.log.levels.ERROR
					)
					on_done(false)
				end
			end)
		end
	)
end

function M.apply(theme, background)
	if background then
		vim.o.background = background
	end
	local ok, err = pcall(vim.cmd, "colorscheme " .. theme.scheme_name)
	if not ok then
		vim.notify(
			string.format(
				"Couldn't :colorscheme %s — %s",
				theme.scheme_name,
				tostring(err)
			),
			vim.log.levels.WARN
		)
	end
end

return M
