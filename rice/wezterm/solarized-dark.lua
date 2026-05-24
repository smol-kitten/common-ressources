-- Theme: Solarized Dark
-- Source: https://ethanschoonover.com/solarized/
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.solarized-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#002B36",
    foreground    = "#839496",
    cursor_bg     = "#839496",
    cursor_border = "#839496",
    cursor_fg     = "#002B36",
    selection_bg  = "#073642",
    selection_fg  = "#839496",

    ansi    = { "#073642", "#DC322F", "#859900", "#B58900", "#268BD2", "#D33682", "#2AA198", "#EEE8D5" },
    brights = { "#002B36", "#CB4B16", "#586E75", "#657B83", "#839496", "#6C71C4", "#93A1A1", "#FDF6E3" },
  },
}
