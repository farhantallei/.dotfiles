local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.automatically_reload_config = true
	config.window_close_confirmation = "NeverPrompt"

	config.front_end = "WebGpu"
	config.max_fps = 120
	config.prefer_egl = true

	config.font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"JetBrains Mono",
		"Symbols Nerd Font Mono",
	})
	config.font_size = 12

	config.window_decorations = "RESIZE"
	config.hide_tab_bar_if_only_one_tab = true
	config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	config.initial_rows = 60
	config.initial_cols = 240
end

return M
