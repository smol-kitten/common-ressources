-- Theme: Ayu Light
-- Source: https://github.com/dempfi/ayu
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.ayu-light")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#FAFAFA",
    foreground    = "#575F66",
    cursor_bg     = "#FF6A00",
    cursor_border = "#FF6A00",
    cursor_fg     = "#FAFAFA",
    selection_bg  = "#D3D3D3",
    selection_fg  = "#575F66",

    ansi    = { "#0A0E14", "#FF3333", "#86B300", "#F29718", "#41A6D9", "#A37ACC", "#4DBF99", "#BFBDB6" },
    brights = { "#5C6773", "#FF6565", "#B8CC52", "#FFB454", "#73D8FF", "#D4BFFF", "#95E6CB", "#FFFFFF" },
  },
}
