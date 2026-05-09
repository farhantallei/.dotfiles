local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
	config.keys = {
		{ key = "LeftArrow",  mods = "CMD",        action = act.SendString("\x1b[1;5D") },
		{ key = "RightArrow", mods = "CMD",        action = act.SendString("\x1b[1;5C") },
		{ key = "k",          mods = "CMD",        action = act.ClearScrollback("ScrollbackAndViewport") },
		{ key = "Tab",        mods = "CTRL",       action = act.SendKey({ key = "Tab", mods = "CTRL" }) },
		{ key = "Tab",        mods = "CTRL|SHIFT", action = act.SendKey({ key = "Tab", mods = "CTRL|SHIFT" }) },
		{ key = "Enter",      mods = "SHIFT",      action = act.SendString("\x1b[13;2u") },
		{ key = "Enter",      mods = "ALT",        action = act.SendKey({ key = "Enter", mods = "ALT" }) },
		{ key = "Enter",      mods = "ALT|SHIFT",  action = act.SendString("\x1b[13;4u") },
	}
end

return M
