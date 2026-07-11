-- chroma: pywal for macOS.
--
-- Reads the current desktop wallpaper, extracts a palette from it, and builds a
-- neovim colorscheme that adapts to it. Dependency-free: uses macOS built-ins
-- only (`osascript` to find the wallpaper, `sips` to downscale it to a tiny
-- BMP), then does all colour work in pure Lua so there's no pywal/imagemagick
-- to install.

local M = {}

M.config = {
	-- "auto" follows the macOS system appearance (like the old neotone system
	-- mode); "dark" / "light" pin it. The same wallpaper yields a dark or light
	-- palette depending on this.
	mode = "auto",
	-- Longest edge sips downscales the wallpaper to before we read pixels. Small
	-- keeps extraction fast; the palette barely changes above ~128.
	sample_size = 128,
	-- Regenerate when you alt-tab back into nvim and the wallpaper (or, in auto
	-- mode, the system appearance) changed.
	auto_refresh = true,
	notify = false,
	-- A wallpaper's darkest/lightest colours aren't guaranteed usable as
	-- bg/fg, so we clamp them into these luminance bounds (0-255). Light mode
	-- uses the mirror of these (255 - x).
	bg_lum_max = 42,
	fg_lum_min = 185,
}

-- Neutral scheme shown before the first generation finishes (and on non-macOS,
-- or if extraction ever fails) so `:colorscheme chroma` is never broken.
local DEFAULT = {
	mode = "dark",
	bg = "#1a1b21",
	bg_alt = "#22232b",
	fg = "#c8ccd4",
	fg_dim = "#9498a1",
	gray = "#5c606b",
	gray_dim = "#3a3d45",
	accent = { "#61afef", "#c678dd", "#98c379", "#e5c07b", "#56b6c2" },
	error = "#e06c75",
	warn = "#e5c07b",
	ok = "#98c379",
	info = "#61afef",
	hint = "#56b6c2",
	magenta = "#c678dd",
}

local cache_file = vim.fs.joinpath(vim.fn.stdpath("cache"), "chroma.json")
local bmp_file = vim.fs.joinpath(vim.fn.stdpath("cache"), "chroma.bmp")

-- Guards against overlapping generations (setup + colorscheme both fire one).
local busy = false

-- ============================================================================
-- COLOUR MATH
-- ============================================================================

local function clamp(n, lo, hi)
	return math.max(lo, math.min(hi, n))
end

local function round(n)
	return math.floor(n + 0.5)
end

local function to_hex(c)
	return string.format(
		"#%02x%02x%02x",
		clamp(round(c.r), 0, 255),
		clamp(round(c.g), 0, 255),
		clamp(round(c.b), 0, 255)
	)
end

local function from_hex(hex)
	return {
		r = tonumber(hex:sub(2, 3), 16),
		g = tonumber(hex:sub(4, 5), 16),
		b = tonumber(hex:sub(6, 7), 16),
	}
end

-- Perceptual luminance (Rec. 709), 0-255.
local function luminance(c)
	return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
end

-- Blend c1 toward c2 by t (0-1).
local function blend(c1, c2, t)
	return {
		r = c1.r + (c2.r - c1.r) * t,
		g = c1.g + (c2.g - c1.g) * t,
		b = c1.b + (c2.b - c1.b) * t,
	}
end

local BLACK = { r = 0, g = 0, b = 0 }
local WHITE = { r = 255, g = 255, b = 255 }

local function darken(c, t)
	return blend(c, BLACK, t)
end

local function lighten(c, t)
	return blend(c, WHITE, t)
end

local function rgb_to_hsv(c)
	local r, g, b = c.r / 255, c.g / 255, c.b / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local d = max - min
	local h = 0
	if d ~= 0 then
		if max == r then
			h = ((g - b) / d) % 6
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h * 60
	end
	local s = max == 0 and 0 or d / max
	return h, s, max
end

local function hsv_to_rgb(h, s, v)
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	local r, g, b
	if h < 60 then
		r, g, b = c, x, 0
	elseif h < 120 then
		r, g, b = x, c, 0
	elseif h < 180 then
		r, g, b = 0, c, x
	elseif h < 240 then
		r, g, b = 0, x, c
	elseif h < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return { r = (r + m) * 255, g = (g + m) * 255, b = (b + m) * 255 }
end

local function hue_dist(a, b)
	local d = math.abs(a - b) % 360
	return math.min(d, 360 - d)
end

-- ============================================================================
-- BMP PARSING  (sips emits uncompressed 24-bit BMP, sometimes top-down)
-- ============================================================================

local function read_u32(s, off)
	local b1, b2, b3, b4 = s:byte(off, off + 3)
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function read_i32(s, off)
	local v = read_u32(s, off)
	if v >= 0x80000000 then
		v = v - 0x100000000
	end
	return v
end

local function read_bmp_pixels(path)
	local fd = assert(io.open(path, "rb"))
	local data = fd:read("*a")
	fd:close()

	assert(data:sub(1, 2) == "BM", "not a BMP")
	local pix_off = read_u32(data, 11) -- header field is 0-based; string is 1-based
	local width = read_i32(data, 19)
	local height = read_i32(data, 23)
	local bpp = data:byte(29) + data:byte(30) * 256
	local bytes_pp = bpp / 8
	-- Rows are padded up to a 4-byte boundary.
	local row_size = math.floor((bpp * width + 31) / 32) * 4
	local rows = math.abs(height)

	local pixels = {}
	for row = 0, rows - 1 do
		local base = pix_off + row * row_size + 1
		for col = 0, width - 1 do
			local p = base + col * bytes_pp
			-- BMP stores BGR.
			pixels[#pixels + 1] = { b = data:byte(p), g = data:byte(p + 1), r = data:byte(p + 2) }
		end
	end
	return pixels
end

-- ============================================================================
-- MEDIAN CUT  (quantise pixels down to N dominant colours)
-- ============================================================================

local function bucket_average(bucket)
	local r, g, b = 0, 0, 0
	for _, p in ipairs(bucket) do
		r, g, b = r + p.r, g + p.g, b + p.b
	end
	local n = #bucket
	-- w = how much of the image this colour covers, so the palette can favour
	-- dominant colours over incidental ones.
	return { r = r / n, g = g / n, b = b / n, w = n }
end

-- Widest channel range decides which bucket to split and along which axis.
local function widest_channel(bucket)
	local lo = { r = 255, g = 255, b = 255 }
	local hi = { r = 0, g = 0, b = 0 }
	for _, p in ipairs(bucket) do
		for _, ch in ipairs({ "r", "g", "b" }) do
			if p[ch] < lo[ch] then
				lo[ch] = p[ch]
			end
			if p[ch] > hi[ch] then
				hi[ch] = p[ch]
			end
		end
	end
	local rr, rg, rb = hi.r - lo.r, hi.g - lo.g, hi.b - lo.b
	local range = math.max(rr, rg, rb)
	local ch = (range == rr) and "r" or (range == rg) and "g" or "b"
	return ch, range
end

local function median_cut(pixels, count)
	local buckets = { pixels }
	while #buckets < count do
		-- Split the bucket with the widest colour spread.
		local target, target_ch, best = nil, nil, -1
		for i, bucket in ipairs(buckets) do
			if #bucket > 1 then
				local ch, range = widest_channel(bucket)
				if range > best then
					best, target, target_ch = range, i, ch
				end
			end
		end
		if not target then
			break -- every bucket is a single pixel
		end
		local bucket = buckets[target]
		table.sort(bucket, function(a, b)
			return a[target_ch] < b[target_ch]
		end)
		local mid = math.floor(#bucket / 2)
		local lo, hi = {}, {}
		for i, p in ipairs(bucket) do
			if i <= mid then
				lo[#lo + 1] = p
			else
				hi[#hi + 1] = p
			end
		end
		buckets[target] = lo
		buckets[#buckets + 1] = hi
	end

	local colors = {}
	for _, bucket in ipairs(buckets) do
		colors[#colors + 1] = bucket_average(bucket)
	end
	return colors
end

-- ============================================================================
-- PALETTE
-- ============================================================================

-- Fit an accent's brightness/saturation so it reads against the background:
-- brighter on dark, darker and a touch more saturated on light.
local function fit_accent(h, s, v, light)
	if light then
		return hsv_to_rgb(h, math.max(s, 0.5), math.min(v, 0.62))
	end
	return hsv_to_rgb(h, clamp(s, 0.45, 1), clamp(v, 0.62, 0.92))
end

-- Pull the wallpaper's *actual* dominant saturated colours (ordered by how much
-- of the image they cover) instead of forcing a fixed rainbow. Missing slots
-- are filled by rotating an existing hue, so every accent still belongs to the
-- wallpaper's family. This is what makes the theme look like the wallpaper.
local function extract_accents(colors, light)
	local vivid = {}
	for _, c in ipairs(colors) do
		local h, s, v = rgb_to_hsv(c)
		if s > 0.2 and v > 0.18 then
			vivid[#vivid + 1] = { h = h, s = s, v = v, w = c.w or 1 }
		end
	end
	table.sort(vivid, function(a, b)
		return a.w > b.w
	end)

	-- Keep the highest-coverage colour per hue cluster.
	local picked = {}
	for _, cd in ipairs(vivid) do
		local dup = false
		for _, q in ipairs(picked) do
			if hue_dist(cd.h, q.h) < 32 then
				dup = true
				break
			end
		end
		if not dup then
			picked[#picked + 1] = cd
		end
		if #picked >= 6 then
			break
		end
	end

	-- Syntax needs a few distinct colours; if the wallpaper is near-monochrome,
	-- rotate the dominant hue(s) to invent in-family accents.
	local base = #picked
	if base > 0 then
		local offsets = { 28, -28, 55, -55, 82, -82 }
		local i, guard = 0, 0
		while #picked < 5 and guard < 40 do
			guard = guard + 1
			local src = picked[(i % base) + 1]
			local nh = (src.h + offsets[(i % #offsets) + 1]) % 360
			i = i + 1
			local ok = true
			for _, q in ipairs(picked) do
				if hue_dist(nh, q.h) < 16 then
					ok = false
					break
				end
			end
			if ok then
				picked[#picked + 1] = { h = nh, s = src.s, v = src.v }
			end
		end
	end

	local out = {}
	for _, pk in ipairs(picked) do
		out[#out + 1] = to_hex(fit_accent(pk.h, pk.s, pk.v, light))
	end
	return out, picked
end

-- A semantically-hued colour (for diagnostics/git) tinted with the wallpaper's
-- character: borrow a nearby wallpaper colour's saturation/value if one exists,
-- else synthesise at the target hue.
local function semantic_color(picked, target_h, light)
	local best, best_d
	for _, pk in ipairs(picked) do
		local d = hue_dist(pk.h, target_h)
		if not best_d or d < best_d then
			best, best_d = pk, d
		end
	end
	local s, v = 0.55, light and 0.55 or 0.78
	if best and best_d < 45 then
		s, v = best.s, best.v
	end
	return to_hex(fit_accent(target_h, s, v, light))
end

-- Background from the most dominant *dark* colour (keeping its hue, lightly
-- desaturated) so bg carries the wallpaper's tint; foreground from the most
-- dominant colour at the other end. Light mode mirrors this. Both clamp to the
-- luminance bounds.
local function pick_bg_fg(colors, light)
	local byLum = {}
	for _, c in ipairs(colors) do
		byLum[#byLum + 1] = c
	end
	table.sort(byLum, function(a, b)
		return luminance(a) < luminance(b)
	end)

	local dark_pool, light_pool = {}, {}
	for _, c in ipairs(colors) do
		if luminance(c) < 110 then
			dark_pool[#dark_pool + 1] = c
		end
		if luminance(c) > 150 then
			light_pool[#light_pool + 1] = c
		end
	end
	if #dark_pool == 0 then
		dark_pool = { byLum[1] }
	end
	if #light_pool == 0 then
		light_pool = { byLum[#byLum] }
	end
	local by_weight = function(a, b)
		return (a.w or 1) > (b.w or 1)
	end
	table.sort(dark_pool, by_weight)
	table.sort(light_pool, by_weight)

	local bg_src = light and light_pool[1] or dark_pool[1]
	local fg_src = light and dark_pool[1] or light_pool[1]
	local bh, bs, bv = rgb_to_hsv(bg_src)
	local fh, fs, fv = rgb_to_hsv(fg_src)
	local bg = hsv_to_rgb(bh, math.min(bs, light and 0.16 or 0.4), bv)
	local fg = hsv_to_rgb(fh, math.min(fs, light and 0.22 or 0.14), fv)

	if light then
		for _ = 1, 12 do
			if luminance(bg) >= 255 - M.config.bg_lum_max then
				break
			end
			bg = lighten(bg, 0.15)
		end
		for _ = 1, 12 do
			if luminance(fg) <= 255 - M.config.fg_lum_min then
				break
			end
			fg = darken(fg, 0.15)
		end
	else
		for _ = 1, 12 do
			if luminance(bg) <= M.config.bg_lum_max then
				break
			end
			bg = darken(bg, 0.15)
		end
		for _ = 1, 12 do
			if luminance(fg) >= M.config.fg_lum_min then
				break
			end
			fg = lighten(fg, 0.15)
		end
	end
	return bg, fg
end

local function build_palette(colors, mode)
	local light = mode == "light"
	local bg, fg = pick_bg_fg(colors, light)

	local accents, picked = extract_accents(colors, light)
	-- Near-monochrome wallpaper: fall back to a fg/bg ramp so syntax keeps some
	-- structure instead of collapsing to a single colour.
	if #accents == 0 then
		accents = {
			to_hex(blend(fg, bg, 0.15)),
			to_hex(blend(fg, bg, 0.35)),
			to_hex(blend(fg, bg, 0.05)),
			to_hex(blend(fg, bg, 0.5)),
			to_hex(blend(fg, bg, 0.25)),
		}
	end
	while #accents < 5 do
		accents[#accents + 1] = accents[(#accents % #accents) + 1]
	end

	return {
		mode = light and "light" or "dark",
		bg = to_hex(bg),
		bg_alt = to_hex(light and darken(bg, 0.05) or lighten(bg, 0.06)),
		fg = to_hex(fg),
		fg_dim = to_hex(blend(fg, bg, 0.3)),
		gray = to_hex(blend(bg, fg, 0.42)),
		gray_dim = to_hex(blend(bg, fg, 0.24)),
		accent = accents, -- wallpaper-faithful, ordered by dominance; drives syntax
		-- Semantic hues kept correct so diagnostics/git/terminal read right.
		error = semantic_color(picked, 0, light),
		warn = semantic_color(picked, 45, light),
		ok = semantic_color(picked, 125, light),
		info = semantic_color(picked, 215, light),
		hint = semantic_color(picked, 190, light),
		magenta = semantic_color(picked, 300, light),
	}
end

-- ============================================================================
-- APPLY
-- ============================================================================

-- The ANSI "bright" variants pull away from the background: lighter on dark,
-- darker on light.
local function bright(hex, light)
	local c = from_hex(hex)
	return to_hex(light and darken(c, 0.18) or lighten(c, 0.18))
end

local function apply(p)
	local light = p.mode == "light"
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.background = light and "light" or "dark"
	vim.g.colors_name = "chroma"

	-- Accents are ordered by dominance; cycle through them for syntax so the code
	-- is painted in the wallpaper's own colours.
	local a = p.accent
	local function acc(i)
		return a[((i - 1) % #a) + 1]
	end

	-- ANSI 0-15 for :terminal and terminal-aware plugins. These stay semantically
	-- hued (red/green/…) so terminal apps look right, even where the wallpaper
	-- lacks that hue.
	local term = {
		p.bg,
		p.error,
		p.ok,
		p.warn,
		p.info,
		p.magenta,
		p.hint,
		p.fg_dim,
		p.gray,
		bright(p.error, light),
		bright(p.ok, light),
		bright(p.warn, light),
		bright(p.info, light),
		bright(p.magenta, light),
		bright(p.hint, light),
		p.fg,
	}
	for i, hex in ipairs(term) do
		vim.g["terminal_color_" .. (i - 1)] = hex
	end

	local sel = to_hex(blend(from_hex(p.bg), from_hex(acc(1)), 0.22))

	-- CursorLine must stay visible against Normal on any wallpaper, so blend the
	-- background toward the foreground until the luminance gap is clearly readable
	-- rather than using a fixed (sometimes invisible) ratio.
	local bg_rgb, fg_rgb = from_hex(p.bg), from_hex(p.fg)
	local cursorline_rgb, t = bg_rgb, 0.08
	while t <= 0.45 do
		cursorline_rgb = blend(bg_rgb, fg_rgb, t)
		if math.abs(luminance(cursorline_rgb) - luminance(bg_rgb)) >= 18 then
			break
		end
		t = t + 0.03
	end
	local cursorline = to_hex(cursorline_rgb)

	-- Docs floats (hover/signature) sit one elevation above the cursorline, so
	-- push their panel a clear step further toward the foreground than the line
	-- highlight; otherwise the two read as the same shade.
	local float_panel_rgb = blend(bg_rgb, fg_rgb, math.min(t + 0.14, 0.5))
	local float_panel = to_hex(float_panel_rgb)

	-- The current line *inside* a docs float, a readable step above the panel.
	local float_line_rgb, t2 = float_panel_rgb, 0.1
	while t2 <= 0.5 do
		float_line_rgb = blend(float_panel_rgb, fg_rgb, t2)
		if math.abs(luminance(float_line_rgb) - luminance(float_panel_rgb)) >= 16 then
			break
		end
		t2 = t2 + 0.03
	end
	local float_line = to_hex(float_line_rgb)

	local function hi(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	local groups = {
		-- Editor UI
		Normal = { fg = p.fg, bg = p.bg },
		NormalNC = { fg = p.fg, bg = p.bg },
		NormalFloat = { fg = p.fg, bg = p.bg_alt },
		FloatBorder = { fg = p.gray, bg = p.bg_alt },
		-- Dedicated groups for LSP docs floats (see lua/lsp.lua); a solid panel
		-- clearly elevated above both Normal and CursorLine.
		HoverDoc = { fg = p.fg, bg = float_panel },
		HoverDocBorder = { fg = p.gray, bg = float_panel },
		HoverDocLine = { bg = float_line },
		FloatTitle = { fg = acc(1), bg = p.bg_alt, bold = true },
		ColorColumn = { bg = p.bg_alt },
		Cursor = { fg = p.bg, bg = p.fg },
		CursorLine = { bg = cursorline },
		CursorColumn = { bg = cursorline },
		CursorLineNr = { fg = p.fg, bold = true },
		LineNr = { fg = p.gray_dim },
		SignColumn = { bg = p.bg },
		Folded = { fg = p.gray, bg = p.bg_alt },
		FoldColumn = { fg = p.gray_dim },
		VertSplit = { fg = p.bg_alt },
		WinSeparator = { fg = p.bg_alt },
		EndOfBuffer = { fg = p.bg },
		Visual = { bg = sel },
		Search = { fg = p.bg, bg = acc(1) },
		IncSearch = { fg = p.bg, bg = acc(2) },
		CurSearch = { fg = p.bg, bg = acc(2) },
		MatchParen = { fg = acc(1), bg = p.gray_dim, bold = true },
		Whitespace = { fg = p.gray_dim },
		NonText = { fg = p.gray_dim },
		SpecialKey = { fg = p.gray_dim },
		Directory = { fg = acc(1) },
		Title = { fg = acc(1), bold = true },
		ErrorMsg = { fg = p.error },
		WarningMsg = { fg = p.warn },
		ModeMsg = { fg = p.ok },
		MoreMsg = { fg = p.ok },
		Question = { fg = p.ok },
		WinBar = { fg = p.fg, bg = p.bg },
		WinBarNC = { fg = p.gray, bg = p.bg },

		-- Menus / statusline / tabs
		Pmenu = { fg = p.fg, bg = p.bg_alt },
		PmenuSel = { fg = p.bg, bg = acc(1), bold = true },
		PmenuSbar = { bg = p.bg_alt },
		PmenuThumb = { bg = p.gray },
		StatusLine = { fg = p.fg, bg = p.bg_alt },
		StatusLineNC = { fg = p.gray, bg = p.bg },
		TabLine = { fg = p.gray, bg = p.bg_alt },
		TabLineSel = { fg = p.bg, bg = acc(1), bold = true },
		TabLineFill = { bg = p.bg },

		-- Syntax (painted from the wallpaper's dominant colours)
		Comment = { fg = p.gray, italic = true },
		Constant = { fg = acc(4) },
		String = { fg = acc(3) },
		Character = { fg = acc(3) },
		Number = { fg = acc(4) },
		Boolean = { fg = acc(4) },
		Float = { fg = acc(4) },
		Identifier = { fg = p.fg },
		Function = { fg = acc(2) },
		Statement = { fg = acc(1) },
		Conditional = { fg = acc(1) },
		Repeat = { fg = acc(1) },
		Label = { fg = acc(1) },
		Operator = { fg = p.fg_dim },
		Keyword = { fg = acc(1) },
		Exception = { fg = acc(1) },
		PreProc = { fg = acc(5) },
		Include = { fg = acc(5) },
		Define = { fg = acc(5) },
		Macro = { fg = acc(5) },
		Type = { fg = acc(5) },
		StorageClass = { fg = acc(5) },
		Structure = { fg = acc(5) },
		Typedef = { fg = acc(5) },
		Special = { fg = acc(3) },
		SpecialChar = { fg = acc(3) },
		Delimiter = { fg = p.fg_dim },
		Tag = { fg = acc(1) },
		Underlined = { fg = acc(2), underline = true },
		Error = { fg = p.error },
		Todo = { fg = p.bg, bg = acc(4), bold = true },

		-- Treesitter captures. Set explicitly (rather than leaning on default
		-- @-> base links) so each carries an intentional wallpaper colour.
		["@variable"] = { fg = p.fg },
		["@variable.builtin"] = { fg = acc(1) },
		["@variable.parameter"] = { fg = p.fg },
		["@variable.member"] = { fg = acc(4) },
		["@property"] = { fg = acc(4) },
		["@field"] = { fg = acc(4) },
		["@constant"] = { fg = acc(4) },
		["@constant.builtin"] = { fg = acc(4) },
		["@constant.macro"] = { fg = acc(4) },
		["@module"] = { fg = acc(5) },
		["@namespace"] = { fg = acc(5) },
		["@label"] = { fg = acc(1) },
		["@string"] = { fg = acc(3) },
		["@string.escape"] = { fg = p.magenta },
		["@string.special"] = { fg = acc(3) },
		["@string.regexp"] = { fg = acc(3) },
		["@character"] = { fg = acc(3) },
		["@number"] = { fg = acc(4) },
		["@number.float"] = { fg = acc(4) },
		["@boolean"] = { fg = acc(4) },
		["@function"] = { fg = acc(2) },
		["@function.call"] = { fg = acc(2) },
		["@function.builtin"] = { fg = acc(2) },
		["@function.method"] = { fg = acc(2) },
		["@function.method.call"] = { fg = acc(2) },
		["@constructor"] = { fg = acc(5) },
		["@keyword"] = { fg = acc(1) },
		["@keyword.function"] = { fg = acc(1) },
		["@keyword.operator"] = { fg = acc(1) },
		["@keyword.return"] = { fg = acc(1) },
		["@keyword.conditional"] = { fg = acc(1) },
		["@keyword.repeat"] = { fg = acc(1) },
		["@keyword.exception"] = { fg = acc(1) },
		["@keyword.import"] = { fg = acc(5) },
		["@type"] = { fg = acc(5) },
		["@type.builtin"] = { fg = acc(5) },
		["@type.definition"] = { fg = acc(5) },
		["@attribute"] = { fg = acc(2) },
		["@operator"] = { fg = p.fg_dim },
		["@punctuation.delimiter"] = { fg = p.fg_dim },
		["@punctuation.bracket"] = { fg = p.fg_dim },
		["@punctuation.special"] = { fg = p.magenta },
		["@tag"] = { fg = acc(1) },
		["@tag.builtin"] = { fg = acc(1) },
		["@tag.attribute"] = { fg = acc(4) },
		["@tag.delimiter"] = { fg = p.fg_dim },
		["@comment"] = { fg = p.gray, italic = true },
		["@comment.documentation"] = { fg = p.gray, italic = true },
		["@comment.error"] = { fg = p.error },
		["@comment.warning"] = { fg = p.warn },
		["@comment.todo"] = { fg = p.bg, bg = acc(4), bold = true },
		["@comment.note"] = { fg = p.info },
		["@markup.heading"] = { fg = acc(2), bold = true },
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.link"] = { fg = acc(5), underline = true },
		["@markup.link.url"] = { fg = acc(3), underline = true },
		["@markup.raw"] = { fg = acc(3) },
		["@markup.list"] = { fg = acc(1) },
		["@markup.quote"] = { fg = p.gray, italic = true },
		["@diff.plus"] = { fg = p.ok },
		["@diff.minus"] = { fg = p.error },
		["@diff.delta"] = { fg = p.warn },

		-- LSP semantic tokens. vtsls sends these ~1s after open; mirroring the
		-- treesitter colours above keeps that pass from visibly recolouring code.
		["@lsp.type.variable"] = { fg = p.fg },
		["@lsp.type.parameter"] = { fg = p.fg },
		["@lsp.type.property"] = { fg = acc(4) },
		["@lsp.type.enumMember"] = { fg = acc(4) },
		["@lsp.type.function"] = { fg = acc(2) },
		["@lsp.type.method"] = { fg = acc(2) },
		["@lsp.type.namespace"] = { fg = acc(5) },
		["@lsp.type.class"] = { fg = acc(5) },
		["@lsp.type.interface"] = { fg = acc(5) },
		["@lsp.type.enum"] = { fg = acc(5) },
		["@lsp.type.type"] = { fg = acc(5) },
		["@lsp.type.typeParameter"] = { fg = acc(5) },
		["@lsp.type.decorator"] = { fg = acc(2) },
		["@lsp.type.keyword"] = { fg = acc(1) },
		["@lsp.type.string"] = { fg = acc(3) },
		["@lsp.type.number"] = { fg = acc(4) },
		["@lsp.type.comment"] = { fg = p.gray, italic = true },

		-- Diagnostics
		DiagnosticError = { fg = p.error },
		DiagnosticWarn = { fg = p.warn },
		DiagnosticInfo = { fg = p.info },
		DiagnosticHint = { fg = p.hint },
		DiagnosticOk = { fg = p.ok },
		DiagnosticUnderlineError = { sp = p.error, undercurl = true },
		DiagnosticUnderlineWarn = { sp = p.warn, undercurl = true },
		DiagnosticUnderlineInfo = { sp = p.info, undercurl = true },
		DiagnosticUnderlineHint = { sp = p.hint, undercurl = true },

		-- Git / diff
		DiffAdd = { fg = p.ok, bg = to_hex(blend(from_hex(p.bg), from_hex(p.ok), 0.15)) },
		DiffChange = { fg = p.warn, bg = to_hex(blend(from_hex(p.bg), from_hex(p.warn), 0.12)) },
		DiffDelete = { fg = p.error, bg = to_hex(blend(from_hex(p.bg), from_hex(p.error), 0.15)) },
		DiffText = { fg = p.bg, bg = p.warn },
		Added = { fg = p.ok },
		Changed = { fg = p.warn },
		Removed = { fg = p.error },
		GitSignsAdd = { fg = p.ok },
		GitSignsChange = { fg = p.warn },
		GitSignsDelete = { fg = p.error },
	}

	for group, opts in pairs(groups) do
		hi(group, opts)
	end

	vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "chroma" })
end

-- ============================================================================
-- CACHE + ORCHESTRATION
-- ============================================================================

local function read_cache()
	local fd = io.open(cache_file, "r")
	if not fd then
		return nil
	end
	local raw = fd:read("*a")
	fd:close()
	local ok, data = pcall(vim.json.decode, raw)
	return ok and data or nil
end

local function write_cache(palette, wallpaper)
	palette._wallpaper = wallpaper
	local fd = io.open(cache_file, "w")
	if fd then
		fd:write(vim.json.encode(palette))
		fd:close()
	end
end

-- osascript can be slow (~50ms) and blocks, so always fetch the path async.
local function get_wallpaper(cb)
	if vim.fn.has("mac") == 0 then
		cb(nil)
		return
	end
	vim.system(
		{ "osascript", "-e", 'tell application "System Events" to get picture of current desktop' },
		{ text = true },
		function(res)
			local path = res.code == 0 and vim.trim(res.stdout or "") or ""
			cb(path ~= "" and path or nil)
		end
	)
end

-- Ask System Events for the appearance. `defaults read -g AppleInterfaceStyle`
-- is unreliable from a child process (cfprefsd caches per-session and the read
-- can disagree with reality), whereas this AppleScript property is consistent
-- and matches what we already use to fetch the wallpaper.
local function system_appearance(cb)
	if vim.fn.has("mac") == 0 then
		cb("dark")
		return
	end
	vim.system(
		{ "osascript", "-e", 'tell application "System Events" to tell appearance preferences to return dark mode' },
		{ text = true },
		function(res)
			local dark = res.code == 0 and vim.trim(res.stdout or "") == "true"
			cb(dark and "dark" or "light")
		end
	)
end

-- Resolve the effective mode: honour a pinned mode, else ask the system.
local function resolve_mode(cb)
	local m = M.config.mode
	if m == "dark" or m == "light" then
		cb(m)
	else
		system_appearance(cb)
	end
end

-- Latest queued request while a generation is in flight, so a toggle/regen
-- fired mid-run (e.g. right after startup) coalesces instead of being dropped.
local pending = nil

-- Generate a fresh palette from the current wallpaper and apply it.
function M.generate(opts)
	opts = opts or {}
	if busy then
		pending = opts -- keep only the latest; config.mode holds the desired mode
		return
	end
	busy = true

	local function finish()
		busy = false
		if pending then
			local p = pending
			pending = nil
			M.generate(p)
		end
	end

	resolve_mode(function(mode)
		get_wallpaper(function(wallpaper)
			if not wallpaper then
				if opts.notify then
					vim.schedule(function()
						vim.notify("chroma: could not read wallpaper", vim.log.levels.WARN)
					end)
				end
				finish()
				return
			end

			vim.system({
				"sips",
				"-Z",
				tostring(M.config.sample_size),
				"-s",
				"format",
				"bmp",
				wallpaper,
				"--out",
				bmp_file,
			}, { text = false }, function(res)
				vim.schedule(function()
					if res.code ~= 0 then
						if opts.notify then
							vim.notify("chroma: sips failed on wallpaper", vim.log.levels.WARN)
						end
						finish()
						return
					end
					local ok, palette = pcall(function()
						return build_palette(median_cut(read_bmp_pixels(bmp_file), 16), mode)
					end)
					if not ok then
						vim.notify("chroma: extraction failed: " .. tostring(palette), vim.log.levels.ERROR)
						finish()
						return
					end
					write_cache(palette, wallpaper)
					apply(palette)
					if opts.notify then
						vim.notify("chroma: theme updated (" .. mode .. ")")
					end
					finish()
				end)
			end)
		end)
	end)
end

-- Entry point for `colors/chroma.lua`. Applies instantly from cache (or the
-- neutral default), then refreshes from the live wallpaper in the background.
function M.load()
	local cached = read_cache()
	apply(cached or DEFAULT)
	M.generate()
end

-- Pin the mode ("dark" | "light" | "auto") and regenerate.
function M.set_mode(mode)
	M.config.mode = mode
	M.generate({ notify = true })
end

-- Flip between dark and light (pins the mode, leaving auto).
function M.toggle()
	local cached = read_cache()
	local current = (cached and cached.mode) or "dark"
	M.set_mode(current == "dark" and "light" or "dark")
end

function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})

	vim.api.nvim_create_user_command("Chroma", function(args)
		local mode = vim.trim(args.args)
		if mode == "dark" or mode == "light" or mode == "auto" then
			M.set_mode(mode)
		else
			M.generate({ notify = true })
		end
	end, {
		nargs = "?",
		complete = function()
			return { "dark", "light", "auto" }
		end,
		desc = "Regenerate colorscheme from wallpaper; optional dark|light|auto",
	})

	if M.config.auto_refresh then
		vim.api.nvim_create_autocmd("FocusGained", {
			group = vim.api.nvim_create_augroup("Chroma", {}),
			callback = function()
				-- Regenerate if the wallpaper changed, or (in auto mode) if the
				-- system flipped between light and dark while nvim was unfocused.
				get_wallpaper(function(wallpaper)
					resolve_mode(function(mode)
						local cached = read_cache()
						local wallpaper_changed = wallpaper and (not cached or cached._wallpaper ~= wallpaper)
						local mode_changed = cached and cached.mode ~= mode
						if wallpaper_changed or mode_changed then
							vim.schedule(function()
								M.generate({ notify = M.config.notify })
							end)
						end
					end)
				end)
			end,
		})
	end
end

return M
