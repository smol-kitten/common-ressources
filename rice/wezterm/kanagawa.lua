-- Theme: Kanagawa
-- Source: https://github.com/rebelot/kanagawa.nvim
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.kanagawa")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#1f1f28",
    foreground    = "#dcd7ba",
    cursor_bg     = "#c8c093",
    cursor_border = "#c8c093",
    cursor_fg     = "#1f1f28",
    selection_bg  = "#2d4f67",
    selection_fg  = "#dcd7ba",

    ansi    = { "#16161d", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
    brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
  },
}
