# Rice Configs

Per-theme configuration files for popular Arch Linux ricing tools, generated from the terminal color themes in [`colors/terminal/themes.json`](../colors/terminal/themes.json).

## Supported Tools

| Tool       | Config format | Install path                     |
|------------|---------------|----------------------------------|
| Alacritty  | `.toml`       | `~/.config/alacritty/colors.toml`|
| Kitty      | `.conf`       | `~/.config/kitty/colors.conf`    |
| Hyprland   | `.conf`       | `~/.config/hypr/colors.conf`     |
| Waybar     | `.css`        | `~/.config/waybar/colors.css`    |
| Rofi       | `.rasi`       | `~/.config/rofi/colors.rasi`     |
| Dunst      | `.conf`       | `~/.config/dunst/colors.conf`    |
| WezTerm    | `.lua`        | `~/.config/wezterm/colors.lua`   |

## Available Themes

| Slug              | Name              | Style      |
|-------------------|-------------------|------------|
| `dracula`         | Dracula           | Dark       |
| `nord`            | Nord              | Dark       |
| `solarized-dark`  | Solarized Dark    | Dark       |
| `solarized-light` | Solarized Light   | Light      |
| `monokai`         | Monokai           | Dark       |
| `gruvbox-dark`    | Gruvbox Dark      | Dark       |
| `catppuccin-mocha`| Catppuccin Mocha  | Dark       |
| `tokyo-night`     | Tokyo Night       | Dark       |
| `one-dark`        | One Dark          | Dark       |
| `material-dark`   | Material Dark     | Dark       |

## Quick Install via fetch.sh

The easiest way to apply a theme is with the one-liner fetch script:

```bash
bash <(curl -s https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice/fetch.sh) dracula
```

Replace `dracula` with any slug from the table above. The script will:

1. Download all config files for the chosen theme
2. Copy them to the right paths under `~/.config/`
3. Add import/source/include lines to your existing config files where possible
4. Print a summary and any manual steps needed

To list available themes without installing anything:

```bash
bash <(curl -s https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice/fetch.sh)
```

## Manual Application

### Alacritty

Copy the theme file and tell Alacritty to import it:

```bash
cp rice/alacritty/dracula.toml ~/.config/alacritty/colors.toml
```

Add to `~/.config/alacritty/alacritty.toml`:

```toml
[general]
import = ["~/.config/alacritty/colors.toml"]
```

### Kitty

```bash
cp rice/kitty/dracula.conf ~/.config/kitty/colors.conf
```

Add to `~/.config/kitty/kitty.conf`:

```
include colors.conf
```

Reload with `ctrl+shift+F5` or restart Kitty.

### Hyprland

```bash
cp rice/hyprland/dracula.conf ~/.config/hypr/colors.conf
```

Add to `~/.config/hypr/hyprland.conf`:

```
source = ~/.config/hypr/colors.conf
```

Reload Hyprland: `hyprctl reload`

### Waybar

```bash
cp rice/waybar/dracula.css ~/.config/waybar/colors.css
```

Add to the top of `~/.config/waybar/style.css`:

```css
@import url("colors.css");
```

Then use CSS variables like `var(--background)`, `var(--blue)`, etc. in your Waybar style.

### Rofi

```bash
cp rice/rofi/dracula.rasi ~/.config/rofi/colors.rasi
```

Add to `~/.config/rofi/config.rasi`:

```
@import "colors.rasi"
```

### Dunst

```bash
cp rice/dunst/dracula.conf ~/.config/dunst/colors.conf
```

Copy the urgency blocks from `colors.conf` into your `~/.config/dunst/dunstrc`, replacing existing `[urgency_low]`, `[urgency_normal]`, and `[urgency_critical]` sections.

Restart dunst: `killall dunst && dunst &`

### WezTerm

```bash
cp rice/wezterm/dracula.lua ~/.config/wezterm/colors.lua
```

In `~/.config/wezterm/wezterm.lua`:

```lua
local colors = require("colors")
config.colors = colors.colors
```

## Regenerating Configs

Config files are generated from `colors/terminal/themes.json` by the generator script:

```bash
node rice/generate.js
```

This overwrites all `rice/<tool>/<slug>.*` files. Do not edit generated files directly — edit `generate.js` or the JSON source instead.

## Preview

See [`preview.html`](preview.html) for an interactive browser preview showing simulated neofetch-style terminal output for all themes side-by-side.

The HTML file is self-contained (xterm.js is embedded inline) and can be opened locally without a web server.
