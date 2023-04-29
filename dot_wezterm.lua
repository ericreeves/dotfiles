local wt = require("wezterm");
local act = wt.action

local TabBackground = "#000"
local TabForeground = "#aaa"
local TabForegroundActive = "#fff"

function string.split(str, sep)
	local t = {}
	for s in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
end

function reduce_title(title)
	title = title:gsub("\\", "/")
	title = title:split("/")
	return title[#title]
end

wt.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return reduce_title(tab.active_pane.title)
end)

wt.on("format-window-title", function(tab, pane, tabs, panes, config)
	return reduce_title(tab.active_pane.title)
end)

return {
--	color_scheme = "Builtin Tango Dark",
--  color_scheme = 'Tangoesque (terminal.sexy)',
  color_scheme = 'Tomorrow Night Bright',

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
	initial_cols = 100,
	initial_rows = 30,

  tab_bar_at_bottom = true,
  front_end = "WebGpu",
  font = wt.font('FiraCode NF'),
	font_size = 11,
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 800,
  cursor_thickness = "2px",
  underline_position = "1px",
  underline_thickness = "2px",
	hide_tab_bar_if_only_one_tab = true,
	window_background_opacity = 0.85,
	default_prog = {"C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo"},
	alternate_buffer_wheel_scroll_speed = 1,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	keys = {
		{ key = "t", mods = "CTRL|SHIFT", action = wt.action{ SpawnTab = "DefaultDomain", }, },
		{ key = "w", mods = "CTRL|SHIFT", action = wt.action{ CloseCurrentTab = { confirm = false, }, }, },
		{ key = "Tab", mods = "CTRL", action = wt.action{ ActivateTabRelative = 1, }, },
		{ key = "Tab", mods = "CTRL|SHIFT", action = wt.action{ ActivateTabRelative = -1, }, },
		{ key = "c", mods = "ALT", action = wt.action{ CopyTo = "Clipboard", }, },
		{ key = "v", mods = "ALT", action = wt.action{ PasteFrom = "Clipboard", }, },
    { key = '>', mods = 'SHIFT|CTRL', action = wt.action.SplitVertical{ domain = 'CurrentPaneDomain' } },
    { key = '<', mods = 'SHIFT|CTRL', action = wt.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    { key = 'z', mods = 'SHIFT|CTRL', action = wt.action.TogglePaneZoomState },
    { key = 'h', mods = 'SHIFT|CTRL', action = wt.action.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'SHIFT|CTRL', action = wt.action.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'SHIFT|CTRL', action = wt.action.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'SHIFT|CTRL', action = wt.action.ActivatePaneDirection 'Down' },
    { key = 'u', mods = 'SHIFT|CTRL', action = wt.action.AdjustPaneSize{ 'Left', 5 } },
    { key = 'p', mods = 'SHIFT|CTRL', action = wt.action.AdjustPaneSize{ 'Right', 5 } },
    { key = 'o', mods = 'SHIFT|CTRL', action = wt.action.AdjustPaneSize{ 'Up', 5 } },
    { key = 'i', mods = 'SHIFT|CTRL', action = wt.action.AdjustPaneSize{ 'Down', 5 } }
	}
}
