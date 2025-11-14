local wezterm = require "wezterm"
local theme_switcher = require "theme-switcher"
local theme_config = require "theme-config"
local config = {}

config.font = wezterm.font("JetBrains Mono", { weight = 400 })
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 25
config.font_size = 15.0
config.use_fancy_tab_bar = false
config.enable_kitty_keyboard = true
config.enable_kitty_graphics = true
config.window_padding = {
  left = 32,
  right = 32,
  top = 32,
  bottom = 32
}
config.enable_tab_bar = false
config.enable_csi_u_key_encoding = true

local act = wezterm.action

wezterm.on(
  "window-config-reloaded",
  function(window, pane)
    local window_id = window:window_id()
    local current_theme = theme_config.window_themes[window_id]

    if current_theme then
      theme_config.apply_theme_to_window(window, current_theme)
    else
      local themes = theme_config.get_appearance_themes()
      local theme_name = themes[(window_id % #themes) + 1]
      theme_config.apply_theme_to_window(window, theme_name)
    end
  end
)

wezterm.on(
  "window-close",
  function(window, pane)
    theme_config.window_themes[window:window_id()] = nil
  end
)

local initial_overrides = theme_config.get_theme_overrides(theme_config.get_initial_theme_name())
config.color_scheme = initial_overrides.color_scheme
config.colors = initial_overrides.colors

config.keys = {
  {
    key = "T",
    mods = "CMD|SHIFT",
    action = wezterm.action_callback(
      function(window, pane)
        local themes = theme_config.get_appearance_themes()
        math.randomseed(os.time())
        local theme_name = themes[math.random(#themes)]
        theme_config.apply_theme_to_window(window, theme_name)
      end
    )
  },
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentPane { confirm = true }
  },
  {
    key = ".",
    mods = "CMD",
    action = wezterm.action.SendString(":SwitchWindow\n")
  },
  {
    key = "RightArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.MoveTabRelative(1)
  },
  {
    key = "LeftArrow",
    mods = "CMD|SHIFT",
    action = wezterm.action.MoveTabRelative(-1)
  },
  {
    key = "`",
    mods = "CTRL",
    action = act.SendKey { key = "b", mods = "CTRL" }
  },
  {
    key = "~",
    mods = "CTRL|SHIFT",
    action = act.SendKey { key = "b", mods = "CTRL" }
  },
  {
    key = "f",
    mods = "CMD",
    action = wezterm.action.DisableDefaultAssignment
  },
  {
    key = "r",
    mods = "CMD|SHIFT",
    action = wezterm.action.ReloadConfiguration
  },
  {
    key = "y",
    mods = "CMD|SHIFT",
    action = wezterm.action_callback(theme_switcher.theme_switcher)
  }
}

config.default_prog = { "/Users/darkawower/.nix-profile/bin/fish" }
config.set_environment_variables = {
  PATH = "/Users/darkawower/.nix-profile/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
}
return config
