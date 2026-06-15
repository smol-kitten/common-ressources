#!/usr/bin/env node
// Generates per-theme config files for Arch Linux ricing tools.
// Reads colors/terminal/themes.json and writes one file per theme for each tool.
//
// Usage:
//   node rice/generate.js

'use strict';

const fs   = require('fs');
const path = require('path');

const ROOT       = path.resolve(__dirname, '..');
const THEMES_FILE = path.join(ROOT, 'colors', 'terminal', 'themes.json');
const RICE_DIR   = __dirname;

const themes = JSON.parse(fs.readFileSync(THEMES_FILE, 'utf8'));

// ── helpers ────────────────────────────────────────────────────────────────────

/** Strip '#' prefix from a hex colour string. */
function stripHash(hex) { return hex.replace(/^#/, ''); }

/** Ensure a directory exists. */
function ensureDir(dir) { fs.mkdirSync(dir, { recursive: true }); }

/** Write a file, creating parent dirs as needed. */
function write(filePath, content) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content, 'utf8');
  console.log('  wrote', path.relative(ROOT, filePath));
}

// ── generators ─────────────────────────────────────────────────────────────────

function genAlacritty(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}

[colors.primary]
background = "${theme.background}"
foreground = "${theme.foreground}"

[colors.cursor]
cursor = "${theme.cursor}"
text   = "${theme.background}"

[colors.selection]
background = "${theme['selection-background']}"
text       = "${theme.foreground}"

[colors.normal]
black   = "${c['black']}"
red     = "${c['red']}"
green   = "${c['green']}"
yellow  = "${c['yellow']}"
blue    = "${c['blue']}"
magenta = "${c['magenta']}"
cyan    = "${c['cyan']}"
white   = "${c['white']}"

[colors.bright]
black   = "${c['bright-black']}"
red     = "${c['bright-red']}"
green   = "${c['bright-green']}"
yellow  = "${c['bright-yellow']}"
blue    = "${c['bright-blue']}"
magenta = "${c['bright-magenta']}"
cyan    = "${c['bright-cyan']}"
white   = "${c['bright-white']}"
`;
  write(path.join(RICE_DIR, 'alacritty', `${theme.slug}.toml`), content);
}

function genKitty(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}

background              ${theme.background}
foreground              ${theme.foreground}
cursor                  ${theme.cursor}
selection_background    ${theme['selection-background']}
selection_foreground    ${theme.foreground}

# Normal colors (0-7)
color0  ${c['black']}
color1  ${c['red']}
color2  ${c['green']}
color3  ${c['yellow']}
color4  ${c['blue']}
color5  ${c['magenta']}
color6  ${c['cyan']}
color7  ${c['white']}

# Bright colors (8-15)
color8  ${c['bright-black']}
color9  ${c['bright-red']}
color10 ${c['bright-green']}
color11 ${c['bright-yellow']}
color12 ${c['bright-blue']}
color13 ${c['bright-magenta']}
color14 ${c['bright-cyan']}
color15 ${c['bright-white']}
`;
  write(path.join(RICE_DIR, 'kitty', `${theme.slug}.conf`), content);
}

function genHyprland(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Include in hyprland.conf: source = ~/.config/hypr/colors.conf

$color_background = rgb(${stripHash(theme.background)})
$color_foreground = rgb(${stripHash(theme.foreground)})
$color_cursor     = rgb(${stripHash(theme.cursor)})
$color_selection  = rgb(${stripHash(theme['selection-background'])})

$color_black      = rgb(${stripHash(c['black'])})
$color_red        = rgb(${stripHash(c['red'])})
$color_green      = rgb(${stripHash(c['green'])})
$color_yellow     = rgb(${stripHash(c['yellow'])})
$color_blue       = rgb(${stripHash(c['blue'])})
$color_magenta    = rgb(${stripHash(c['magenta'])})
$color_cyan       = rgb(${stripHash(c['cyan'])})
$color_white      = rgb(${stripHash(c['white'])})

$color_bright_black   = rgb(${stripHash(c['bright-black'])})
$color_bright_red     = rgb(${stripHash(c['bright-red'])})
$color_bright_green   = rgb(${stripHash(c['bright-green'])})
$color_bright_yellow  = rgb(${stripHash(c['bright-yellow'])})
$color_bright_blue    = rgb(${stripHash(c['bright-blue'])})
$color_bright_magenta = rgb(${stripHash(c['bright-magenta'])})
$color_bright_cyan    = rgb(${stripHash(c['bright-cyan'])})
$color_bright_white   = rgb(${stripHash(c['bright-white'])})
`;
  write(path.join(RICE_DIR, 'hyprland', `${theme.slug}.conf`), content);
}

function genWaybar(theme) {
  const c = theme.colors;
  const content = `/* Theme: ${theme.name} */
/* Source: ${theme.source} */
/* Include in waybar/style.css: @import url("colors.css"); */

:root {
  --background:        ${theme.background};
  --foreground:        ${theme.foreground};
  --cursor:            ${theme.cursor};
  --selection:         ${theme['selection-background']};

  --black:             ${c['black']};
  --red:               ${c['red']};
  --green:             ${c['green']};
  --yellow:            ${c['yellow']};
  --blue:              ${c['blue']};
  --magenta:           ${c['magenta']};
  --cyan:              ${c['cyan']};
  --white:             ${c['white']};

  --bright-black:      ${c['bright-black']};
  --bright-red:        ${c['bright-red']};
  --bright-green:      ${c['bright-green']};
  --bright-yellow:     ${c['bright-yellow']};
  --bright-blue:       ${c['bright-blue']};
  --bright-magenta:    ${c['bright-magenta']};
  --bright-cyan:       ${c['bright-cyan']};
  --bright-white:      ${c['bright-white']};
}
`;
  write(path.join(RICE_DIR, 'waybar', `${theme.slug}.css`), content);
}

function genRofi(theme) {
  const c = theme.colors;
  const content = `/* Theme: ${theme.name} */
/* Source: ${theme.source} */
/* Usage: rofi -theme ~/.config/rofi/colors.rasi */

* {
    background-color:              ${theme.background};
    foreground:                    ${theme.foreground};

    normal-background:             ${theme.background};
    normal-foreground:             ${theme.foreground};
    selected-normal-background:    ${c['blue']};
    selected-normal-foreground:    ${theme.background};

    active-background:             ${c['green']};
    active-foreground:             ${theme.background};
    selected-active-background:    ${c['bright-green']};
    selected-active-foreground:    ${theme.background};

    urgent-background:             ${c['red']};
    urgent-foreground:             ${theme.background};
    selected-urgent-background:    ${c['bright-red']};
    selected-urgent-foreground:    ${theme.background};

    border-color:                  ${c['bright-black']};
    separatorcolor:                ${c['bright-black']};
}
`;
  write(path.join(RICE_DIR, 'rofi', `${theme.slug}.rasi`), content);
}

function genDunst(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Include in dunstrc: [global] section, or source this file

[urgency_low]
    background = "${theme.background}"
    foreground = "${theme.foreground}"
    frame_color = "${c['blue']}"

[urgency_normal]
    background = "${theme.background}"
    foreground = "${theme.foreground}"
    frame_color = "${c['blue']}"

[urgency_critical]
    background = "${c['red']}"
    foreground = "${theme.background}"
    frame_color = "${c['bright-red']}"
`;
  write(path.join(RICE_DIR, 'dunst', `${theme.slug}.conf`), content);
}

function genWezterm(theme) {
  const c = theme.colors;
  const ansi = [
    c['black'], c['red'], c['green'], c['yellow'],
    c['blue'],  c['magenta'], c['cyan'], c['white'],
  ];
  const brights = [
    c['bright-black'], c['bright-red'],   c['bright-green'],  c['bright-yellow'],
    c['bright-blue'],  c['bright-magenta'], c['bright-cyan'], c['bright-white'],
  ];
  const fmtList = (arr) => arr.map(v => `"${v}"`).join(', ');

  const content = `-- Theme: ${theme.name}
-- Source: ${theme.source}
-- Usage in wezterm.lua:
--   local scheme = require("rice.wezterm.${theme.slug}")
--   config.colors = scheme.colors

return {
  colors = {
    background    = "${theme.background}",
    foreground    = "${theme.foreground}",
    cursor_bg     = "${theme.cursor}",
    cursor_border = "${theme.cursor}",
    cursor_fg     = "${theme.background}",
    selection_bg  = "${theme['selection-background']}",
    selection_fg  = "${theme.foreground}",

    ansi    = { ${fmtList(ansi)} },
    brights = { ${fmtList(brights)} },
  },
}
`;
  write(path.join(RICE_DIR, 'wezterm', `${theme.slug}.lua`), content);
}

function genTmux(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Usage: add to ~/.tmux.conf or source this file
#   source-file ~/.config/tmux/themes/${theme.slug}.conf

# Status bar
set -g status-style "bg=${theme.background},fg=${theme.foreground}"
set -g status-left-style "fg=${c['green']},bold"
set -g status-right-style "fg=${c['bright-black']}"

# Active window tab
set -g window-status-current-style "fg=${theme.background},bg=${c['blue']},bold"
set -g window-status-current-format " #I:#W "

# Inactive window tab
set -g window-status-style "fg=${c['bright-black']},bg=${theme.background}"
set -g window-status-format " #I:#W "

# Pane borders
set -g pane-border-style "fg=${c['bright-black']}"
set -g pane-active-border-style "fg=${c['blue']}"

# Message bar
set -g message-style "bg=${c['yellow']},fg=${theme.background}"

# Selection in copy mode
set -g mode-style "bg=${theme['selection-background']},fg=${theme.foreground}"

# Clock
set -g clock-mode-colour "${c['blue']}"
`;
  write(path.join(RICE_DIR, 'tmux', `${theme.slug}.conf`), content);
}

function genGhostty(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Usage: add to ~/.config/ghostty/config
#   theme = ${theme.slug}

background = ${theme.background.slice(1)}
foreground = ${theme.foreground.slice(1)}
cursor-color = ${theme.cursor.slice(1)}
selection-background = ${theme['selection-background'].slice(1)}
selection-foreground = ${theme.foreground.slice(1)}

palette = 0=${c['black']}
palette = 1=${c['red']}
palette = 2=${c['green']}
palette = 3=${c['yellow']}
palette = 4=${c['blue']}
palette = 5=${c['magenta']}
palette = 6=${c['cyan']}
palette = 7=${c['white']}
palette = 8=${c['bright-black']}
palette = 9=${c['bright-red']}
palette = 10=${c['bright-green']}
palette = 11=${c['bright-yellow']}
palette = 12=${c['bright-blue']}
palette = 13=${c['bright-magenta']}
palette = 14=${c['bright-cyan']}
palette = 15=${c['bright-white']}
`;
  write(path.join(RICE_DIR, 'ghostty', `${theme.slug}`), content);
}

function genVSCode(theme) {
  const c = theme.colors;
  const isLight = parseInt(theme.background.slice(1, 3), 16) > 128;
  const obj = {
    name: theme.name,
    type: isLight ? 'light' : 'dark',
    colors: {
      'editor.background': theme.background,
      'editor.foreground': theme.foreground,
      'editorCursor.foreground': theme.cursor,
      'editor.selectionBackground': theme['selection-background'],
      'terminal.background': theme.background,
      'terminal.foreground': theme.foreground,
      'terminal.ansiBlack': c['black'],
      'terminal.ansiRed': c['red'],
      'terminal.ansiGreen': c['green'],
      'terminal.ansiYellow': c['yellow'],
      'terminal.ansiBlue': c['blue'],
      'terminal.ansiMagenta': c['magenta'],
      'terminal.ansiCyan': c['cyan'],
      'terminal.ansiWhite': c['white'],
      'terminal.ansiBrightBlack': c['bright-black'],
      'terminal.ansiBrightRed': c['bright-red'],
      'terminal.ansiBrightGreen': c['bright-green'],
      'terminal.ansiBrightYellow': c['bright-yellow'],
      'terminal.ansiBrightBlue': c['bright-blue'],
      'terminal.ansiBrightMagenta': c['bright-magenta'],
      'terminal.ansiBrightCyan': c['bright-cyan'],
      'terminal.ansiBrightWhite': c['bright-white'],
      'activityBar.background': theme.background,
      'sideBar.background': theme.background,
      'statusBar.background': c['blue'],
      'statusBar.foreground': theme.background,
      'titleBar.activeBackground': theme.background,
      'titleBar.activeForeground': theme.foreground,
    },
    tokenColors: [
      { scope: 'comment', settings: { foreground: c['bright-black'], fontStyle: 'italic' } },
      { scope: 'string', settings: { foreground: c['green'] } },
      { scope: ['keyword', 'storage'], settings: { foreground: c['magenta'] } },
      { scope: ['entity.name.function', 'support.function'], settings: { foreground: c['blue'] } },
      { scope: ['entity.name.type', 'entity.name.class'], settings: { foreground: c['yellow'] } },
      { scope: 'variable', settings: { foreground: theme.foreground } },
      { scope: 'constant.numeric', settings: { foreground: c['cyan'] } },
      { scope: 'constant.language', settings: { foreground: c['red'] } },
    ],
  };
  write(path.join(RICE_DIR, 'vscode', `${theme.slug}.json`), JSON.stringify(obj, null, 2));
}

function genWindowsTerminal(theme) {
  const c = theme.colors;
  const scheme = {
    name: theme.name,
    _source: theme.source,
    background: theme.background,
    foreground: theme.foreground,
    cursorColor: theme.cursor,
    selectionBackground: theme['selection-background'],
    black: c['black'],
    red: c['red'],
    green: c['green'],
    yellow: c['yellow'],
    blue: c['blue'],
    purple: c['magenta'],
    cyan: c['cyan'],
    white: c['white'],
    brightBlack: c['bright-black'],
    brightRed: c['bright-red'],
    brightGreen: c['bright-green'],
    brightYellow: c['bright-yellow'],
    brightBlue: c['bright-blue'],
    brightPurple: c['bright-magenta'],
    brightCyan: c['bright-cyan'],
    brightWhite: c['bright-white'],
  };
  write(path.join(RICE_DIR, 'windows-terminal', `${theme.slug}.json`), JSON.stringify(scheme, null, 2));
}

function genHelix(theme) {
  const c = theme.colors;
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Usage: copy to ~/.config/helix/themes/${theme.slug}.toml
#   then set theme = "${theme.slug}" in ~/.config/helix/config.toml

"ui.background"           = { bg = "background" }
"ui.background.separator" = { fg = "bright-black" }
"ui.text"                 = { fg = "foreground" }
"ui.text.focus"           = { fg = "foreground", modifiers = ["bold"] }
"ui.cursor"               = { fg = "background", bg = "cursor" }
"ui.cursor.match"         = { fg = "background", bg = "yellow" }
"ui.cursor.insert"        = { fg = "background", bg = "green" }
"ui.cursor.select"        = { fg = "background", bg = "blue" }
"ui.selection"            = { bg = "selection" }
"ui.linenr"               = { fg = "bright-black" }
"ui.linenr.selected"      = { fg = "foreground", modifiers = ["bold"] }
"ui.statusline"           = { fg = "foreground", bg = "black" }
"ui.statusline.inactive"  = { fg = "bright-black", bg = "black" }
"ui.statusline.normal"    = { fg = "background", bg = "blue", modifiers = ["bold"] }
"ui.statusline.insert"    = { fg = "background", bg = "green", modifiers = ["bold"] }
"ui.statusline.select"    = { fg = "background", bg = "magenta", modifiers = ["bold"] }
"ui.popup"                = { bg = "black" }
"ui.popup.info"           = { bg = "black" }
"ui.window"               = { fg = "bright-black" }
"ui.help"                 = { fg = "foreground", bg = "black" }
"ui.menu"                 = { fg = "foreground", bg = "black" }
"ui.menu.selected"        = { fg = "background", bg = "blue" }
"ui.menu.scroll"          = { fg = "blue", bg = "black" }
"ui.virtual.ruler"        = { bg = "black" }
"ui.virtual.inlay-hint"   = { fg = "bright-black" }

"diagnostic.error"   = { underline = { color = "red",    style = "curl" } }
"diagnostic.warning" = { underline = { color = "yellow", style = "curl" } }
"diagnostic.info"    = { underline = { color = "blue",   style = "curl" } }
"diagnostic.hint"    = { underline = { color = "cyan",   style = "curl" } }
"error"   = { fg = "red" }
"warning" = { fg = "yellow" }
"info"    = { fg = "blue" }
"hint"    = { fg = "cyan" }

"comment"                = { fg = "bright-black", modifiers = ["italic"] }
"string"                 = { fg = "green" }
"string.regexp"          = { fg = "cyan" }
"string.special"         = { fg = "cyan" }
"constant"               = { fg = "red" }
"constant.numeric"       = { fg = "cyan" }
"constant.builtin"       = { fg = "red" }
"constant.character"     = { fg = "yellow" }
"keyword"                = { fg = "magenta", modifiers = ["bold"] }
"keyword.function"       = { fg = "magenta" }
"keyword.control"        = { fg = "magenta" }
"keyword.control.return" = { fg = "magenta", modifiers = ["bold"] }
"keyword.operator"       = { fg = "magenta" }
"keyword.directive"      = { fg = "magenta" }
"function"               = { fg = "blue" }
"function.macro"         = { fg = "cyan" }
"function.builtin"       = { fg = "cyan" }
"type"                   = { fg = "yellow" }
"type.builtin"           = { fg = "yellow", modifiers = ["italic"] }
"constructor"            = { fg = "blue" }
"variable"               = { fg = "foreground" }
"variable.builtin"       = { fg = "red" }
"variable.parameter"     = { fg = "foreground", modifiers = ["italic"] }
"variable.other.member"  = { fg = "foreground" }
"attribute"              = { fg = "blue" }
"namespace"              = { fg = "cyan" }
"label"                  = { fg = "blue" }
"operator"               = { fg = "magenta" }
"punctuation"            = { fg = "foreground" }
"punctuation.delimiter"  = { fg = "foreground" }
"punctuation.bracket"    = { fg = "foreground" }
"tag"                    = { fg = "red" }
"tag.attribute"          = { fg = "blue" }

"markup.heading"         = { fg = "blue", modifiers = ["bold"] }
"markup.raw"             = { fg = "green" }
"markup.bold"            = { modifiers = ["bold"] }
"markup.italic"          = { modifiers = ["italic"] }
"markup.link.url"        = { fg = "cyan", modifiers = ["underlined"] }
"markup.link.text"       = { fg = "blue" }
"markup.quote"           = { fg = "bright-black", modifiers = ["italic"] }

[palette]
background  = "${theme.background}"
foreground  = "${theme.foreground}"
cursor      = "${theme.cursor}"
selection   = "${theme['selection-background']}"
black       = "${c['black']}"
red         = "${c['red']}"
green       = "${c['green']}"
yellow      = "${c['yellow']}"
blue        = "${c['blue']}"
magenta     = "${c['magenta']}"
cyan        = "${c['cyan']}"
white       = "${c['white']}"
bright-black    = "${c['bright-black']}"
bright-red      = "${c['bright-red']}"
bright-green    = "${c['bright-green']}"
bright-yellow   = "${c['bright-yellow']}"
bright-blue     = "${c['bright-blue']}"
bright-magenta  = "${c['bright-magenta']}"
bright-cyan     = "${c['bright-cyan']}"
bright-white    = "${c['bright-white']}"
`;
  write(path.join(RICE_DIR, 'helix', `${theme.slug}.toml`), content);
}

function genFoot(theme) {
  const c = theme.colors;
  const sh = (hex) => hex.replace(/^#/, '');
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Usage: include in ~/.config/foot/foot.ini:
#   include=~/.config/foot/themes/${theme.slug}.ini

[colors]
background=${sh(theme.background)}
foreground=${sh(theme.foreground)}

selection-background=${sh(theme['selection-background'])}
selection-foreground=${sh(theme.foreground)}

regular0=${sh(c['black'])}
regular1=${sh(c['red'])}
regular2=${sh(c['green'])}
regular3=${sh(c['yellow'])}
regular4=${sh(c['blue'])}
regular5=${sh(c['magenta'])}
regular6=${sh(c['cyan'])}
regular7=${sh(c['white'])}

bright0=${sh(c['bright-black'])}
bright1=${sh(c['bright-red'])}
bright2=${sh(c['bright-green'])}
bright3=${sh(c['bright-yellow'])}
bright4=${sh(c['bright-blue'])}
bright5=${sh(c['bright-magenta'])}
bright6=${sh(c['bright-cyan'])}
bright7=${sh(c['bright-white'])}
`;
  write(path.join(RICE_DIR, 'foot', `${theme.slug}.ini`), content);
}

function genNvim(theme) {
  const c = theme.colors;
  const content = `-- Theme: ${theme.name}
-- Source: ${theme.source}
-- Usage: dofile(vim.fn.stdpath("config") .. "/lua/rice/${theme.slug}.lua")
--   or copy to ~/.config/nvim/colors/${theme.slug}.lua

local hi = vim.api.nvim_set_hl

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "${theme.slug}"

local is_light = ${parseInt(theme.background.slice(1, 3), 16) > 128}
vim.o.background = is_light and "light" or "dark"

-- Editor chrome
hi(0, "Normal",       { bg = "${theme.background}", fg = "${theme.foreground}" })
hi(0, "NormalFloat",  { bg = "${c['black']}", fg = "${theme.foreground}" })
hi(0, "NormalNC",     { bg = "${theme.background}", fg = "${c['bright-black']}" })
hi(0, "SignColumn",   { bg = "${theme.background}" })
hi(0, "LineNr",       { fg = "${c['bright-black']}" })
hi(0, "CursorLine",   { bg = "${theme['selection-background']}" })
hi(0, "CursorLineNr", { fg = "${theme.foreground}", bold = true })
hi(0, "CursorColumn", { bg = "${theme['selection-background']}" })
hi(0, "Visual",       { bg = "${theme['selection-background']}" })
hi(0, "VisualNOS",    { bg = "${theme['selection-background']}" })
hi(0, "Search",       { bg = "${c['yellow']}", fg = "${theme.background}" })
hi(0, "IncSearch",    { bg = "${c['bright-yellow']}", fg = "${theme.background}" })
hi(0, "CurSearch",    { bg = "${c['bright-yellow']}", fg = "${theme.background}" })
hi(0, "StatusLine",   { bg = "${c['black']}", fg = "${theme.foreground}" })
hi(0, "StatusLineNC", { bg = "${c['black']}", fg = "${c['bright-black']}" })
hi(0, "VertSplit",    { fg = "${c['bright-black']}" })
hi(0, "WinSeparator", { fg = "${c['bright-black']}" })
hi(0, "Folded",       { bg = "${c['black']}", fg = "${c['bright-black']}" })
hi(0, "FoldColumn",   { fg = "${c['bright-black']}" })
hi(0, "Conceal",      { fg = "${c['bright-black']}" })
hi(0, "ColorColumn",  { bg = "${c['black']}" })
hi(0, "Pmenu",        { bg = "${c['black']}", fg = "${theme.foreground}" })
hi(0, "PmenuSel",     { bg = "${c['blue']}", fg = "${theme.background}" })
hi(0, "PmenuSbar",    { bg = "${c['black']}" })
hi(0, "PmenuThumb",   { bg = "${c['bright-black']}" })
hi(0, "TabLine",      { bg = "${c['black']}", fg = "${c['bright-black']}" })
hi(0, "TabLineSel",   { bg = "${theme.background}", fg = "${theme.foreground}", bold = true })
hi(0, "TabLineFill",  { bg = "${c['black']}" })
hi(0, "Title",        { fg = "${c['blue']}", bold = true })
hi(0, "MatchParen",   { fg = "${c['cyan']}", bold = true })
hi(0, "Question",     { fg = "${c['green']}" })
hi(0, "Directory",    { fg = "${c['blue']}" })
hi(0, "SpecialKey",   { fg = "${c['bright-black']}" })
hi(0, "NonText",      { fg = "${c['bright-black']}" })
hi(0, "Whitespace",   { fg = "${c['bright-black']}" })
hi(0, "EndOfBuffer",  { fg = "${c['bright-black']}" })
hi(0, "WildMenu",     { bg = "${c['blue']}", fg = "${theme.background}" })
hi(0, "DiffAdd",      { bg = "${theme.background}", fg = "${c['green']}" })
hi(0, "DiffChange",   { bg = "${theme.background}", fg = "${c['yellow']}" })
hi(0, "DiffDelete",   { bg = "${theme.background}", fg = "${c['red']}" })
hi(0, "DiffText",     { bg = "${c['yellow']}", fg = "${theme.background}" })
hi(0, "ErrorMsg",     { fg = "${c['red']}", bold = true })
hi(0, "WarningMsg",   { fg = "${c['yellow']}" })
hi(0, "ModeMsg",      { fg = "${theme.foreground}", bold = true })
hi(0, "MoreMsg",      { fg = "${c['green']}" })
hi(0, "SpellBad",     { undercurl = true, sp = "${c['red']}" })
hi(0, "SpellCap",     { undercurl = true, sp = "${c['yellow']}" })
hi(0, "SpellLocal",   { undercurl = true, sp = "${c['cyan']}" })
hi(0, "SpellRare",    { undercurl = true, sp = "${c['magenta']}" })

-- Syntax
hi(0, "Comment",      { fg = "${c['bright-black']}", italic = true })
hi(0, "String",       { fg = "${c['green']}" })
hi(0, "Character",    { fg = "${c['green']}" })
hi(0, "Number",       { fg = "${c['cyan']}" })
hi(0, "Float",        { fg = "${c['cyan']}" })
hi(0, "Boolean",      { fg = "${c['red']}" })
hi(0, "Keyword",      { fg = "${c['magenta']}", bold = true })
hi(0, "Statement",    { fg = "${c['magenta']}" })
hi(0, "Conditional",  { fg = "${c['magenta']}" })
hi(0, "Repeat",       { fg = "${c['magenta']}" })
hi(0, "Label",        { fg = "${c['blue']}" })
hi(0, "Operator",     { fg = "${c['magenta']}" })
hi(0, "Exception",    { fg = "${c['red']}" })
hi(0, "Function",     { fg = "${c['blue']}" })
hi(0, "Identifier",   { fg = "${c['cyan']}" })
hi(0, "Type",         { fg = "${c['yellow']}" })
hi(0, "StorageClass", { fg = "${c['magenta']}" })
hi(0, "Structure",    { fg = "${c['yellow']}" })
hi(0, "Typedef",      { fg = "${c['yellow']}" })
hi(0, "Constant",     { fg = "${c['red']}" })
hi(0, "PreProc",      { fg = "${c['cyan']}" })
hi(0, "Include",      { fg = "${c['magenta']}" })
hi(0, "Define",       { fg = "${c['magenta']}" })
hi(0, "Macro",        { fg = "${c['cyan']}" })
hi(0, "Special",      { fg = "${c['red']}" })
hi(0, "SpecialChar",  { fg = "${c['cyan']}" })
hi(0, "Delimiter",    { fg = "${theme.foreground}" })
hi(0, "Tag",          { fg = "${c['red']}" })
hi(0, "Debug",        { fg = "${c['red']}" })
hi(0, "Error",        { fg = "${c['red']}", bold = true })
hi(0, "Todo",         { bg = "${c['yellow']}", fg = "${theme.background}", bold = true })
hi(0, "Underlined",   { underline = true })

-- Treesitter
hi(0, "@comment",            { link = "Comment" })
hi(0, "@comment.todo",       { bg = "${c['yellow']}", fg = "${theme.background}", bold = true })
hi(0, "@string",             { link = "String" })
hi(0, "@string.regexp",      { fg = "${c['cyan']}" })
hi(0, "@string.escape",      { fg = "${c['cyan']}" })
hi(0, "@number",             { link = "Number" })
hi(0, "@float",              { link = "Float" })
hi(0, "@boolean",            { link = "Boolean" })
hi(0, "@keyword",            { link = "Keyword" })
hi(0, "@keyword.function",   { fg = "${c['magenta']}" })
hi(0, "@keyword.return",     { fg = "${c['magenta']}", bold = true })
hi(0, "@keyword.operator",   { fg = "${c['magenta']}" })
hi(0, "@function",           { link = "Function" })
hi(0, "@function.call",      { fg = "${c['blue']}" })
hi(0, "@function.macro",     { fg = "${c['cyan']}" })
hi(0, "@function.builtin",   { fg = "${c['cyan']}" })
hi(0, "@method",             { fg = "${c['blue']}" })
hi(0, "@method.call",        { fg = "${c['blue']}" })
hi(0, "@constructor",        { fg = "${c['blue']}" })
hi(0, "@type",               { link = "Type" })
hi(0, "@type.builtin",       { fg = "${c['yellow']}", italic = true })
hi(0, "@variable",           { fg = "${theme.foreground}" })
hi(0, "@variable.builtin",   { fg = "${c['red']}" })
hi(0, "@variable.parameter", { fg = "${theme.foreground}", italic = true })
hi(0, "@property",           { fg = "${theme.foreground}" })
hi(0, "@field",              { fg = "${theme.foreground}" })
hi(0, "@constant",           { link = "Constant" })
hi(0, "@constant.builtin",   { fg = "${c['red']}", italic = true })
hi(0, "@namespace",          { fg = "${c['cyan']}" })
hi(0, "@attribute",          { fg = "${c['blue']}" })
hi(0, "@operator",           { fg = "${c['magenta']}" })
hi(0, "@punctuation",        { fg = "${theme.foreground}" })
hi(0, "@tag",                { fg = "${c['red']}" })
hi(0, "@tag.attribute",      { fg = "${c['blue']}" })
hi(0, "@tag.delimiter",      { fg = "${c['bright-black']}" })
hi(0, "@text.uri",           { fg = "${c['cyan']}", underline = true })
hi(0, "@text.reference",     { fg = "${c['blue']}" })

-- LSP
hi(0, "DiagnosticError",          { fg = "${c['red']}" })
hi(0, "DiagnosticWarn",           { fg = "${c['yellow']}" })
hi(0, "DiagnosticInfo",           { fg = "${c['blue']}" })
hi(0, "DiagnosticHint",           { fg = "${c['cyan']}" })
hi(0, "DiagnosticUnderlineError", { undercurl = true, sp = "${c['red']}" })
hi(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = "${c['yellow']}" })
hi(0, "LspReferenceText",         { bg = "${theme['selection-background']}" })
hi(0, "LspReferenceRead",         { bg = "${theme['selection-background']}" })
hi(0, "LspReferenceWrite",        { bg = "${theme['selection-background']}", bold = true })
`;
  write(path.join(RICE_DIR, 'nvim', `${theme.slug}.lua`), content);
}

function genFish(theme) {
  const c = theme.colors;
  const sh = (hex) => hex.replace(/^#/, '');
  const sel = sh(theme['selection-background']);
  const content = `# Theme: ${theme.name}
# Source: ${theme.source}
# Usage: source this file or copy to ~/.config/fish/conf.d/${theme.slug}.fish
#   source ~/.config/fish/themes/${theme.slug}.fish

# Fish color variables (hex without #)
set -U fish_color_normal          ${sh(theme.foreground)}
set -U fish_color_command         ${sh(c['blue'])}
set -U fish_color_keyword         ${sh(c['magenta'])}
set -U fish_color_quote           ${sh(c['green'])}
set -U fish_color_redirection     ${sh(c['cyan'])}
set -U fish_color_end             ${sh(c['magenta'])}
set -U fish_color_error           ${sh(c['red'])}
set -U fish_color_param           ${sh(theme.foreground)}
set -U fish_color_valid_path      ${sh(c['cyan'])} --underline
set -U fish_color_comment         ${sh(c['bright-black'])}
set -U fish_color_selection       --background=${sel}
set -U fish_color_operator        ${sh(c['magenta'])}
set -U fish_color_escape          ${sh(c['yellow'])}
set -U fish_color_autosuggestion  ${sh(c['bright-black'])}
set -U fish_color_user            ${sh(c['green'])}
set -U fish_color_host            ${sh(c['blue'])}
set -U fish_color_host_remote     ${sh(c['cyan'])}
set -U fish_color_status          ${sh(c['red'])}
set -U fish_color_cancel          ${sh(c['red'])}
set -U fish_color_search_match    --background=${sh(c['yellow'])}

# Pager colors
set -U fish_pager_color_progress             ${sh(c['bright-black'])}
set -U fish_pager_color_prefix               ${sh(c['blue'])}
set -U fish_pager_color_completion           ${sh(theme.foreground)}
set -U fish_pager_color_description          ${sh(c['bright-black'])}
set -U fish_pager_color_selected_background  --background=${sel}
set -U fish_pager_color_selected_prefix      ${sh(c['blue'])} --bold
set -U fish_pager_color_selected_completion  ${sh(theme.foreground)} --bold
`;
  write(path.join(RICE_DIR, 'fish', `${theme.slug}.fish`), content);
}

// ── interactive index page ─────────────────────────────────────────────────────

function genIndex(themes) {
  const themeData = JSON.stringify(themes, null, 2);

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Terminal Themes — Interactive Preview</title>
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --ui-bg:      #111116;
  --ui-surface: #1a1a22;
  --ui-border:  rgba(255,255,255,0.07);
  --ui-text:    #aaa;
  --ui-muted:   #555;
}

body {
  background: var(--ui-bg);
  color: var(--ui-text);
  font-family: system-ui, -apple-system, sans-serif;
  font-size: 13px;
  height: 100dvh;
  display: flex;
  overflow: hidden;
}

/* ── sidebar ─────────────────────────── */
#sidebar {
  width: 220px;
  flex-shrink: 0;
  background: var(--ui-surface);
  border-right: 1px solid var(--ui-border);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
#sidebar-header {
  padding: 16px 14px 10px;
  font-size: 10px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--ui-muted);
  border-bottom: 1px solid var(--ui-border);
}
#theme-list {
  flex: 1;
  overflow-y: auto;
  padding: 6px 0;
}
.theme-item {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 7px 14px;
  cursor: pointer;
  transition: background 0.12s;
  border-left: 2px solid transparent;
}
.theme-item:hover { background: rgba(255,255,255,0.04); }
.theme-item.active {
  background: rgba(255,255,255,0.06);
  border-left-color: var(--t-blue);
}
.theme-dot-row { display: flex; gap: 3px; flex-shrink: 0; }
.theme-dot {
  width: 9px; height: 9px; border-radius: 50%;
}
.theme-name { font-size: 12px; font-weight: 500; color: #ccc; }

/* tabs */
#tabs {
  display: flex;
  border-bottom: 1px solid var(--ui-border);
  padding: 0 8px;
  gap: 2px;
}
.tab {
  padding: 8px 12px;
  font-size: 11px;
  letter-spacing: 0.04em;
  cursor: pointer;
  color: var(--ui-muted);
  border-bottom: 2px solid transparent;
  transition: color 0.12s;
}
.tab:hover { color: #ccc; }
.tab.active { color: #eee; border-bottom-color: var(--t-blue); }

/* ── main ────────────────────────────── */
#main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* panel container */
.panel { flex: 1; overflow: hidden; display: none; }
.panel.active { display: flex; flex-direction: column; }

/* ── desktop mockup ──────────────────── */
#desktop {
  flex: 1;
  position: relative;
  overflow: hidden;
  background: var(--t-bg);
  transition: background 0.25s;
}

/* waybar */
#waybar {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 30px;
  background: var(--t-bg);
  border-bottom: 1px solid var(--t-bblack);
  display: flex;
  align-items: center;
  padding: 0 14px;
  gap: 16px;
  font-size: 11px;
  font-family: 'JetBrains Mono', monospace;
  transition: background 0.25s, border-color 0.25s;
  z-index: 10;
}
.wb-ws { display: flex; gap: 6px; }
.ws-btn {
  width: 18px; height: 18px; border-radius: 4px;
  display: flex; align-items: center; justify-content: center;
  font-size: 10px; cursor: pointer; transition: background 0.15s;
}
.ws-active { background: var(--t-blue); color: var(--t-bg); }
.ws-used   { background: var(--t-bblack); color: var(--t-fg); }
.ws-empty  { color: var(--t-bblack); }
.wb-spacer { flex: 1; }
.wb-clock  { color: var(--t-green); font-weight: 600; }
.wb-info   { color: var(--t-cyan); }
.wb-battery{ color: var(--t-yellow); }

/* windows */
.win {
  position: absolute;
  border-radius: 9px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0,0,0,0.5), 0 2px 6px rgba(0,0,0,0.3);
  border: 1px solid rgba(255,255,255,0.08);
  transition: background 0.25s;
}
.win-bar {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 7px 10px;
  background: var(--t-bblack);
  transition: background 0.25s;
}
.win-btn { width: 10px; height: 10px; border-radius: 50%; }
.win-title {
  flex: 1; text-align: center;
  font-size: 10px; color: var(--t-fg); opacity: 0.5;
  font-family: system-ui, sans-serif;
  margin-right: 28px;
}
.win-body {
  background: var(--t-bg);
  font-family: 'JetBrains Mono', 'Cascadia Code', monospace;
  font-size: 11px;
  line-height: 1.55;
  padding: 10px 12px;
  transition: background 0.25s, color 0.25s;
  color: var(--t-fg);
  height: 100%;
}

/* terminal window */
#win-term {
  top: 50px; left: 24px;
  width: 420px; height: 290px;
}

/* editor window */
#win-editor {
  top: 50px; right: 24px;
  width: 360px; height: 290px;
}
.ed-gutter { color: var(--t-bblack); user-select: none; display: inline-block; width: 24px; text-align: right; margin-right: 12px; }
.ed-kw  { color: var(--t-magenta); }
.ed-fn  { color: var(--t-blue); }
.ed-str { color: var(--t-green); }
.ed-num { color: var(--t-yellow); }
.ed-cmt { color: var(--t-bblack); font-style: italic; }
.ed-var { color: var(--t-cyan); }
.ed-op  { color: var(--t-red); }
.ed-sel { background: var(--t-sel); display: inline; border-radius: 2px; }

/* rofi launcher */
#win-rofi {
  bottom: 40px;
  left: 50%;
  transform: translateX(-50%);
  width: 340px;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 16px 48px rgba(0,0,0,0.7);
  border: 1px solid var(--t-blue);
  z-index: 20;
}
#win-rofi .win-body { padding: 0; }
.rofi-search {
  display: flex;
  align-items: center;
  padding: 10px 14px;
  border-bottom: 1px solid var(--t-bblack);
  gap: 8px;
  color: var(--t-fg);
  font-family: system-ui, sans-serif;
  font-size: 13px;
}
.rofi-search span { color: var(--t-blue); }
.rofi-items { padding: 6px 0; }
.rofi-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 14px;
  font-family: system-ui, sans-serif;
  font-size: 12px;
  color: var(--t-fg);
  opacity: 0.8;
}
.rofi-item.sel {
  background: var(--t-blue);
  color: var(--t-bg);
  opacity: 1;
}
.rofi-icon { font-size: 14px; width: 18px; text-align: center; }

/* notification */
#notif {
  position: absolute;
  top: 40px; right: 14px;
  width: 280px;
  background: var(--t-bblack);
  border-radius: 8px;
  border: 1px solid var(--t-blue);
  padding: 10px 13px;
  font-family: system-ui, sans-serif;
  z-index: 30;
  box-shadow: 0 4px 16px rgba(0,0,0,0.5);
  transition: background 0.25s;
}
.notif-app { font-size: 10px; color: var(--t-bwhite); opacity: 0.5; margin-bottom: 3px; }
.notif-title { font-size: 12px; font-weight: 600; color: var(--t-fg); margin-bottom: 2px; }
.notif-body { font-size: 11px; color: var(--t-fg); opacity: 0.7; }

/* ── grid panel ──────────────────────── */
#panel-grid {
  overflow-y: auto;
  background: var(--ui-bg);
  padding: 20px;
}
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; }
.card {
  border-radius: 10px; overflow: hidden;
  box-shadow: 0 4px 18px rgba(0,0,0,0.5);
  border: 1px solid rgba(255,255,255,0.06);
  cursor: pointer; transition: transform 0.15s, box-shadow 0.15s;
}
.card:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(0,0,0,0.6); }
.card-bar {
  display: flex; align-items: center; gap: 6px;
  padding: 8px 10px;
}
.card-dots { display: flex; gap: 5px; }
.card-dot  { width: 10px; height: 10px; border-radius: 50%; }
.card-label {
  flex: 1; text-align: center; font-size: 11px; font-weight: 600;
  opacity: 0.5; margin-right: 30px;
}
.card-body { padding: 10px 13px 13px; font-family: 'JetBrains Mono', monospace; font-size: 11px; line-height: 1.5; }
.swatches { display: flex; flex-wrap: wrap; gap: 3px; margin-bottom: 10px; }
.sw { width: 20px; height: 20px; border-radius: 3px; }
.tl { display: flex; flex-direction: column; gap: 2px; }
.tl-line { display: flex; gap: 5px; align-items: baseline; }

/* ── configs panel ───────────────────── */
#panel-configs {
  overflow-y: auto;
  background: var(--ui-bg);
  padding: 20px;
}
.config-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 16px; }
.config-card {
  border-radius: 8px; overflow: hidden;
  border: 1px solid var(--ui-border);
  background: var(--ui-surface);
}
.config-card-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 9px 13px;
  border-bottom: 1px solid var(--ui-border);
  font-size: 11px; font-weight: 600; color: #ccc;
}
.config-badge {
  font-size: 9px; padding: 2px 7px; border-radius: 99px;
  background: rgba(255,255,255,0.07); color: var(--ui-muted);
  letter-spacing: 0.06em; text-transform: uppercase;
}
.config-body {
  padding: 10px 13px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 10px; line-height: 1.6;
  color: #888; max-height: 180px; overflow-y: auto;
  white-space: pre;
}

/* scrollbar */
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }
</style>
</head>
<body>

<div id="sidebar">
  <div id="sidebar-header">Terminal Themes</div>
  <div id="theme-list"></div>
</div>

<div id="main">
  <div id="tabs">
    <div class="tab active" data-panel="panel-desktop">Desktop</div>
    <div class="tab" data-panel="panel-grid">All Themes</div>
    <div class="tab" data-panel="panel-configs">Config Files</div>
  </div>

  <!-- desktop mockup -->
  <div id="panel-desktop" class="panel active">
    <div id="desktop">
      <div id="waybar">
        <div class="wb-ws">
          <div class="ws-btn ws-active">1</div>
          <div class="ws-btn ws-used">2</div>
          <div class="ws-btn ws-used">3</div>
          <div class="ws-btn ws-empty">4</div>
          <div class="ws-btn ws-empty">5</div>
        </div>
        <div class="wb-spacer"></div>
        <span class="wb-clock" id="wb-clock">14:23</span>
        <span class="wb-info">Sat 24 May</span>
        <span class="wb-battery">♥ 72%</span>
        <span class="wb-info" id="wb-theme-label">Dracula</span>
      </div>

      <!-- terminal window -->
      <div class="win" id="win-term">
        <div class="win-bar">
          <div class="win-btn" style="background:#ff5f57"></div>
          <div class="win-btn" style="background:#febc2e"></div>
          <div class="win-btn" style="background:#28c840"></div>
          <div class="win-title">bash — <span id="td-name">Dracula</span></div>
        </div>
        <div class="win-body" id="term-body"></div>
      </div>

      <!-- editor window -->
      <div class="win" id="win-editor">
        <div class="win-bar">
          <div class="win-btn" style="background:#ff5f57"></div>
          <div class="win-btn" style="background:#febc2e"></div>
          <div class="win-btn" style="background:#28c840"></div>
          <div class="win-title">nvim — config.lua</div>
        </div>
        <div class="win-body" id="editor-body"></div>
      </div>

      <!-- rofi launcher -->
      <div class="win" id="win-rofi">
        <div class="win-body">
          <div class="rofi-search"><span>⌕</span> <span style="opacity:0.4">run anything...</span></div>
          <div class="rofi-items">
            <div class="rofi-item sel"><span class="rofi-icon">⚙</span> System Settings</div>
            <div class="rofi-item"><span class="rofi-icon">🌐</span> Firefox</div>
            <div class="rofi-item"><span class="rofi-icon">📁</span> Files</div>
            <div class="rofi-item"><span class="rofi-icon">🎵</span> Spotify</div>
            <div class="rofi-item"><span class="rofi-icon">💻</span> Terminal</div>
          </div>
        </div>
      </div>

      <!-- notification -->
      <div id="notif">
        <div class="notif-app">dunst · now</div>
        <div class="notif-title">Build complete</div>
        <div class="notif-body">rice/screenshots regenerated — 10 themes</div>
      </div>
    </div>
  </div>

  <!-- all themes grid -->
  <div id="panel-grid" class="panel">
    <div class="grid" id="theme-grid"></div>
  </div>

  <!-- config files -->
  <div id="panel-configs" class="panel">
    <div class="config-grid" id="config-grid"></div>
  </div>
</div>

<script>
const THEMES = ${themeData};

let current = 0;

function hex(c) { return c.replace(/^#/, ''); }
function luma(c) {
  const r = parseInt(c.slice(1,3),16), g = parseInt(c.slice(3,5),16), b = parseInt(c.slice(5,7),16);
  return 0.299*r + 0.587*g + 0.114*b;
}

// Clock
function updateClock() {
  const d = new Date();
  document.getElementById('wb-clock').textContent =
    String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0');
}
updateClock();
setInterval(updateClock, 10000);

function applyTheme(idx) {
  current = idx;
  const t = THEMES[idx];
  const c = t.colors;
  const root = document.documentElement;
  const vars = {
    '--t-bg':      t.background,
    '--t-fg':      t.foreground,
    '--t-sel':     t['selection-background'],
    '--t-black':   c.black,   '--t-red':    c.red,   '--t-green':  c.green,
    '--t-yellow':  c.yellow,  '--t-blue':   c.blue,  '--t-magenta':c.magenta,
    '--t-cyan':    c.cyan,    '--t-white':  c.white,
    '--t-bblack':  c['bright-black'],   '--t-bred':    c['bright-red'],
    '--t-bgreen':  c['bright-green'],   '--t-byellow': c['bright-yellow'],
    '--t-bblue':   c['bright-blue'],    '--t-bmagenta':c['bright-magenta'],
    '--t-bcyan':   c['bright-cyan'],    '--t-bwhite':  c['bright-white'],
  };
  for (const [k,v] of Object.entries(vars)) root.style.setProperty(k, v);

  // highlight active sidebar item
  document.querySelectorAll('.theme-item').forEach((el,i) => el.classList.toggle('active', i===idx));

  // update labels
  document.getElementById('wb-theme-label').textContent = t.name;
  document.getElementById('td-name').textContent = t.name;

  // terminal content
  const termLines = [
    ['green',  '❯ ssh neo@' + t.slug + '.local'],
    ['cyan',   'Connected. Session started.'],
    ['yellow', '⚠ 3 unread messages in /var/log/'],
    ['green',  '❯ ls --color=auto ~/projects'],
    ['blue',   'dotfiles/  scripts/  rice/  wallpapers/'],
    ['green',  '❯ neofetch --config none'],
    ['magenta','    OS: Arch Linux btw   WM: Hyprland'],
    ['cyan',   '    Theme: ' + t.name],
    ['green',  '❯ _'],
  ];
  const tb = document.getElementById('term-body');
  tb.innerHTML = termLines.map(([col, txt]) =>
    \`<div style="color:var(--t-\${col})">\${txt}</div>\`
  ).join('');

  // editor content (fake Lua config)
  const ed = document.getElementById('editor-body');
  ed.innerHTML = \`<div><span class="ed-gutter">1</span><span class="ed-cmt">-- Neovim config · \${t.name}</span></div>
<div><span class="ed-gutter">2</span><span class="ed-kw">local</span> <span class="ed-var">colors</span> <span class="ed-op">=</span> <span class="ed-fn">require</span>(<span class="ed-str">"rice.colors"</span>)</div>
<div><span class="ed-gutter">3</span></div>
<div><span class="ed-gutter">4</span><span class="ed-kw">vim</span>.cmd(<span class="ed-str">"colorscheme \${t.slug}"</span>)</div>
<div><span class="ed-gutter">5</span><span class="ed-kw">vim</span>.opt.background <span class="ed-op">=</span> <span class="ed-str">"\${luma(t.background) > 128 ? 'light' : 'dark'}"</span></div>
<div><span class="ed-gutter">6</span></div>
<div><span class="ed-gutter">7</span><span class="ed-kw">local</span> <span class="ed-var">hl</span> <span class="ed-op">=</span> <span class="ed-var">vim</span>.api.nvim_set_hl</div>
<div><span class="ed-gutter">8</span><span class="ed-fn">hl</span>(<span class="ed-num">0</span>, <span class="ed-str">"Normal"</span>, { bg<span class="ed-op">=</span><span class="ed-str">"\${t.background}"</span>, fg<span class="ed-op">=</span><span class="ed-str">"\${t.foreground}"</span> })</div>
<div><span class="ed-gutter">9</span><span class="ed-fn">hl</span>(<span class="ed-num">0</span>, <span class="ed-str">"Comment"</span>, { fg<span class="ed-op">=</span><span class="ed-str">"\${c['bright-black']}"</span>, italic<span class="ed-op">=</span><span class="ed-kw">true</span> })</div>
<div><span class="ed-gutter">10</span><span class="ed-fn">hl</span>(<span class="ed-num">0</span>, <span class="ed-str">"String"</span>, { fg<span class="ed-op">=</span><span class="ed-str">"\${c.green}"</span> })</div>
<div><span class="ed-gutter">11</span><span class="ed-fn">hl</span>(<span class="ed-num">0</span>, <span class="ed-str">"Keyword"</span>, { fg<span class="ed-op">=</span><span class="ed-str">"\${c.magenta}"</span>, bold<span class="ed-op">=</span><span class="ed-kw">true</span> })</div>
<div><span class="ed-gutter">12</span><span class="ed-fn">hl</span>(<span class="ed-num">0</span>, <span class="ed-str">"Function"</span>, { fg<span class="ed-op">=</span><span class="ed-str">"\${c.blue}"</span> })</div>\`;
}

// Build sidebar
const list = document.getElementById('theme-list');
THEMES.forEach((t, i) => {
  const c = t.colors;
  const el = document.createElement('div');
  el.className = 'theme-item';
  el.innerHTML = \`
    <div class="theme-dot-row">
      <div class="theme-dot" style="background:\${c.red}"></div>
      <div class="theme-dot" style="background:\${c.green}"></div>
      <div class="theme-dot" style="background:\${c.blue}"></div>
    </div>
    <span class="theme-name">\${t.name}</span>
  \`;
  el.addEventListener('click', () => applyTheme(i));
  list.appendChild(el);
});

// Build all-themes grid
const grid = document.getElementById('theme-grid');
THEMES.forEach((t, i) => {
  const c = t.colors;
  const allColors = [c.black,c.red,c.green,c.yellow,c.blue,c.magenta,c.cyan,c.white,
                     c['bright-black'],c['bright-red'],c['bright-green'],c['bright-yellow'],
                     c['bright-blue'],c['bright-magenta'],c['bright-cyan'],c['bright-white']];
  const card = document.createElement('div');
  card.className = 'card';
  card.style.background = t.background;
  card.innerHTML = \`
    <div class="card-bar" style="background:\${c['bright-black']}">
      <div class="card-dots">
        <div class="card-dot" style="background:#ff5f57"></div>
        <div class="card-dot" style="background:#febc2e"></div>
        <div class="card-dot" style="background:#28c840"></div>
      </div>
      <div class="card-label" style="color:\${t.foreground}">\${t.name}</div>
    </div>
    <div class="card-body" style="color:\${t.foreground}">
      <div class="swatches">\${allColors.map(col=>\`<div class="sw" style="background:\${col}" title="\${col}"></div>\`).join('')}</div>
      <div class="tl">
        <div class="tl-line"><span style="color:\${c.green}">❯</span> <span>git log --oneline -2</span></div>
        <div class="tl-line" style="opacity:0.6"><span style="color:\${c.yellow}">7a1f3b2</span> add \${t.slug} rice configs</div>
        <div class="tl-line" style="opacity:0.6"><span style="color:\${c.yellow}">3c8e5d1</span> update hyprland theme</div>
        <div class="tl-line" style="margin-top:4px"><span style="color:\${c.green}">❯</span> <span>echo \$THEME</span></div>
        <div class="tl-line" style="opacity:0.6; color:\${c.cyan}">\${t.name}</div>
      </div>
    </div>
  \`;
  card.addEventListener('click', () => {
    applyTheme(i);
    document.querySelector('[data-panel="panel-desktop"]').click();
  });
  grid.appendChild(card);
});

// Build config panel
const configGrid = document.getElementById('config-grid');
function makeConfigCard(title, ext, contentFn) {
  const card = document.createElement('div');
  card.className = 'config-card';
  card.innerHTML = \`
    <div class="config-card-head">
      <span id="cc-\${ext}-title">\${title}</span>
      <span class="config-badge">\${ext}</span>
    </div>
    <div class="config-body" id="cc-\${ext}-body"></div>
  \`;
  configGrid.appendChild(card);
  return contentFn;
}

const configRenderers = [];
configRenderers.push(makeConfigCard('Alacritty', 'toml', (t) => {
  const c = t.colors;
  return \`[colors.primary]
background = "\${t.background}"
foreground = "\${t.foreground}"

[colors.normal]
black   = "\${c.black}"
red     = "\${c.red}"
green   = "\${c.green}"
yellow  = "\${c.yellow}"
blue    = "\${c.blue}"
magenta = "\${c.magenta}"
cyan    = "\${c.cyan}"
white   = "\${c.white}"\`;
}));
configRenderers.push(makeConfigCard('Kitty', 'conf', (t) => {
  const c = t.colors;
  return \`background  \${t.background}
foreground  \${t.foreground}
cursor      \${t.cursor}

color0  \${c.black}
color1  \${c.red}
color2  \${c.green}
color3  \${c.yellow}
color4  \${c.blue}
color5  \${c.magenta}
color6  \${c.cyan}
color7  \${c.white}\`;
}));
configRenderers.push(makeConfigCard('Waybar CSS', 'css', (t) => {
  const c = t.colors;
  return \`:root {
  --background: \${t.background};
  --foreground: \${t.foreground};
  --red:        \${c.red};
  --green:      \${c.green};
  --yellow:     \${c.yellow};
  --blue:       \${c.blue};
  --magenta:    \${c.magenta};
  --cyan:       \${c.cyan};
}\`;
}));
configRenderers.push(makeConfigCard('Rofi', 'rasi', (t) => {
  const c = t.colors;
  return \`* {
  background-color:           \${t.background};
  foreground:                 \${t.foreground};
  selected-normal-background: \${c.blue};
  selected-normal-foreground: \${t.background};
  border-color:               \${c['bright-black']};
}\`;
}));
configRenderers.push(makeConfigCard('Hyprland', 'conf', (t) => {
  const c = t.colors;
  return \`\$color_background = rgb(\${hex(t.background)})
\$color_foreground = rgb(\${hex(t.foreground)})
\$color_red        = rgb(\${hex(c.red)})
\$color_green      = rgb(\${hex(c.green)})
\$color_blue       = rgb(\${hex(c.blue)})
\$color_magenta    = rgb(\${hex(c.magenta)})
\$color_cyan       = rgb(\${hex(c.cyan)})\`;
}));
configRenderers.push(makeConfigCard('WezTerm', 'lua', (t) => {
  const c = t.colors;
  return \`return {
  colors = {
    background    = "\${t.background}",
    foreground    = "\${t.foreground}",
    ansi = {
      "\${c.black}", "\${c.red}", "\${c.green}", "\${c.yellow}",
      "\${c.blue}",  "\${c.magenta}", "\${c.cyan}", "\${c.white}",
    },
  },
}\`;
}));

function updateConfigPanel(t) {
  const exts = ['toml','conf','css','rasi','conf','lua'];
  configRenderers.forEach((fn, i) => {
    const el = document.getElementById('cc-' + exts[i] + '-body');
    if (el) el.textContent = fn(t);
  });
}

// Watch theme changes to update configs
const origApply = applyTheme;
window.applyTheme = function(idx) {
  origApply(idx);
  updateConfigPanel(THEMES[idx]);
};

// Tabs
document.querySelectorAll('.tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
    tab.classList.add('active');
    document.getElementById(tab.dataset.panel).classList.add('active');
  });
});

// Init
applyTheme(0);
updateConfigPanel(THEMES[0]);
</script>
</body>
</html>
`;
  write(path.join(RICE_DIR, 'index.html'), html);
}

// ── main ───────────────────────────────────────────────────────────────────────

console.log(`Generating rice configs for ${themes.length} themes...\n`);

for (const theme of themes) {
  console.log(`[${theme.slug}]`);
  genAlacritty(theme);
  genKitty(theme);
  genHyprland(theme);
  genWaybar(theme);
  genRofi(theme);
  genDunst(theme);
  genWezterm(theme);
  genTmux(theme);
  genGhostty(theme);
  genVSCode(theme);
  genWindowsTerminal(theme);
  genHelix(theme);
  genFoot(theme);
  genNvim(theme);
  genFish(theme);
}

genIndex(themes);
const CONFIG_TYPES = 15;
console.log(`\nDone. Generated ${themes.length * CONFIG_TYPES + 1} files (configs + interactive index).`);
