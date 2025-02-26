------------------------------------------------------
--               Wezterm configuration
------------------------------------------------------

local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local windows = require("windows") -- file located at ~/.wezterm/windows.lua
local linux = require("linux") -- file located at ~/.wezterm/linux.lua
local keymaps = require("keymaps")
local terminal = require("terminal")
-- local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
-- For windows host custom configuration
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	windows.options(config)
end

-- For linux host custom configuration
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	linux.options(config)
end

keymaps.options(config)
terminal.options(config)

-- bar.apply_to_config(config)
-- Add spotify to bar
-- bar.apply_to_config(config, {
-- 	modules = {
-- 		spotify = {
-- 			enabled = true,
-- 		},
-- 	},
-- })

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {},
})

tabline.apply_to_config(config)

return config
