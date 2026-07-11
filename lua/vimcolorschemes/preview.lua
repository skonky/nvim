local M = {}

-- (highlight_group, fg_key_in_palette, bg_key_in_palette)
-- Many keys derive from the vimcolorschemes "Vim Vader" sample (vimFuncNameFg etc).
local mapping = {
	{ "Normal", "NormalFg", "NormalBg" },
	{ "NormalNC", "NormalFg", "NormalBg" },
	{ "NormalFloat", "NormalFg", "NormalBg" },
	{ "SignColumn", "NormalFg", "NormalBg" },
	{ "EndOfBuffer", "NormalBg", "NormalBg" },
	{ "NonText", "vimLineCommentFg", "NormalBg" },
	{ "Whitespace", "vimLineCommentFg" },
	{ "LineNr", "LineNrFg", "LineNrBg" },
	{ "CursorLine", nil, "CursorLineBg" },
	{ "CursorLineNr", "CursorLineNrFg", "CursorLineNrBg" },
	{ "Cursor", "CursorFg", "CursorBg" },
	{ "StatusLine", "StatusLineFg", "StatusLineBg" },
	{ "StatusLineNC", "StatusLineFg", "StatusLineBg" },
	{ "WinSeparator", "vimLineCommentFg", "NormalBg" },
	{ "Comment", "vimLineCommentFg" },
	{ "String", "vimStringFg" },
	{ "Character", "vimStringFg" },
	{ "Function", "vimFuncNameFg" },
	{ "Identifier", "vimVarFg" },
	{ "Variable", "vimVarFg" },
	{ "Type", "vimFunctionFg" },
	{ "Keyword", "vimFuncKeyFg" },
	{ "Statement", "vimCommandFg" },
	{ "Conditional", "vimCommandFg" },
	{ "Repeat", "vimCommandFg" },
	{ "Operator", "vimOperFg" },
	{ "Number", "vimNumberFg" },
	{ "Float", "vimNumberFg" },
	{ "Boolean", "vimNumberFg" },
	{ "Constant", "vimNumberFg" },
	{ "Special", "vimSubstFg" },
	{ "SpecialChar", "vimSubstFg" },
	{ "Delimiter", "vimParenSepFg" },
	{ "PreProc", "vimLetFg" },
	{ "Include", "vimLetFg" },
	{ "Title", "vimFuncNameFg" },
	{ "Directory", "vimFuncNameFg" },
	{ "MatchParen", "vimSubstFg", "CursorLineBg" },
	{ "Visual", nil, "CursorLineBg" },
	{ "Pmenu", "NormalFg", "StatusLineBg" },
	{ "PmenuSel", "NormalBg", "vimFuncNameFg" },
	{ "FloatBorder", "vimLineCommentFg", "NormalBg" },
	{ "FloatTitle", "vimFuncNameFg", "NormalBg" },
}

local saved_colorscheme = nil
local applied = false

function M.is_applied()
	return applied
end

local function snapshot()
	if applied then
		return
	end
	saved_colorscheme = vim.g.colors_name
	applied = true
end

function M.apply(palette, background)
	snapshot()
	vim.cmd("hi clear")
	if background then
		vim.o.background = background
	end
	for _, row in ipairs(mapping) do
		local group, fg_key, bg_key = row[1], row[2], row[3]
		local opts = {}
		if fg_key and palette[fg_key] then
			opts.fg = palette[fg_key]
		end
		if bg_key and palette[bg_key] then
			opts.bg = palette[bg_key]
		end
		if next(opts) then
			vim.api.nvim_set_hl(0, group, opts)
		end
	end
end

function M.restore()
	if not applied then
		return
	end
	applied = false
	vim.cmd("hi clear")
	if saved_colorscheme and saved_colorscheme ~= "" then
		pcall(vim.cmd, "colorscheme " .. saved_colorscheme)
	end
	saved_colorscheme = nil
end

-- Drop the snapshot without restoring (used when the user installs and we want
-- the chosen colorscheme to take over).
function M.commit()
	applied = false
	saved_colorscheme = nil
end

return M
