local wezterm = require('wezterm')
local gpu_adapters = require('utils.gpu-adapter')
-- local backdrops = require('utils.backdrops')

return {
   max_fps = 120,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),
   underline_thickness = '1.5pt',

   -- cursor
   animation_fps = 120,
   cursor_blink_ease_in = 'EaseOut',
   cursor_blink_ease_out = 'EaseOut',
   default_cursor_style = 'BlinkingBlock',
   cursor_blink_rate = 650,

   -- color scheme
   color_scheme = 'catppuccin-mocha',

   colors = {
      split = '#6272a4', -- Dracula purple for dividers
      tab_bar = {
         background = '#11111b',
         active_tab = {
            bg_color = '#1e1e2e',
            fg_color = '#cdd6f4',
         },
         inactive_tab = {
            bg_color = '#11111b',
            fg_color = '#313244',
         },
         inactive_tab_hover = {
            bg_color = '#585b70',
            fg_color = '#cdd6f4',
         },
         new_tab = {
            bg_color = '#11111b',
            fg_color = '#cdd6f4',
         },
         new_tab_hover = {
            bg_color = '#585b70',
            fg_color = '#cdd6f4',
         },
      },
   },

   -- background
   -- background = backdrops:initial_options(false), -- set to true if you want wezterm to start on focus mode

   -- scrollbar
   enable_scroll_bar = true,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = true,
   use_fancy_tab_bar = true,
   tab_max_width = 100,
   show_tab_index_in_tab_bar = true,
   switch_to_last_active_tab_when_closing_tab = true,
   tab_bar_at_bottom = false,

   -- window
   window_padding = {
      left = 0,
      right = 0,
      top = 10,
      bottom = 7.5,
   },
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'AlwaysPrompt',
   window_decorations = 'RESIZE',
   window_frame = {
      active_titlebar_bg = '#11111b',
      inactive_titlebar_bg = '#11111b',
      -- font = wezterm.font('FiraCode Nerd Font'),
      font_size = 11.0,
   },
   -- inactive_pane_hsb = {
   --    saturation = 0.9,
   --    brightness = 0.65,
   -- },
   inactive_pane_hsb = {
      saturation = 1,
      brightness = 0.7,
   },

   audible_bell = 'Disabled',
   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
