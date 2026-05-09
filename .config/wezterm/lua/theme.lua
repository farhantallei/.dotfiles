local M = {}

local FALLBACK = "mocha"

local SCHEMES = {
	mocha = "Catppuccin Mocha",
	macchiato = "Catppuccin Macchiato",
	frappe = "Catppuccin Frappe",
	latte = "Catppuccin Latte",
	["tokyonight-night"] = "tokyonight_night",
	["tokyonight-storm"] = "tokyonight_storm",
	["tokyonight-moon"] = "tokyonight_moon",
	["tokyonight-day"] = "tokyonight_day",
	["kanagawa-dragon"] = "Kanagawa Dragon",
	["kanagawa-wave"] = "Kanagawa Wave",
	["kanagawa-lotus"] = "Kanagawa Lotus",
}

-- Custom kanagawa schemes — wezterm gak punya built-in per-variant.
-- Palette derived dari kanagawa.nvim theme.ui mapping.
local CUSTOM_SCHEMES = {
	["Kanagawa Dragon"] = {
		background = "#181616",
		foreground = "#c5c9c5",
		cursor_bg = "#c8c093",
		cursor_fg = "#181616",
		cursor_border = "#c8c093",
		selection_bg = "#223249",
		selection_fg = "#c5c9c5",
		ansi = { "#0d0c0c", "#c4746e", "#8a9a7b", "#c4b28a", "#658594", "#a292a3", "#8ea4a2", "#a6a69c" },
		brights = { "#a6a69c", "#E46876", "#87a987", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#c5c9c5" },
	},
	["Kanagawa Wave"] = {
		background = "#1f1f28",
		foreground = "#dcd7ba",
		cursor_bg = "#c8c093",
		cursor_fg = "#1f1f28",
		cursor_border = "#c8c093",
		selection_bg = "#2D4F67",
		selection_fg = "#dcd7ba",
		ansi = { "#16161d", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
		brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
	},
	["Kanagawa Lotus"] = {
		background = "#f2ecbc",
		foreground = "#545464",
		cursor_bg = "#43436c",
		cursor_fg = "#f2ecbc",
		cursor_border = "#43436c",
		selection_bg = "#c9cbd1",
		selection_fg = "#545464",
		ansi = { "#1F1F28", "#c84053", "#6f894e", "#77713f", "#4d699b", "#b35b79", "#597b75", "#545464" },
		brights = { "#8a8980", "#d7474b", "#6e915f", "#836f4a", "#6693bf", "#624c83", "#5e857a", "#43436c" },
	},
}

local function read_current_variant()
	local path = os.getenv("HOME") .. "/.config/theme-current"
	local f = io.open(path, "r")
	if not f then
		return FALLBACK
	end
	local line = f:read("*l") or ""
	f:close()
	local variant = line:match("^%s*(%S+)%s*$") or ""
	if SCHEMES[variant] then
		return variant
	end
	return FALLBACK
end

function M.apply(config)
	-- Inject custom schemes biar wezterm tau soal kanagawa-*
	config.color_schemes = config.color_schemes or {}
	for name, scheme in pairs(CUSTOM_SCHEMES) do
		config.color_schemes[name] = scheme
	end
	config.color_scheme = SCHEMES[read_current_variant()]
end

return M
