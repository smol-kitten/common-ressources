-- Theme: Palenight
-- Source: https://github.com/whizkydee/vscode-palenight-theme
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.palenight")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#292d3e",
    foreground    = "#a6accd",
    cursor_bg     = "#a6accd",
    cursor_border = "#a6accd",
    cursor_fg     = "#292d3e",
    selection_bg  = "#32374d",
    selection_fg  = "#a6accd",

    ansi    = { "#292d3e", "#f07178", "#c3e88d", "#ffcb6b", "#82aaff", "#c792ea", "#89ddff", "#d0d0d0" },
    brights = { "#434758", "#ff8b92", "#ddffa7", "#ffe585", "#9cc4ff", "#e1acff", "#a3f7ff", "#ffffff" },
  },
}
