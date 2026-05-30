# Winget Packages

A curated JSON list of winget packages recommended for fresh Windows installs. Covers browsers, terminals, editors, development tools, media players, utilities, communication apps, security tools, and fonts.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Visual Studio Code",
  "slug": "vscode",
  "id": "Microsoft.VisualStudioCode",
  "version-latest": "1.90.0",
  "category": "editor",
  "description": "Lightweight, extensible code editor from Microsoft.",
  "homepage": "https://code.visualstudio.com",
  "free": true,
  "open-source": true,
  "tags": ["editor", "ide", "microsoft"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable package name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `id` | string | Winget package ID (use with `winget install`) |
| `version-latest` | string | Latest known version at time of writing |
| `category` | string | Functional category (see below) |
| `description` | string | What the package does |
| `homepage` | string | Official website |
| `free` | boolean | Whether the package is free to use |
| `open-source` | boolean | Whether the package is open source |
| `tags` | string[] | Keywords for filtering and discovery |

### Categories

| Category | Description |
|---|---|
| `browser` | Web browsers |
| `terminal` | Terminal emulators |
| `editor` | Text and code editors |
| `dev-tool` | Developer tools, runtimes, and CLIs |
| `media` | Media players and recording tools |
| `utility` | General-purpose system utilities |
| `communication` | Chat, messaging, and VOIP apps |
| `security` | Password managers and anti-malware |
| `font` | Developer-focused fonts |

## Packages included

| Slug | Name | Category | Open Source |
|---|---|---|---|
| `brave` | Brave Browser | browser | yes |
| `firefox` | Mozilla Firefox | browser | yes |
| `chrome` | Google Chrome | browser | no |
| `windows-terminal` | Windows Terminal | terminal | yes |
| `wezterm` | WezTerm | terminal | yes |
| `alacritty` | Alacritty | terminal | yes |
| `vscode` | Visual Studio Code | editor | yes |
| `neovim` | Neovim | editor | yes |
| `notepadpp` | Notepad++ | editor | yes |
| `git` | Git | dev-tool | yes |
| `powershell` | PowerShell 7 | dev-tool | yes |
| `python3` | Python 3 | dev-tool | yes |
| `nodejs-lts` | Node.js (LTS) | dev-tool | yes |
| `gh` | GitHub CLI | dev-tool | yes |
| `docker-desktop` | Docker Desktop | dev-tool | no |
| `7zip` | 7-Zip | utility | yes |
| `powertoys` | PowerToys | utility | yes |
| `everything` | Everything | utility | no |
| `flow-launcher` | Flow Launcher | utility | yes |
| `sharex` | ShareX | utility | yes |
| `scrcpy` | Scrcpy | utility | yes |
| `vlc` | VLC Media Player | media | yes |
| `obs` | OBS Studio | media | yes |
| `spotify` | Spotify | media | no |
| `discord` | Discord | communication | no |
| `signal` | Signal | communication | yes |
| `keepassxc` | KeePassXC | security | yes |
| `malwarebytes` | Malwarebytes | security | no |
| `jetbrains-mono-nf` | JetBrains Mono (Nerd Font) | font | yes |
| `cascadia-code` | Cascadia Code | font | yes |
| `fira-code` | Fira Code | font | yes |

## Usage

Install a package:

```powershell
winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
```

Install all packages from a category using this data:

```powershell
$packages = Get-Content packages.json | ConvertFrom-Json
$devTools = $packages | Where-Object category -eq 'dev-tool'
foreach ($pkg in $devTools) {
    winget install --id $pkg.id --silent --accept-package-agreements --accept-source-agreements
}
```

## Examples

### Shell — list all package IDs in a category

```bash
jq -r '[.[] | select(.category == "dev-tool") | .id] | .[]' packages.json
```

### Shell — list only open-source packages

```bash
jq '[.[] | select(.["open-source"] == true) | {slug, name, category}]' packages.json
```

### Shell — generate a winget install script

```bash
jq -r '.[] | "winget install --id \(.id) --silent"' packages.json
```

### JavaScript — look up a package by slug

```javascript
const packages = await fetch('packages.json').then(r => r.json());
const bySlug = Object.fromEntries(packages.map(p => [p.slug, p]));

const pkg = bySlug['vscode'];
console.log(`winget install --id ${pkg.id}`);
// "winget install --id Microsoft.VisualStudioCode"
```

### JavaScript — generate install commands by category

```javascript
const packages = await fetch('packages.json').then(r => r.json());
const browsers = packages.filter(p => p.category === 'browser');
const cmds = browsers.map(p => `winget install --id ${p.id} --silent`);
console.log(cmds.join('\n'));
```

### PHP — display packages grouped by category

```php
$packages = json_decode(file_get_contents('packages.json'), true);
$byCategory = [];
foreach ($packages as $p) {
    $byCategory[$p['category']][] = $p;
}
foreach ($byCategory as $cat => $group) {
    echo "$cat:\n";
    foreach ($group as $p) {
        $oss = $p['open-source'] ? 'OSS' : 'proprietary';
        echo "  {$p['name']} ({$p['id']}) [$oss]\n";
    }
}
```
