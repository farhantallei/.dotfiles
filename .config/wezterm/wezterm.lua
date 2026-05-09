local wezterm = require("wezterm")
local config = wezterm.config_builder()

package.path = wezterm.config_dir .. "/lua/?.lua;" .. package.path

require("appearance").apply(config)
require("theme").apply(config)
require("keymaps").apply(config)

return config
