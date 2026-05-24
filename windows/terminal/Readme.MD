# Windows Terminal Profiles

A structured JSON reference for Windows Terminal profile templates. Covers PowerShell, CMD, WSL distros, Git Bash, Cygwin, and development shells. Each profile is ready to paste into your `settings.json`.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "PowerShell 7",
  "slug": "powershell-7",
  "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
  "commandline": "pwsh.exe -NoLogo",
  "icon": "ms-appx:///ProfileIcons/...",
  "colorScheme": "Campbell Powershell",
  "fontFace": "CaskaydiaCove Nerd Font",
  "fontSize": 12,
  "cursorShape": "bar",
  "backgroundImage": null,
  "backgroundImageOpacity": 1.0,
  "description": "PowerShell 7 cross-platform shell.",
  "tags": ["powershell", "pwsh"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Display name shown in the tab dropdown |
| `slug` | string | Lowercase hyphen-separated identifier |
| `guid` | string | Unique GUID for the profile (use as-is or generate a new one) |
| `commandline` | string | The executable and arguments to launch |
| `icon` | string \| null | Path or URL to the profile icon |
| `colorScheme` | string | Name of the Windows Terminal color scheme to apply |
| `fontFace` | string | Font family name |
| `fontSize` | number | Font size in points |
| `cursorShape` | string | Cursor style: `bar`, `block`, `underscore`, `filledBox`, `emptyBox`, `vintage` |
| `backgroundImage` | string \| null | Path to a background image, or null |
| `backgroundImageOpacity` | number | Opacity of background image (0.0–1.0) |
| `description` | string | What this profile launches and its use case |
| `tags` | string[] | Keywords for filtering and discovery |

## Profiles included

| Slug | Name | Shell Type |
|---|---|---|
| `powershell-7` | PowerShell 7 | pwsh |
| `cmd` | Command Prompt | cmd.exe |
| `wsl-ubuntu-2204` | WSL Ubuntu 22.04 | bash (WSL) |
| `wsl-ubuntu-2404` | WSL Ubuntu 24.04 | bash (WSL) |
| `wsl-arch` | WSL Arch Linux | bash (WSL) |
| `git-bash` | Git Bash | bash (MSYS2) |
| `cygwin` | Cygwin | bash (Cygwin) |
| `azure-cloud-shell` | Azure Cloud Shell | az CLI |
| `developer-powershell-vs` | Developer PowerShell for VS | PowerShell + VS tools |
| `python-repl` | Python REPL | python.exe |
| `nodejs-repl` | Node.js REPL | node.exe |

## Usage

Paste a profile object into the `"profiles"` → `"list"` array in your Windows Terminal `settings.json`:

```json
{
  "profiles": {
    "list": [
      {
        "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
        "name": "PowerShell 7",
        "commandline": "pwsh.exe -NoLogo",
        "colorScheme": "Campbell Powershell"
      }
    ]
  }
}
```

Settings file location: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

## Examples

### Shell (PowerShell) — look up commandline for a profile

```powershell
$profiles = Get-Content profiles.json | ConvertFrom-Json
$profile = $profiles | Where-Object slug -eq 'powershell-7'
Write-Host $profile.commandline
```

### Shell — list all WSL profiles

```bash
jq '[.[] | select(.tags | contains(["wsl"])) | {slug, name, commandline}]' profiles.json
```

### JavaScript — look up a profile by slug

```javascript
const profiles = await fetch('profiles.json').then(r => r.json());
const bySlug = Object.fromEntries(profiles.map(p => [p.slug, p]));

const profile = bySlug['git-bash'];
console.log(profile.commandline);
// "C:\\Program Files\\Git\\bin\\bash.exe -i -l"
```

### JavaScript — generate settings.json list section

```javascript
const profiles = await fetch('profiles.json').then(r => r.json());
const settingsList = profiles.map(p => ({
  guid: p.guid,
  name: p.name,
  commandline: p.commandline,
  colorScheme: p.colorScheme,
  fontFace: p.fontFace,
  fontSize: p.fontSize
}));
console.log(JSON.stringify({ profiles: { list: settingsList } }, null, 2));
```

### PHP — display all profiles and their commandlines

```php
$profiles = json_decode(file_get_contents('profiles.json'), true);
foreach ($profiles as $p) {
    echo "{$p['name']}: {$p['commandline']}\n";
}
```
