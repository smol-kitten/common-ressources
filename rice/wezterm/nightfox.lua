-- Theme: Nightfox
-- Source: https://github.com/EdenEast/nightfox.nvim
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.nightfox")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#192330",
    foreground    = "#CDCECF",
    cursor_bg     = "#CDCECF",
    cursor_border = "#CDCECF",
    cursor_fg     = "#192330",
    selection_bg  = "#2B3B51",
    selection_fg  = "#CDCECF",

    ansi    = { "#393B44", "#C94F6D", "#81B29A", "#DBC074", "#719CD6", "#9D79D6", "#63CDCF", "#DFDFE0" },
    brights = { "#575860", "#D16983", "#8EBD9B", "#E0C989", "#86ABDC", "#B48EAD", "#7AD5D6", "#E4E4E5" },
  },
}
