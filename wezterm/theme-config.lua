
local wezterm = require "wezterm"

local M = {}

M.dark_themes = {
  "Catppuccin Frappe",
  "Laser",
  "Tokyo Night",
  "Dracula",
  "OneDark",
  "Rebecca (base16)"
}

M.light_themes = {
  "Catppuccin Latte",
  "Ayu Light (Gogh)",
  "Cupcake (base16)",
  "rose-pine-dawn",
}

M.window_themes = {}

function M.get_theme_overrides(theme_name)
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

function M.apply_theme_to_window(window, theme_name)
  local overrides = M.get_theme_overrides(theme_name)
  window:set_config_overrides(overrides)
  M.window_themes[window:window_id()] = theme_name
  wezterm.log_info("Theme for window " .. window:window_id() .. " set to: " .. theme_name)
end

function M.get_initial_theme_name()
  local appearance = wezterm.gui.get_appearance()
  return appearance:find("Dark") and M.dark_themes[1] or M.light_themes[1]
end

function M.get_appearance_themes()
  local appearance = wezterm.gui.get_appearance()
  return appearance:find("Dark") and M.dark_themes or M.light_themes
end

return M
