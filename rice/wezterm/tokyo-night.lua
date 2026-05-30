-- Theme: Tokyo Night
-- Source: https://github.com/enkia/tokyo-night-vscode-theme
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.tokyo-night")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#1A1B26",
    foreground    = "#C0CAF5",
    cursor_bg     = "#C0CAF5",
    cursor_border = "#C0CAF5",
    cursor_fg     = "#1A1B26",
    selection_bg  = "#283457",
    selection_fg  = "#C0CAF5",

    ansi    = { "#15161E", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#A9B1D6" },
    brights = { "#414868", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#C0CAF5" },
  },
}
