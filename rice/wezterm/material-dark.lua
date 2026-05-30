-- Theme: Material Dark
-- Source: https://material-theme.com
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.material-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#212121",
    foreground    = "#EEFFFF",
    cursor_bg     = "#FFCC00",
    cursor_border = "#FFCC00",
    cursor_fg     = "#212121",
    selection_bg  = "#546E7A",
    selection_fg  = "#EEFFFF",

    ansi    = { "#546E7A", "#FF5370", "#C3E88D", "#FFCB6B", "#82AAFF", "#C792EA", "#89DDFF", "#EEFFFF" },
    brights = { "#B0BEC5", "#FF5370", "#C3E88D", "#FFCB6B", "#82AAFF", "#C792EA", "#89DDFF", "#FFFFFF" },
  },
}
