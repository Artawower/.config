local wezterm = require "wezterm"
local config = {}

-- config.font = wezterm.font "JetBrains Mono"
config.font = wezterm.font("JetBrains Mono", {weight = 400})

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.font_size = 15.0
config.use_fancy_tab_bar = false
local act = wezterm.action

local function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        return "Catppuccin Macchiato"
    else
        return "Catppuccin Latte"
    end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
local wez_theme = wezterm.color.get_builtin_schemes()[config.color_scheme]

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
    {
        key = ".",
        mods = "CMD",
        action = act.PaneSelect {
            alphabet = "1234567890"
        }
    },
    {
        key = "w",
        mods = "CMD",
        action = wezterm.action.CloseCurrentPane {confirm = true}
    }
}
return config
