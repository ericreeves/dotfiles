local wezterm = require('wezterm')
local platform = require('utils.platform')
-- local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   -- mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT|SHIFT|CTRL' -- to not conflict with Windows key shortcuts
   -- mod.SUPER_REV = 'SHIFT|ALT'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'c', mods = mod.SUPER, action = 'ActivateCopyMode' },
   { key = 'p',  mods = mod.SUPER, action = act.ActivateCommandPalette },
   { key = 'd', mods = mod.SUPER,     action = wezterm.action.ShowLauncherArgs {
      flags = 'DOMAINS',
      title = 'Choose domain',
    }
  },

   -- copy/paste --
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.EmitEvent('tabs.show-launch-menu') },
   { key = 'w',          mods = mod.SUPER, action = act.CloseCurrentTab({ confirm = true }) },
   { key = 'z',          mods = mod.SUPER, action = act.DetachDomain('CurrentPaneDomain') },

   -- tabs: navigation
   { key = 'y', mods = mod.SUPER, action = act.MoveTabRelative(-1) },
   { key = 'u', mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
   { key = 'i', mods = mod.SUPER, action = act.ActivateTabRelative(1) },
   { key = 'o', mods = mod.SUPER, action = act.MoveTabRelative(1) },


   -- panes: navigation
   { key = 'k',     mods = mod.SUPER, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER, action = act.ActivatePaneDirection('Right') },

  { key = 'r', mods = mod.SUPER, action = act.EmitEvent('tabs.manual-update-tab-title') },
  -- { key = 'r', mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },
   -- window --
   -- window: spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- panes --
   -- panes: split panes
   -- {
   --    key = 'b',
   --    mods = mod.SUPER,
   --    action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   -- },
   -- {
   --    key = 'v',
   --    mods = mod.SUPER,
   --    action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   -- },
   --
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
