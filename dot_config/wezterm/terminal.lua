local wezterm = require("wezterm")

local M = {}

function M.options(config)
	config.status_update_interval = 1000

	config.color_scheme = "catppuccin-mocha"

	config.animation_fps = 60
	config.max_fps = 60

	config.initial_cols = 115
	config.initial_rows = 28
	-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Regular" })
	config.font = wezterm.font("FiraCode Nerd Font", { weight = 450 })
	-- config.font = wezterm.font("RobotoMono Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("SpaceMono Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("EnvyCodeR Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("Iosevka Nerd Font", { weight = "Regular" })
	-- config.font = wezterm.font("Iosevka Nerd Font", { weight = "Medium" })
	-- config.line_height = 1.1
	config.font_size = 11
	config.freetype_load_flags = "NO_HINTING"
	-- config.freetype_load_target = "HorizontalLcd"
	config.front_end = "WebGpu"
	config.window_decorations = "RESIZE"
	-- config.text_background_opacity = 1.5
	-- config.window_background_opacity = 1.5
	config.window_frame = {
		border_left_width = "3px",
		border_right_width = "3px",
		border_bottom_height = "3px",
		border_top_height = "3px",
	}
	config.enable_scroll_bar = false
	config.default_cursor_style = "BlinkingBar"
	config.cursor_blink_rate = 333
	config.inactive_pane_hsb = { saturation = 0.5, brightness = 1.0 }
	config.window_padding = { left = "0px", right = "0px", top = 0, bottom = 0 }

	----- Misc
	-- config.warn_about_missing_glyphs = false
	config.adjust_window_size_when_changing_font_size = false
	-- config.audible_bell = "Disabled"
	-- config.exit_behavior = "Close"
	-- config.window_close_confirmation = "NeverPrompt"
	-- config.scrollback_lines = 50000
	-- config.tab_max_width = 9999
	-- config.hide_tab_bar_if_only_one_tab = false
	-- config.tab_bar_at_bottom = false
	-- config.use_fancy_tab_bar = true
	-- config.show_new_tab_button_in_tab_bar = false
	-- config.allow_win32_input_mode = true
	-- config.disable_default_key_bindings = true
	-- config.quit_when_all_windows_are_closed = false
end
-- config.selection_word_boundary = "{}[]()\"'`.,;:="

return M
