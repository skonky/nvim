local M = {}

-- Ghostty has no runtime opacity IPC, so nvim can only toggle whether its
-- background is transparent (lets ghostty's own `background-opacity` show
-- through) or solid. Set `background-opacity` in ghostty.conf to pick the level.
local groups = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"SignColumn",
	"LineNr",
	"EndOfBuffer",
}

-- Persist outside the repo so the choice survives across sessions.
local state_file = vim.fs.joinpath(vim.fn.stdpath("data"), "transparent.txt")

local transparent = false

local function save()
	local fd = io.open(state_file, "w")
	if fd then
		fd:write(transparent and "1" or "0")
		fd:close()
	end
end

local function load()
	local fd = io.open(state_file, "r")
	if not fd then
		return false
	end
	local raw = fd:read("*a")
	fd:close()
	return vim.trim(raw) == "1"
end

local function apply()
	if transparent then
		for _, group in ipairs(groups) do
			vim.api.nvim_set_hl(0, group, { bg = "none" })
		end
	end
	-- When solid, the colorscheme's own backgrounds already apply; nothing to do.
end

function M.toggle()
	transparent = not transparent
	if not transparent then
		-- Re-source the colorscheme to restore the original backgrounds.
		if vim.g.colors_name then
			vim.cmd.colorscheme(vim.g.colors_name)
		end
	else
		apply()
	end
	save()
	vim.notify("Transparent: " .. (transparent and "on" or "off"))
end

function M.setup()
	transparent = load()
	vim.api.nvim_create_user_command("Transparent", M.toggle, { desc = "Toggle transparent background" })
	-- Colorscheme changes reset highlights, so re-assert transparency after each.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("Opacity", {}),
		callback = apply,
	})
	apply()
end

return M
