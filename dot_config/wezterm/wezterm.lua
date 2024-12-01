------------------------------------------------------
--               Wezterm configuration
------------------------------------------------------

local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end



local windows = require("windows") -- file located at ~/.wezterm/windows.lua
local linux = require("linux") -- file located at ~/.wezterm/linux.lua
local keymaps = require("keymaps")
local terminal = require("terminal")
local bar = wezterm.plugin.require "https://github.com/adriankarlen/bar.wezterm"


-- For windows host custom configuration
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	windows.options(config)
end

-- For linux host custom configuration
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	linux.options(config)
end

keymaps.options(config)
terminal.options(config)

-- Add spotify to bar
bar.apply_to_config(
  config,
  {
    modules = {
      spotify = {
        enabled = true,
      },
    },
  }
)


return config