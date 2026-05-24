-- Theme: Gruvbox Dark
-- Source: https://github.com/morhetz/gruvbox
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.gruvbox-dark")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#282828",
    foreground    = "#EBDBB2",
    cursor_bg     = "#EBDBB2",
    cursor_border = "#EBDBB2",
    cursor_fg     = "#282828",
    selection_bg  = "#3C3836",
    selection_fg  = "#EBDBB2",

    ansi    = { "#282828", "#CC241D", "#98971A", "#D79921", "#458588", "#B16286", "#689D6A", "#A89984" },
    brights = { "#928374", "#FB4934", "#B8BB26", "#FABD2F", "#83A598", "#D3869B", "#8EC07C", "#EBDBB2" },
  },
}
