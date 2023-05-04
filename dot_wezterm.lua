local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local TabBackground = "#000"
local TabForeground = "#aaa"
local TabForegroundActive = "#fff"

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
	-- color_scheme = "Builtin Tango Dark",
	color_scheme = "Hardcore",
	--  color_scheme = 'Tangoesque (terminal.sexy)',
	-- color_scheme = 'Tomorrow Night Bright',

	--  color_scheme = 'Tango (terminal.sexy)',

	colors = {
		tab_bar = {
			background = TabBackground,
			active_tab = {
				bg_color = TabBackground,
				fg_color = TabForegroundActive,
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = TabBackground,
				fg_color = TabForeground,
				intensity = "Normal",
			},
			inactive_tab_hover = {
				bg_color = TabBackground,
				fg_color = TabForegroundActive,
				intensity = "Normal",
			},
			new_tab = {
				bg_color = TabBackground,
				fg_color = TabForeground,
			},
			new_tab_hover = {
				bg_color = TabBackground,
				fg_color = TabForegroundActive,
			},
		},
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

	initial_cols = 100,
	initial_rows = 30,

	tab_bar_at_bottom = true,
	window_decorations = "RESIZE",

	front_end = "OpenGL",
	font = wezterm.font("FiraCode NF"),
	font_size = 11,
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 800,
	line_height = 1.3,
	cursor_thickness = "2px",
	underline_position = "1px",
	underline_thickness = "2px",
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	window_background_opacity = 0.97,
	default_prog = { "C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo" },
	alternate_buffer_wheel_scroll_speed = 1,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_frame = {
		font = wezterm.font({ family = "Noto Sans", weight = "Regular" }),
	},
	disable_default_key_bindings = true,
	keys = {
		{ key = "t", mods = "CTRL|SHIFT", action = act({ SpawnTab = "DefaultDomain" }) },
		{ key = "w", mods = "CTRL|SHIFT", action = act({ CloseCurrentTab = { confirm = false } }) },
		{ key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
		{ key = "Tab", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },
		{ key = "c", mods = "ALT", action = act({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "ALT", action = act({ PasteFrom = "Clipboard" }) },
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
