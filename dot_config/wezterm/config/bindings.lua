local wezterm = require('wezterm')
local platform = require('utils.platform')
-- local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'SHIFT|ALT'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
   { key = 'p',  mods = mod.SUPER, action = act.ActivateCommandPalette },
   { key = 'd', mods = mod.SUPER,     action = wezterm.action.ShowLauncherArgs {
      flags = 'DOMAINS',
      title = 'Choose domain',
    }
  },
   { key = 'g', mods = mod.SUPER, action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER_REV, action = act.Search({ CaseInSensitiveString = '' }) },
   -- {
   --    key = 'u',
   --    mods = mod.SUPER_REV,
   --    action = wezterm.action.QuickSelectArgs({
   --       label = 'open url',
   --       patterns = {
   --          '\\((https?://\\S+)\\)',
   --          '\\[(https?://\\S+)\\]',
   --          '\\{(https?://\\S+)\\}',
   --          '<(https?://\\S+)>',
   --          '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
   --       },
   --       action = wezterm.action_callback(function(window, pane)
   --          local url = window:get_selection_text_for_pane(pane)
   --          wezterm.log_info('opening: ' .. url)
   --          wezterm.open_with(url)
   --       end),
   --    }),
   -- },
   --
   -- cursor movement --
   -- { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' },
   -- { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' },
   -- { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\u{15}' },

   -- copy/paste --
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('CurrentPaneDomain') },
   { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = true }) },
   { key = 'd',          mods = mod.SUPER_REV, action = act.DetachDomain('CurrentPaneDomain') },

   -- tabs: navigation
   { key = 'u', mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
   { key = 'o', mods = mod.SUPER, action = act.ActivateTabRelative(1) },

   { key = 'o', mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },
   { key = 'u', mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER, action = act.ActivatePaneDirection('Right') },

   { key = 'l',     mods = mod.SUPER_REV, action = act.RotatePanes 'Clockwise' },
   { key = 'h',     mods = mod.SUPER_REV, action = act.RotatePanes 'CounterClockwise' },

   { key = 'k',        mods = mod.SUPER_REV, action = act.ScrollByLine(-5) },
   { key = 'j',        mods = mod.SUPER_REV, action = act.ScrollByLine(5) },

   -- panes: zoom+close pane
   { key = 'f', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'c',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = true }) },

   -- tab: title
  { key = 'r', mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },
  { key = 'r', mods = mod.SUPER, action = act.EmitEvent('tabs.manual-update-tab-title') },

   -- window --
   -- window: spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- background controls --
   -- {
   --    key = [[/]],
   --    mods = mod.SUPER,
   --    action = wezterm.action_callback(function(window, _pane)
   --       backdrops:random(window)
   --    end),
   -- },
   -- {
   --    key = [[,]],
   --    mods = mod.SUPER,
   --    action = wezterm.action_callback(function(window, _pane)
   --       backdrops:cycle_back(window)
   --    end),
   -- },
   -- {
   --    key = [[.]],
   --    mods = mod.SUPER,
   --    action = wezterm.action_callback(function(window, _pane)
   --       backdrops:cycle_forward(window)
   --    end),
   -- },
   -- {
   --    key = [[/]],
   --    mods = mod.SUPER_REV,
   --    action = act.InputSelector({
   --       title = 'InputSelector: Select Background',
   --       choices = backdrops:choices(),
   --       fuzzy = true,
   --       fuzzy_description = 'Select Background: ',
   --       action = wezterm.action_callback(function(window, _pane, idx)
   --          if not idx then
   --             return
   --          end
   --          ---@diagnostic disable-next-line: param-type-mismatch
   --          backdrops:set_img(window, tonumber(idx))
   --       end),
   --    }),
   -- },
   -- {
   --    key = 'b',
   --    mods = mod.SUPER,
   --    action = wezterm.action_callback(function(window, _pane)
   --       backdrops:toggle_focus(window)
   --    end)
   -- },

   -- panes --
   -- panes: split panes
   {
      key = 'b',
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = 'v',
      mods = mod.SUPER,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- {
   --    key = 'p',
   --    mods = mod.SUPER,
   --    action = act.PaneSelect({ alphabet = '1234567890', mode = 'Activate' }),
   -- },
   {
      key = 's',
      mods = 'LEADER',
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- panes: scroll pane
   -- { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-0.75) },
   -- { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(0.75) },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   -- disable_default_mouse_bindings = true,
   leader = { key = 'Space', mods = mod.SUPER, timemout_miliseconds = 1000 },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
