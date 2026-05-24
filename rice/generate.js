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
}

console.log(`\nDone. Generated ${themes.length * 7} config files.`);
