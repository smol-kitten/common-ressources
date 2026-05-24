-- Theme: Solarized Light
-- Source: https://ethanschoonover.com/solarized/
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.solarized-light")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#FDF6E3",
    foreground    = "#657B83",
    cursor_bg     = "#586E75",
    cursor_border = "#586E75",
    cursor_fg     = "#FDF6E3",
    selection_bg  = "#EEE8D5",
    selection_fg  = "#657B83",

    ansi    = { "#073642", "#DC322F", "#859900", "#B58900", "#268BD2", "#D33682", "#2AA198", "#EEE8D5" },
    brights = { "#002B36", "#CB4B16", "#586E75", "#657B83", "#839496", "#6C71C4", "#93A1A1", "#FDF6E3" },
  },
}
