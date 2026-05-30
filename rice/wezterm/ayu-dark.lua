-- Theme: Ayu Dark
-- Source: https://github.com/dempfi/ayu
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.ayu-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#0a0e14",
    foreground    = "#b3b1ad",
    cursor_bg     = "#e6b450",
    cursor_border = "#e6b450",
    cursor_fg     = "#0a0e14",
    selection_bg  = "#273747",
    selection_fg  = "#b3b1ad",

    ansi    = { "#01060e", "#ea6c73", "#91b362", "#f9af4f", "#53bdfa", "#fae994", "#90e1c6", "#c7c7c7" },
    brights = { "#686868", "#f07178", "#c2d94c", "#ffb454", "#59c2ff", "#ffee99", "#95e6cb", "#ffffff" },
  },
}
