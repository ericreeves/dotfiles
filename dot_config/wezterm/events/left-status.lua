local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]

---@type table<string, Cells.SegmentColors>
-- Catppuccin Mocha colors
local colors = {
   default = { bg = '#b4befe', fg = '#11111B' },  -- Lavender bg, Crust fg
   scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#b4befe' },  -- Lavender
}

local cells = Cells:new()

cells
   :add_segment(1, GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment(2, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(3, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(4, GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))

M.setup = function()
   wezterm.on('update-right-status', function(window, _pane)
      local name = window:active_key_table()
      local res = {}

      if name then
         cells
            :update_segment_text(2, GLYPH_KEY_TABLE)
            :update_segment_text(3, ' ' .. string.upper(name))
         res = cells:render_all()
      end

      if window:leader_is_active() then
         cells:update_segment_text(2, GLYPH_KEY):update_segment_text(3, ' ')
         res = cells:render_all()
      end
      window:set_left_status(wezterm.format(res))
   end)
end

return M
