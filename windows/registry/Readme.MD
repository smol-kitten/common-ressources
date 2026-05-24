# Common Windows Registry Tweaks

A structured JSON reference for useful Windows registry tweaks. Covers UI customization, privacy settings, performance optimizations, Explorer behavior, and taskbar configuration.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Enable Dark Mode (Apps)",
  "slug": "dark-mode-apps",
  "key": "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
  "value-name": "AppsUseLightTheme",
  "value-type": "REG_DWORD",
  "value-data": "0",
  "default-value": "1",
  "description": "Forces all Windows apps to use dark theme.",
  "category": "ui",
  "reversible": true,
  "requires-restart": false,
  "tags": ["dark-mode", "theme", "appearance"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable tweak name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `key` | string | Full registry key path |
| `value-name` | string | Registry value name (empty string for default value) |
| `value-type` | string | Registry data type (see below) |
| `value-data` | string | Value to write for the tweak to take effect |
| `default-value` | string \| null | Original/default value, or null if key doesn't exist by default |
| `description` | string | What this tweak does and any caveats |
| `category` | string | Functional category (see below) |
| `reversible` | boolean | Whether the tweak can be safely undone |
| `requires-restart` | boolean | Whether a system restart is needed to apply |
| `tags` | string[] | Keywords for filtering and discovery |

### Value Types

| Type | Description |
|---|---|
| `REG_DWORD` | 32-bit unsigned integer |
| `REG_SZ` | Null-terminated string |
| `REG_BINARY` | Raw binary data |
| `REG_QWORD` | 64-bit unsigned integer |

### Categories

| Category | Description |
|---|---|
| `performance` | Tweaks that improve perceived or actual system performance |
| `privacy` | Tweaks that reduce data collection or disable telemetry |
| `ui` | Visual and interface customization |
| `explorer` | Windows Explorer and file management behavior |
| `taskbar` | Taskbar layout and feature settings |
| `power` | Power management and startup behavior |

## Tweaks included

| Slug | Name | Category | Requires Restart |
|---|---|---|---|
| `dark-mode-apps` | Enable Dark Mode (Apps) | ui | no |
| `dark-mode-system` | Enable Dark Mode (System) | ui | no |
| `disable-telemetry` | Disable Telemetry | privacy | yes |
| `disable-activity-history` | Disable Activity History | privacy | no |
| `classic-context-menu` | Classic Context Menu (Win11) | explorer | yes |
| `show-file-extensions` | Show File Extensions | explorer | no |
| `show-hidden-files` | Show Hidden Files | explorer | no |
| `disable-cortana` | Disable Cortana | privacy | yes |
| `disable-lockscreen-ads` | Disable Lock Screen Ads | ui | no |
| `disable-start-suggestions` | Disable Start Menu Suggestions | ui | no |
| `taskbar-align-left` | Taskbar Alignment Left (Win11) | taskbar | no |
| `disable-taskbar-search` | Disable Taskbar Search Box | taskbar | no |
| `disable-widgets` | Disable Windows Widgets | taskbar | no |
| `disable-fast-startup` | Disable Fast Startup | power | yes |
| `menu-show-delay` | Instant Menu Show Delay | performance | no |
| `disable-animations` | Disable Animations | performance | no |
| `power-plan-high-performance` | Set High Performance Power Plan | power | no |
| `disable-print-spooler` | Disable Print Spooler | privacy | yes |
| `disable-game-bar` | Disable Xbox Game Bar | performance | no |
| `enable-long-paths` | Enable Long File Paths | explorer | yes |

## Usage

Apply a tweak from PowerShell (run as Administrator):

```powershell
# REG_DWORD example
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
  -Name "AppsUseLightTheme" -Value 0 -Type DWord

# REG_SZ example
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
  -Name "MenuShowDelay" -Value "0" -Type String
```

## Examples

### Shell (PowerShell) — apply a tweak from the JSON

```powershell
$tweaks = Get-Content tweaks.json | ConvertFrom-Json
$tweak = $tweaks | Where-Object slug -eq 'show-file-extensions'
Set-ItemProperty -Path "Registry::$($tweak.key)" -Name $tweak.'value-name' -Value $tweak.'value-data'
```

### Shell — list all tweaks that require a restart

```bash
jq '[.[] | select(.["requires-restart"] == true) | {slug, name, category}]' common-tweaks.json
```

### Shell — filter tweaks by category

```bash
jq '[.[] | select(.category == "privacy") | {slug, name}]' common-tweaks.json
```

### JavaScript — build a lookup map

```javascript
const tweaks = await fetch('common-tweaks.json').then(r => r.json());
const bySlug = Object.fromEntries(tweaks.map(t => [t.slug, t]));

const tweak = bySlug['dark-mode-apps'];
console.log(`${tweak.key}\\${tweak['value-name']} = ${tweak['value-data']}`);
```

### PHP — list tweaks by category

```php
$tweaks = json_decode(file_get_contents('common-tweaks.json'), true);
$byCategory = [];
foreach ($tweaks as $t) {
    $byCategory[$t['category']][] = $t;
}
foreach ($byCategory as $cat => $group) {
    echo "$cat:\n";
    foreach ($group as $t) {
        $restart = $t['requires-restart'] ? ' (restart required)' : '';
        echo "  {$t['name']}$restart\n";
    }
}
```
