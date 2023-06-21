local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

function string.split(str, sep)
	local t = {}
	for s in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(t, s)
		return t
	end
end

function reduce_title(title)
	title = title:gsub("\\", "/")
	title = title:split("/")
	return title[#title]
end

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--   return reduce_title(tab.active_pane.title)
-- end)

-- wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
--   return reduce_title(tab.active_pane.title)
-- end)

return {
	tab_bar_style = {
		active_tab_left = wezterm.format({
			{ Background = { Color = "#0b0022" } },
			{ Foreground = { Color = "#2b2042" } },
			{ Text = SOLID_LEFT_ARROW },
		}),
		active_tab_right = wezterm.format({
			{ Background = { Color = "#0b0022" } },
			{ Foreground = { Color = "#2b2042" } },
			{ Text = SOLID_RIGHT_ARROW },
		}),
		inactive_tab_left = wezterm.format({
			{ Background = { Color = "#0b0022" } },
			{ Foreground = { Color = "#1b1032" } },
			{ Text = SOLID_LEFT_ARROW },
		}),
		inactive_tab_right = wezterm.format({
			{ Background = { Color = "#0b0022" } },
			{ Foreground = { Color = "#1b1032" } },
			{ Text = SOLID_RIGHT_ARROW },
		}),
	},

	-- color_scheme = "Catppuccin Mocha", -- or Macchiato, Frappe, Latte
	color_scheme = "Catppuccin Mocha", -- or Macchiato, Frappe, Latte
	-- color_scheme = "BlulocoDark",
	-- color_scheme = "Hardcore",
	-- color_scheme = "Ayu Mirage",
	-- color_scheme = "Builtin Tango Dark",
	--  color_scheme = 'Tangoesque (terminal.sexy)',
	-- color_scheme = 'Tomorrow Night Bright',

	--  color_scheme = 'Tango (terminal.sexy)',
	--
	--  Catppuccin Mocha
	-- rosewater = "#f5e0dc",
	-- 	flamingo = "#f2cdcd",
	-- 	pink = "#f5c2e7",
	-- 	mauve = "#cba6f7",
	-- 	red = "#f38ba8",
	-- 	maroon = "#eba0ac",
	-- 	peach = "#fab387",
	-- 	yellow = "#f9e2af",
	-- 	green = "#a6e3a1",
	-- 	teal = "#94e2d5",
	-- 	sky = "#89dceb",
	-- 	sapphire = "#74c7ec",
	-- 	blue = "#89b4fa",
	-- 	lavender = "#b4befe",
	-- 	text = "#cdd6f4",
	-- 	subtext1 = "#bac2de",
	-- 	subtext0 = "#a6adc8",
	-- 	overlay2 = "#9399b2",
	-- 	overlay1 = "#7f849c",
	-- 	overlay0 = "#6c7086",
	-- 	surface2 = "#585b70",
	-- 	surface1 = "#45475a",
	-- 	surface0 = "#313244",
	-- 	mantle = "#181825",
	-- 	base = "#1e1e2e",
	-- 	crust = "#11111b",

	colors = {

		tab_bar = {
			-- The color of the inactive tab bar edge/divider
			inactive_tab_edge = "#1e1e2e",
			-- The color of the strip that goes along the top of the window
			-- (does not apply when fancy tab bar is in use)
			background = "#1e1e2e",

			-- The active tab is the one that has focus in the window
			active_tab = {
				-- The color of the background area for the tab
				bg_color = "#1e1e2e",
				-- The color of the text for the tab
				fg_color = "#b4befe",

				-- Specify whether you want "Half", "Normal" or "Bold" intensity for the
				-- label shown for this tab.
				-- The default is "Normal"
				intensity = "Normal",

				-- Specify whether you want "None", "Single" or "Double" underline for
				-- label shown for this tab.
				-- The default is "None"
				underline = "None",

				-- Specify whether you want the text to be italic (true) or not (false)
				-- for this tab.  The default is false.
				italic = false,

				-- Specify whether you want the text to be rendered with strikethrough (true)
				-- or not for this tab.  The default is false.
				strikethrough = false,
			},

			-- Inactive tabs are the tabs that do not have focus
			inactive_tab = {
				bg_color = "#1e1e2e",
				fg_color = "#505050",

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `inactive_tab`.
			},

			-- You can configure some alternate styling when the mouse pointer
			-- moves over inactive tabs
			inactive_tab_hover = {
				bg_color = "#1e1e2e",
				fg_color = "#909090",
				italic = true,

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `inactive_tab_hover`.
			},

			-- The new tab button that let you create new tabs
			new_tab = {
				bg_color = "#1e1e2e",
				fg_color = "#808080",

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `new_tab`.
			},

			-- You can configure some alternate styling when the mouse pointer
			-- moves over the new tab button
			new_tab_hover = {
				bg_color = "#1e1e2e",
				bg_color = "#181825",
				fg_color = "#909090",
				italic = true,

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `new_tab_hover`.
			},
		},
		visual_bell = "#202020",
	},

	inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.5,
	},

	visual_bell = {
		fade_in_duration_ms = 75,
		fade_out_duration_ms = 75,
		target = "CursorColor",
	},
	audible_bell = "Disabled",

	initial_cols = 100,
	initial_rows = 30,

	enable_tab_bar = true,
	tab_bar_at_bottom = false,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	window_decorations = "RESIZE",

	-- front_end = "Software",
	-- font = wezterm.font("JetBrainsMono NF"),
	front_end = "WebGpu",
	font = wezterm.font("JetBrains Mono"),
	-- font = wezterm.font("VictorMono NF"),
	-- font = wezterm.font("FiraCode NF"),
	-- font = wezterm.font("CaskaydiaCove NF"),
	-- font = wezterm.font("JetBrains Mono"),
	-- font = wezterm.font("SauceCodePro NF"),
	-- font = wezterm.font_with_fallback({
	-- {
	-- 	family = "JetBrainsMonoNL Nerd Font Propo",
	-- 	weight = "Regular",
	-- },
	-- {
	-- 	-- Fallback font with all the Netd Font Symbols
	-- 	family = "Symbols NFM",
	-- 	scale = 0.9,
	-- },
	-- }),
	font_size = 11,
	freetype_load_target = "Light",
	freetype_render_target = "HorizontalLcd",
	font_shaper = "Harfbuzz",
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 800,
	line_height = 1.2,
	cursor_thickness = "2px",
	underline_position = "1px",
	underline_thickness = "2px",
	adjust_window_size_when_changing_font_size = false,
	window_background_opacity = 0.90,
	text_background_opacity = 0.9,
	default_prog = { "C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo" },
	alternate_buffer_wheel_scroll_speed = 1,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_frame = {
		font = wezterm.font({ family = "Segoe UI", weight = "Bold" }),
		-- The size of the font in the tab bar.
		-- Default to 10.0 on Windows but 12.0 on other systems
		font_size = 11.0,

		-- The overall background color of the tab bar when
		-- the window is focused
		active_titlebar_bg = "#1e1e2e",

		-- The overall background color of the tab bar when
		-- the window is not focused
		inactive_titlebar_bg = "#1e1e2e",
	},
	disable_default_key_bindings = true,
	keys = {
		{ key = "t", mods = "CTRL|SHIFT", action = act({ SpawnTab = "DefaultDomain" }) },
		{ key = "w", mods = "CTRL|SHIFT", action = act({ CloseCurrentTab = { confirm = false } }) },
		{ key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
		{ key = "Tab", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },
		{ key = "c", mods = "ALT", action = act({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "ALT", action = act({ PasteFrom = "Clipboard" }) },
		{ key = "v", mods = "CTRL", action = act({ PasteFrom = "Clipboard" }) },
		{ key = "1", mods = "CTRL", action = act({ ActivateTab = 0 }) },
		{ key = "2", mods = "CTRL", action = act({ ActivateTab = 1 }) },
		{ key = "3", mods = "CTRL", action = act({ ActivateTab = 2 }) },
		{ key = "4", mods = "CTRL", action = act({ ActivateTab = 3 }) },
		{ key = "5", mods = "CTRL", action = act({ ActivateTab = 4 }) },
		{ key = "6", mods = "CTRL", action = act({ ActivateTab = 5 }) },
		{ key = ">", mods = "SHIFT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "<", mods = "SHIFT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "z", mods = "SHIFT|CTRL", action = act.TogglePaneZoomState },
		{ key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
		{ key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
		{ key = "u", mods = "SHIFT|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "p", mods = "SHIFT|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "o", mods = "SHIFT|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "i", mods = "SHIFT|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
		{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	},
}
