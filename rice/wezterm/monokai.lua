-- Theme: Monokai
-- Source: https://monokai.pro
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.monokai")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#272822",
    foreground    = "#F8F8F2",
    cursor_bg     = "#F8F8F2",
    cursor_border = "#F8F8F2",
    cursor_fg     = "#272822",
    selection_bg  = "#75715E",
    selection_fg  = "#F8F8F2",

    ansi    = { "#272822", "#F92672", "#A6E22E", "#F4BF75", "#66D9E8", "#AE81FF", "#A1EFE4", "#F8F8F2" },
    brights = { "#75715E", "#F92672", "#A6E22E", "#F4BF75", "#66D9E8", "#AE81FF", "#A1EFE4", "#F9F8F5" },
  },
}
