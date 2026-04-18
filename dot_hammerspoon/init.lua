-- PaperWM configuration for Hammerspoon
-- Keybindings mirror AeroSpace (alt+hjkl pattern)
-- Managed by: ~/.local/bin/paperwm

PaperWM = hs.loadSpoon("PaperWM")

-- Gap and margin settings (match AeroSpace inner=15)
PaperWM.window_gap = 15
PaperWM.screen_margin = 1

-- Width ratios for cycle_width (golden ratio + half + full)
PaperWM.window_ratios = { 0.38195, 0.5, 0.61804, 1.0 }

-- External bar (sketchybar at top, 32px)
PaperWM.external_bar = { top = 32 }

-- Floating apps (match AeroSpace on-window-detected floating rules)
PaperWM.window_filter:rejectApp("1Password")
PaperWM.window_filter:rejectApp("Mantle")
PaperWM.window_filter:rejectApp("Microsoft Teams")
PaperWM.window_filter:rejectApp("Wispr Flow")
PaperWM.window_filter:rejectApp("Logi Options")
PaperWM.window_filter:rejectApp("iPhone Mirroring")
PaperWM.window_filter:rejectApp("Claude")
PaperWM.window_filter:rejectApp("Cisco Secure Client")
PaperWM.window_filter:rejectApp("Stream Deck")
PaperWM.window_filter:rejectApp("zoom.us")
PaperWM.window_filter:rejectApp("meetily")
PaperWM.window_filter:rejectApp("Elgato Wave Link")
PaperWM.window_filter:rejectApp("Raycast")
PaperWM.window_filter:rejectApp("System Settings")
PaperWM.window_filter:rejectApp("Calculator")
PaperWM.window_filter:rejectApp("Activity Monitor")
PaperWM.window_filter:rejectApp("Archive Utility")
PaperWM.window_filter:rejectApp("Installer")

-- Keybindings matching AeroSpace alt+hjkl pattern
--
-- AeroSpace                    → PaperWM
-- alt-h/j/k/l (focus)          → focus_left/down/up/right
-- alt-shift-h/j/k/l (move)     → swap_left/down/up/right
-- ctrl-alt-h/l (resize)        → decrease_width/increase_width
-- ctrl-alt-j/k (resize)        → decrease_height/increase_height
-- alt-1..9 (workspace)          → switch_space_1..9
-- alt-shift-1..9 (move to ws)   → move_window_1..9
-- alt-f (float toggle)          → toggle_floating
-- alt-m (fullscreen)            → full_width
-- alt-comma/period (cycle)      → focus_prev/focus_next
-- alt-y/o (workspace cycle)     → switch_space_l/switch_space_r
-- alt-shift-y/o (move ws cycle) → (not available, use move_window_N)
-- alt-r (retile)                → refresh_windows
-- alt-slash (monitor focus)     → move_window_r (closest equivalent)

PaperWM:bindHotkeys({
    -- Focus (alt+hjkl)
    focus_left           = {{"alt"}, "h"},
    focus_right          = {{"alt"}, "l"},
    focus_up             = {{"alt"}, "k"},
    focus_down           = {{"alt"}, "j"},

    -- Cycle focus
    focus_prev           = {{"alt"}, ","},
    focus_next           = {{"alt"}, "."},

    -- Move/swap (alt+shift+hjkl)
    swap_left            = {{"alt", "shift"}, "h"},
    swap_right           = {{"alt", "shift"}, "l"},
    swap_up              = {{"alt", "shift"}, "k"},
    swap_down            = {{"alt", "shift"}, "j"},

    -- Resize (ctrl+alt)
    decrease_width       = {{"ctrl", "alt"}, "h"},
    increase_width       = {{"ctrl", "alt"}, "l"},
    decrease_height      = {{"ctrl", "alt"}, "j"},
    increase_height      = {{"ctrl", "alt"}, "k"},

    -- Cycle through preset widths (alt+r / alt+shift+r)
    cycle_width          = {{"alt", "shift"}, ","},
    reverse_cycle_width  = {{"alt", "shift"}, "."},

    -- Fullscreen / center
    full_width           = {{"alt"}, "m"},
    center_window        = {{"alt"}, "c"},

    -- Float toggle
    toggle_floating      = {{"alt"}, "f"},
    focus_floating       = {{"alt", "shift"}, "f"},

    -- Column operations (slurp/barf = join/unjoin)
    slurp_in             = {{"alt", "shift"}, "u"},
    barf_out             = {{"alt", "shift"}, "i"},

    -- Retile
    refresh_windows      = {{"alt"}, "r"},

    -- Workspace switching (alt+1..9)
    switch_space_1       = {{"alt"}, "1"},
    switch_space_2       = {{"alt"}, "2"},
    switch_space_3       = {{"alt"}, "3"},
    switch_space_4       = {{"alt"}, "4"},
    switch_space_5       = {{"alt"}, "5"},
    switch_space_6       = {{"alt"}, "6"},
    switch_space_7       = {{"alt"}, "7"},
    switch_space_8       = {{"alt"}, "8"},
    switch_space_9       = {{"alt"}, "9"},

    -- Workspace cycling (alt+y/o)
    switch_space_l       = {{"alt"}, "y"},
    switch_space_r       = {{"alt"}, "o"},

    -- Move to workspace (alt+shift+1..9)
    move_window_1        = {{"alt", "shift"}, "1"},
    move_window_2        = {{"alt", "shift"}, "2"},
    move_window_3        = {{"alt", "shift"}, "3"},
    move_window_4        = {{"alt", "shift"}, "4"},
    move_window_5        = {{"alt", "shift"}, "5"},
    move_window_6        = {{"alt", "shift"}, "6"},
    move_window_7        = {{"alt", "shift"}, "7"},
    move_window_8        = {{"alt", "shift"}, "8"},
    move_window_9        = {{"alt", "shift"}, "9"},

    -- Move to monitor
    move_window_l        = {{"alt", "shift"}, "/"},
    move_window_r        = {{"ctrl", "alt"}, "/"},
})

PaperWM:start()
