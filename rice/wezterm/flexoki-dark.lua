-- Theme: Flexoki Dark
-- Source: https://stephango.com/flexoki
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.flexoki-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#100F0F",
    foreground    = "#CECDC3",
    cursor_bg     = "#CECDC3",
    cursor_border = "#CECDC3",
    cursor_fg     = "#100F0F",
    selection_bg  = "#282726",
    selection_fg  = "#CECDC3",

    ansi    = { "#1C1B1A", "#D14D41", "#879A39", "#D0A215", "#4385BE", "#CE5D97", "#3AA99F", "#B7B5AC" },
    brights = { "#575653", "#D14D41", "#879A39", "#D0A215", "#4385BE", "#CE5D97", "#3AA99F", "#CECDC3" },
  },
}
