# Window Manager Configs

A structured JSON reference for common Wayland and X11 window managers used on Linux. Covers tiling, floating, and dynamic WMs with their configuration formats, paths, reload commands, and feature sets.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Hyprland",
  "slug": "hyprland",
  "type": "tiling",
  "protocol": "Wayland",
  "config-format": "custom",
  "config-path": "~/.config/hypr/hyprland.conf",
  "reload-cmd": "hyprctl reload",
  "description": "A dynamic tiling Wayland compositor...",
  "features": ["animations", "rounded-corners", "blur"],
  "tags": ["wayland", "tiling", "popular"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable WM name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `type` | string | Window management style (see below) |
| `protocol` | string | Display protocol: `Wayland` or `X11` |
| `config-format` | string | Config language or format used |
| `config-path` | string | Default config file path |
| `reload-cmd` | string | Command to reload config without restart |
| `description` | string | Overview of the WM and its target use case |
| `features` | string[] | Notable capabilities |
| `tags` | string[] | Keywords for filtering and discovery |

### Types

| Type | Description |
|---|---|
| `tiling` | Windows are arranged automatically in a non-overlapping grid |
| `floating` | Windows stack/overlap like a traditional desktop |
| `dynamic` | Supports multiple layout algorithms switchable at runtime |
| `compositor` | Handles rendering in addition to window management (Wayland-native) |

## WMs included

| Slug | Name | Protocol | Type | Config Format |
|---|---|---|---|---|
| `hyprland` | Hyprland | Wayland | tiling | custom |
| `sway` | Sway | Wayland | tiling | i3-compatible |
| `i3` | i3 | X11 | tiling | custom |
| `bspwm` | bspwm | X11 | tiling | shell-script |
| `openbox` | Openbox | X11 | floating | xml |
| `qtile` | Qtile | X11 | dynamic | python |
| `awesome` | AwesomeWM | X11 | dynamic | lua |
| `xmonad` | XMonad | X11 | tiling | haskell |
| `river` | River | Wayland | tiling | shell-script |
| `niri` | Niri | Wayland | tiling | kdl |

## Examples

### Shell — list all Wayland compositors

```bash
jq '[.[] | select(.protocol == "Wayland") | {slug, name, type}]' wm-configs.json
```

### Shell — get the reload command for a WM

```bash
jq -r '.[] | select(.slug == "hyprland") | .["reload-cmd"]' wm-configs.json
```

### Shell — find WMs with a specific feature

```bash
jq '[.[] | select(.features | contains(["animations"]))]' wm-configs.json
```

### JavaScript — look up config path by slug

```javascript
const wms = await fetch('wm-configs.json').then(r => r.json());
const bySlug = Object.fromEntries(wms.map(w => [w.slug, w]));

const sway = bySlug['sway'];
console.log(sway['config-path']);
// "~/.config/sway/config"
```

### JavaScript — filter by protocol

```javascript
const wms = await fetch('wm-configs.json').then(r => r.json());
const wayland = wms.filter(w => w.protocol === 'Wayland');
console.log(wayland.map(w => w.name));
// ["Hyprland", "Sway", "River", "Niri"]
```

### PHP — display WMs grouped by protocol

```php
$wms = json_decode(file_get_contents('wm-configs.json'), true);
$byProtocol = [];
foreach ($wms as $wm) {
    $byProtocol[$wm['protocol']][] = $wm;
}
foreach ($byProtocol as $proto => $group) {
    echo "$proto:\n";
    foreach ($group as $w) {
        echo "  {$w['name']} ({$w['type']}): {$w['config-path']}\n";
    }
}
```
