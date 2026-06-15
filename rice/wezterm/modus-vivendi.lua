-- Theme: Modus Vivendi
-- Source: https://protesilaos.com/emacs/modus-themes
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.modus-vivendi")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "#000000",
    foreground    = "#FFFFFF",
    cursor_bg     = "#FFFFFF",
    cursor_border = "#FFFFFF",
    cursor_fg     = "#000000",
    selection_bg  = "#2C2C2C",
    selection_fg  = "#FFFFFF",

    ansi    = { "#1E1E1E", "#FF5F5F", "#44BC44", "#D0BC00", "#2FAFFF", "#FEACD0", "#00D3D0", "#D0D0D0" },
    brights = { "#595959", "#FF7F9F", "#70C900", "#EFEF00", "#79A8FF", "#F78FE7", "#4AE2F0", "#FFFFFF" },
  },
}
