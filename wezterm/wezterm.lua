local wezterm = require "wezterm"
local config = {}

config.font = wezterm.font("JetBrains Mono", {weight = 400})
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 15
config.font_size = 15.0
config.use_fancy_tab_bar = false
local act = wezterm.action

local dark_themes = {
    "Catppuccin Frappe",
    "Tokyo Night",
    "Dracula",
    "OneDark",
    "Rebecca (base16)"
}

local light_themes = {
    "Catppuccin Latte",
    "rose-pine-dawn",
}

-- This table will store the active theme name per window_id
local window_themes = {}

-- Returns a full configuration table for a given theme name.
local function get_theme_overrides(theme_name)
    local wez_theme = wezterm.color.get_builtin_schemes()[theme_name]
    if not wez_theme then
        wezterm.log_error("Theme '" .. theme_name .. "' not found, falling back to default.")
        theme_name = "Catppuccin Frappe"
        wez_theme = wezterm.color.get_builtin_schemes()[theme_name]
    end

    return {
        color_scheme = theme_name,
        colors = {
            tab_bar = {
                background = wez_theme.background,
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
    }
end

-- Applies a theme to the window and stores its name.
local function apply_theme_to_window(window, theme_name)
    local overrides = get_theme_overrides(theme_name)
    window:set_config_overrides(overrides)
    window_themes[window:window_id()] = theme_name
    wezterm.log_info("Theme for window " .. window:window_id() .. " set to: " .. theme_name)
end

-- Event handler for config reloads and new window creation.
wezterm.on('window-config-reloaded', function(window, pane)
    local window_id = window:window_id()
    local current_theme = window_themes[window_id]

    if current_theme then
        -- Re-apply the existing theme for this window to make it stick
        apply_theme_to_window(window, current_theme)
    else
        -- No theme has been set, apply a deterministic one
        local appearance = wezterm.gui.get_appearance()
        local themes = appearance:find("Dark") and dark_themes or light_themes
        local theme_name = themes[(window_id % #themes) + 1]
        apply_theme_to_window(window, theme_name)
    end
end)

-- Clean up the theme entry when a window is closed
wezterm.on("window-close", function(window, pane)
    window_themes[window:window_id()] = nil
end)

-- Set initial configuration. The 'window-config-reloaded' event will handle the
-- per-window theme application shortly after the window opens.
local function get_initial_theme_name()
    local appearance = wezterm.gui.get_appearance()
    return appearance:find("Dark") and dark_themes[1] or light_themes[1]
end

local initial_overrides = get_theme_overrides(get_initial_theme_name())
config.color_scheme = initial_overrides.color_scheme
config.colors = initial_overrides.colors

config.keys = {
    {
        key = "T",
        mods = "CMD|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            -- Pick a new random theme and apply it
            local appearance = wezterm.gui.get_appearance()
            local themes = appearance:find("Dark") and dark_themes or light_themes
            math.randomseed(os.time())
            local theme_name = themes[math.random(#themes)]
            apply_theme_to_window(window, theme_name)
        end),
    },
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
        action = act.Search { Regex = '[a-f0-9]{6,}' },
    },
    {
        key = 'H',
        mods = 'SHIFT|CTRL',
        action = act.Search { CaseSensitiveString = 'hash' },
    },
    {
        key = 'H',
        mods = 'SHIFT|CTRL',
        action = act.Search { CaseInSensitiveString = 'hash' },
    },
}

config.default_prog = {"/Users/darkawower/.nix-profile/bin/fish", "-l"}
return config