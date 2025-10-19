local wezterm = require "wezterm"
local theme_config = require "theme-config"
local act = wezterm.action
local M = {}

M.theme_switcher = function(window, pane)
  local our_themes = theme_config.get_appearance_themes()
  local schemes = wezterm.get_builtin_color_schemes()
  local choices = {}
  
  for _, theme_name in ipairs(our_themes) do
    if schemes[theme_name] then
      table.insert(choices, { label = "⭐ " .. theme_name })
    end
  end
  
  for name, _ in pairs(schemes) do
    local is_our_theme = false
    for _, our_theme in ipairs(our_themes) do
      if our_theme == name then
        is_our_theme = true
        break
      end
    end
    
    if not is_our_theme then
      table.insert(choices, { label = name })
    end
  end
  
  table.sort(choices, function(a, b) return a.label < b.label end)

  window:perform_action(
    act.InputSelector{
      title = "🎨 Pick a Theme!",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(inner_window, inner_pane, _id, label)
        local theme_name = label:gsub("^⭐ ", "")
        theme_config.apply_theme_to_window(inner_window, theme_name)
      end),
    },
    pane
  )
end

return M
