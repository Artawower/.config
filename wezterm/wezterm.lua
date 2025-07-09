local wezterm = require "wezterm"
local config = {}

-- config.font = wezterm.font "JetBrains Mono"
config.font = wezterm.font("JetBrains Mono", {weight = 400})
-- config.font = wezterm.font("Monaspace Neon frozen", {weight = 400})

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 15
config.font_size = 15.0
config.use_fancy_tab_bar = false
local act = wezterm.action

local dark_themes = {
    -- "Catppuccin Macchiato",
    "Catppuccin Frappe", 
    -- "Catppuccin Mocha",
    "Tokyo Night",
    "Dracula",
    "OneDark",
    "Rebecca (base16)"
}

local light_themes = {
    "Catppuccin Latte",
    "rose-pine-dawn",
    -- "aikofog (terminal.sexy)"
}

wezterm.on('window-config-reloaded', function(window, pane)
    local appearance = wezterm.gui.get_appearance()
    local window_id = window:window_id()
    local theme_index
    
    if appearance:find("Dark") then
        theme_index = (window_id % #dark_themes) + 1
        window:set_config_overrides({
            color_scheme = dark_themes[theme_index]
        })
        wezterm.log_info("Dark mode detected, using theme: " .. dark_themes[theme_index])
    else
        theme_index = (window_id % #light_themes) + 1
        window:set_config_overrides({
            color_scheme = light_themes[theme_index]
        })
        wezterm.log_info("Light mode detected, using theme: " .. light_themes[theme_index])
    end
end)

local function scheme_for_appearance(appearance)
    if appearance:find("Dark") then
        return dark_themes[1]
    else
        return light_themes[1]
    end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
-- config.color_scheme = "Atom (Gogh)"
-- config.color_scheme = "BlueBerryPie"
-- config.color_scheme = "ChallengerDeep"
-- config.color_scheme = "Dark Violet (base16)"

local wez_theme = wezterm.color.get_builtin_schemes()[config.color_scheme]
if not wez_theme then
    config.color_scheme = "Catppuccin Macchiato"
    wez_theme = wezterm.color.get_builtin_schemes()[config.color_scheme]
end

config.colors = {
    tab_bar = {
        -- The color of the strip that goes along the top of the window
        -- (does not apply when fancy tab bar is in use)
        background = wez_theme.background,
        -- The active tab is the one that has focus in the window
        inactive_tab_edge = wezterm.color.parse(wez_theme.background):darken(0.8),
        active_tab = {
            bg_color = wez_theme.brights[3],
            fg_color = wez_theme.background
        },
        inactive_tab = {
            bg_color = wez_theme.background,
            fg_color = wez_theme.foreground
        },
        inactive_tab_hover = {
            bg_color = wezterm.color.parse(wez_theme.background):lighten(0.1),
            fg_color = wezterm.color.parse(wez_theme.foreground):lighten(0.2)
        },
        new_tab = {
            bg_color = wez_theme.background,
            fg_color = wez_theme.foreground
        },
        new_tab_hover = {
            bg_color = wez_theme.brights[3],
            fg_color = wez_theme.background
        }
    }
}

config.keys = {
    -- {
    --     key = ".",
    --     mods = "CMD",
    --     action = act.PaneSelect {
    --         alphabet = "1234567890"
    --     }
    -- },
    {
        key = "w",
        mods = "CMD",
        action = wezterm.action.CloseCurrentPane {confirm = true}
    },
    {
        key = "s",
        mods = "CMD",
        action = wezterm.action.SendString(":w\n")
    },
    {
        key = ".",
        mods = "CMD",
        action = wezterm.action.SendString(":SwitchWindow\n")
    },
      {
    key = 'H',
    mods = 'SHIFT|CTRL',
    action = act.Search {
      Regex = '[a-f0-9]{6,}',
    },
  },
  -- search for the lowercase string "hash" matching the case exactly
  {
    key = 'H',
    mods = 'SHIFT|CTRL',
    action = act.Search { CaseSensitiveString = 'hash' },
  },
  -- search for the string "hash" matching regardless of case
  {
    key = 'H',
    mods = 'SHIFT|CTRL',
    action = act.Search { CaseInSensitiveString = 'hash' },
  },
}

config.default_prog = {"/Users/darkawower/.nix-profile/bin/fish", "-l"}
return config
