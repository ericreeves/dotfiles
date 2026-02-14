local Config = require('config')

-- require('utils.backdrops')
--    -- :set_focus('#000000')
--    -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
--    :set_images()
--    :random()

require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'circle' })
require('events.new-tab-button').setup()

local config = Config:init()
:append(require('config.appearance'))
:append(require('config.bindings'))
:append(require('config.domains'))
:append(require('config.fonts'))
:append(require('config.general'))
:append(require('config.launch')).options

local wezterm = require("wezterm")
-- local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
-- modal.apply_to_config(config)

-- local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- +-------------------------------------------------+
-- | A | B | C |  TABS                   | X | Y | Z |
-- +-------------------------------------------------+
-- tabline.setup({
--   options = {
--     theme = 'catppuccin-mocha',
--     section_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--     component_separators = {
--       left = wezterm.nerdfonts.pl_left_soft_divider,
--       right = wezterm.nerdfonts.pl_right_soft_divider,
--     },
--     tab_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--     sections = {
--       tabline_a = { 'mode' },
--       tabline_b = { 'workspace' },
--       tabline_c = { ' ' },
--       tab_active = {
--         'index',
--         { Attribute = { Intensity = 'Bold' } },
--         { 'tab_title', padding = { left = 0, right = 1 } },
--         { 'zoomed', padding = 0 },
--       },
--       tab_inactive = {
--         'index',
--         { 'tab_title', padding = { left = 0, right = 1 } },
--       },
--       tabline_x = { ' ' },
--       tabline_y = { ' ' },
--       tabline_z = { 'domain' },
--     },
--   }
-- })
-- tabline.apply_to_config(config)

return config
