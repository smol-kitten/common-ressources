-- Theme: Nord
-- Source: https://www.nordtheme.com
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.nord")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#2E3440",
    foreground    = "#D8DEE9",
    cursor_bg     = "#D8DEE9",
    cursor_border = "#D8DEE9",
    cursor_fg     = "#2E3440",
    selection_bg  = "#4C566A",
    selection_fg  = "#D8DEE9",

    ansi    = { "#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0" },
    brights = { "#4C566A", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#8FBCBB", "#ECEFF4" },
  },
}
