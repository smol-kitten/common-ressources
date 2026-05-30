-- Theme: One Dark
-- Source: https://github.com/atom/atom
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.one-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#282C34",
    foreground    = "#ABB2BF",
    cursor_bg     = "#528BFF",
    cursor_border = "#528BFF",
    cursor_fg     = "#282C34",
    selection_bg  = "#3E4451",
    selection_fg  = "#ABB2BF",

    ansi    = { "#282C34", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#ABB2BF" },
    brights = { "#5C6370", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#FFFFFF" },
  },
}
