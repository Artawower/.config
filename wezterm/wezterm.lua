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

local function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        -- return "Dark Violet (base16)"
        -- return "Laser"
        -- return "Catppuccin Frappe"
        return "Catppuccin Macchiato"
    else
        return "Catppuccin Latte"
    end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
-- config.color_scheme = "Atom (Gogh)"
-- config.color_scheme = "BlueBerryPie"
-- config.color_scheme = "ChallengerDeep"
-- config.color_scheme = "Dark Violet (base16)"

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
