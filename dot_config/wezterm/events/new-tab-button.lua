local wezterm = require('wezterm')
local launch_menu = require('config.launch').launch_menu
local domains = require('config.domains')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local act = wezterm.action
local attr = Cells.attr

local M = {}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
-- Catppuccin Mocha colors
local colors = {
   label_text   = { fg = '#CDD6F4' },  -- Text
   icon_default = { fg = '#b4befe' },  -- Lavender
   icon_wsl     = { fg = '#b4befe' },  -- Lavender
   icon_ssh     = { fg = '#b4befe' },  -- Lavender
   icon_unix    = { fg = '#b4befe' },  -- Lavender
}

local cells = Cells:new()
   :add_segment('icon_default', ' ' .. nf.md_domain .. ' ', colors.icon_default)
   :add_segment('icon_wsl', ' ' .. nf.cod_terminal_linux .. ' ', colors.icon_wsl)
   :add_segment('icon_ssh', ' ' .. nf.md_ssh .. ' ', colors.icon_ssh)
   :add_segment('icon_unix', ' ' .. nf.dev_gnu .. ' ', colors.icon_unix)
   :add_segment('label_text', '', colors.label_text, attr(attr.intensity('Bold')))

local function build_choices()
   local choices = {}
   local choices_data = {}
   local idx = 1

   -- Add launch menu items (DefaultDomain)
   for _, v in ipairs(launch_menu) do
      cells:update_segment_text('label_text', v.label)

      table.insert(choices, {
         id = tostring(idx),
         label = wezterm.format(cells:render({ 'icon_default', 'label_text' })),
      })
      table.insert(choices_data, {
         args = v.args,
         domain = 'DefaultDomain',
      })
      idx = idx + 1
   end

   -- Add WSL domains
   for _, v in ipairs(domains.wsl_domains) do
      cells:update_segment_text('label_text', v.name)

      table.insert(choices, {
         id = tostring(idx),
         label = wezterm.format(cells:render({ 'icon_wsl', 'label_text' })),
      })
      table.insert(choices_data, {
         domain = { DomainName = v.name },
      })
      idx = idx + 1
   end

   -- Add SSH domains
   for _, v in ipairs(domains.ssh_domains) do
      cells:update_segment_text('label_text', v.name)
      table.insert(choices, {
         id = tostring(idx),
         label = wezterm.format(cells:render({ 'icon_ssh', 'label_text' })),
      })
      table.insert(choices_data, {
         domain = { DomainName = v.name },
      })
      idx = idx + 1
   end

   -- Add Unix domains
   for _, v in ipairs(domains.unix_domains) do
      cells:update_segment_text('label_text', v.name)
      table.insert(choices, {
         id = tostring(idx),
         label = wezterm.format(cells:render({ 'icon_unix', 'label_text' })),
      })
      table.insert(choices_data, {
         domain = { DomainName = v.name },
      })
      idx = idx + 1
   end

   return choices, choices_data
end

local choices, choices_data = build_choices()

local function show_launch_selector(window, pane)
   window:perform_action(
      act.InputSelector({
         title = 'InputSelector: Launch Menu',
         choices = choices,
         fuzzy = true,
         fuzzy_description = nf.md_rocket .. ' Select a launch item: ',
         action = wezterm.action_callback(function(_window, _pane, id, label)
            if not id and not label then
               return
            else
               wezterm.log_info('you selected ', id, label)
               wezterm.log_info(choices_data[tonumber(id)])
               window:perform_action(
                  act.SpawnCommandInNewTab(choices_data[tonumber(id)]),
                  pane
               )
            end
         end),
      }),
      pane
   )
end

M.setup = function()
   -- Custom event for keybinding (Super+T)
   wezterm.on('tabs.show-launch-menu', function(window, pane)
      show_launch_selector(window, pane)
   end)

   -- Add to command palette
   wezterm.on('augment-command-palette', function(window, pane)
      return {
         {
            brief = 'New Tab (Launch Menu)',
            icon = 'md_rocket',
            action = wezterm.action_callback(function(w, p)
               show_launch_selector(w, p)
            end),
         },
      }
   end)

   -- New tab button click handler
   wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
      -- Both left and right click show the launch menu
      show_launch_selector(window, pane)
      return false
   end)
end

return M
