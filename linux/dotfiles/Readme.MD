# Common Dotfile Paths

A structured JSON reference for standard XDG and dotfile paths used by common Arch Linux tools. Covers config, data, and cache locations along with relevant environment variable overrides.

## JSON

### Structure as of 24.05.2026

```json
{
  "app": "Neovim",
  "slug": "nvim",
  "config-path": "~/.config/nvim/init.lua",
  "data-path": "~/.local/share/nvim",
  "cache-path": "~/.cache/nvim",
  "env-var": "NVIM_APPNAME",
  "notes": "NVIM_APPNAME allows multiple isolated configs."
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `app` | string | Human-readable application name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `config-path` | string | Primary config file or directory path |
| `data-path` | string \| null | XDG data directory (`~/.local/share/…`) or null if unused |
| `cache-path` | string \| null | XDG cache directory (`~/.cache/…`) or null if unused |
| `env-var` | string \| null | Environment variable that overrides the default path, or null |
| `notes` | string | Additional context, caveats, or related paths |

## Apps included

| Slug | App | Config Path |
|---|---|---|
| `alacritty` | Alacritty | `~/.config/alacritty/alacritty.toml` |
| `kitty` | Kitty | `~/.config/kitty/kitty.conf` |
| `hyprland` | Hyprland | `~/.config/hypr/hyprland.conf` |
| `waybar` | Waybar | `~/.config/waybar/config` |
| `rofi` | Rofi | `~/.config/rofi/config.rasi` |
| `dunst` | Dunst | `~/.config/dunst/dunstrc` |
| `wezterm` | WezTerm | `~/.config/wezterm/wezterm.lua` |
| `zsh` | Zsh | `~/.zshrc` |
| `bash` | Bash | `~/.bashrc` |
| `fish` | Fish | `~/.config/fish/config.fish` |
| `nvim` | Neovim | `~/.config/nvim/init.lua` |
| `helix` | Helix | `~/.config/helix/config.toml` |
| `gitconfig` | Git | `~/.gitconfig` |
| `ssh` | SSH | `~/.ssh/config` |
| `gpg` | GPG | `~/.gnupg/gpg.conf` |
| `gtk3` | GTK 3 | `~/.config/gtk-3.0/settings.ini` |
| `gtk4` | GTK 4 | `~/.config/gtk-4.0/settings.ini` |
| `fontconfig` | Fontconfig | `~/.config/fontconfig/fonts.conf` |
| `pipewire` | PipeWire | `~/.config/pipewire/pipewire.conf` |
| `systemd-user` | systemd (user) | `~/.config/systemd/user` |

## Examples

### Shell — look up config path for an app

```bash
jq -r '.[] | select(.slug == "nvim") | .["config-path"]' common-paths.json
```

### Shell — list all apps with an env var override

```bash
jq '[.[] | select(.["env-var"] != null) | {slug, "env-var"}]' common-paths.json
```

### Shell — list apps that have a dedicated cache directory

```bash
jq '[.[] | select(.["cache-path"] != null) | .slug]' common-paths.json
```

### JavaScript — look up config path by slug

```javascript
const paths = await fetch('common-paths.json').then(r => r.json());
const bySlug = Object.fromEntries(paths.map(p => [p.slug, p]));

const nvim = bySlug['nvim'];
console.log(nvim['config-path']);
// "~/.config/nvim/init.lua"

// Replace ~ with home directory
const home = process.env.HOME;
const full = nvim['config-path'].replace('~', home);
```

### JavaScript — build a quick-reference map of config paths

```javascript
const paths = await fetch('common-paths.json').then(r => r.json());
const configMap = Object.fromEntries(
  paths.map(p => [p.slug, p['config-path']])
);
console.log(configMap);
// { alacritty: "~/.config/alacritty/alacritty.toml", ... }
```

### PHP — display all config paths

```php
$paths = json_decode(file_get_contents('common-paths.json'), true);
foreach ($paths as $p) {
    $envNote = $p['env-var'] ? " (override: \${$p['env-var']})" : '';
    echo "{$p['app']}: {$p['config-path']}$envNote\n";
}
```
