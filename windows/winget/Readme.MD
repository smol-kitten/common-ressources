# Winget Package Reference

25 curated Windows packages installable via `winget`. Covers terminals, shells, editors, runtimes, utilities, and fonts. All entries include the official winget package ID.

## JSON

### Structure

```json
{
  "name": "Windows Terminal",
  "slug": "windows-terminal",
  "id": "Microsoft.WindowsTerminal",
  "category": "terminal",
  "description": "Modern tabbed terminal with GPU acceleration, themes, and pane splitting.",
  "install-cmd": "winget install Microsoft.WindowsTerminal",
  "open-source": true,
  "tags": ["terminal", "microsoft", "essential"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Display name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `id` | string | Official winget package ID |
| `category` | string | Functional category |
| `description` | string | What the package is and does |
| `install-cmd` | string | Ready-to-run install command |
| `open-source` | boolean | Whether the package is open-source |
| `tags` | string[] | Keywords for filtering |

### Categories

`terminal` · `shell` · `editor` · `runtime` · `utilities` · `fonts` · `development` · `package-manager` · `containers` · `productivity` · `media` · `security`

## Packages Included

| Slug | ID | Category |
|---|---|---|
| `windows-terminal` | Microsoft.WindowsTerminal | terminal |
| `powershell-7` | Microsoft.PowerShell | shell |
| `git` | Git.Git | development |
| `vscode` | Microsoft.VisualStudioCode | editor |
| `neovim` | Neovim.Neovim | editor |
| `starship` | Starship.Starship | shell |
| `oh-my-posh` | JanDeDobbeleer.OhMyPosh | shell |
| `nodejs` | OpenJS.NodeJS | runtime |
| `python3` | Python.Python.3 | runtime |
| `rustup` | Rustlang.Rustup | runtime |
| `7zip` | 7zip.7zip | utilities |
| `scoop` | ScoopInstaller.Scoop | package-manager |
| `chocolatey` | Chocolatey.Chocolatey | package-manager |
| `jetbrainsmono-nf` | DEVCOM.JetBrainsMonoNerdFont | fonts |
| `firacode-nf` | DEVCOM.FiraCode | fonts |
| `gh` | GitHub.cli | development |
| `fzf` | junegunn.fzf | utilities |
| `ripgrep` | BurntSushi.ripgrep.MSVC | utilities |
| `bat` | sharkdp.bat | utilities |
| `lsd` | lsd-rs.lsd | utilities |
| `docker-desktop` | Docker.DockerDesktop | containers |
| `obsidian` | Obsidian.Obsidian | productivity |
| `vlc` | VideoLAN.VLC | media |
| `bitwarden` | Bitwarden.Bitwarden | security |
| `sharex` | ShareX.ShareX | utilities |

## Usage

### Install a single package

```powershell
winget install Microsoft.WindowsTerminal
```

### Install all packages from JSON (PowerShell)

```powershell
$pkgs = Get-Content packages.json | ConvertFrom-Json
$pkgs | ForEach-Object { winget install $_.id --silent --accept-package-agreements }
```

### Search for available winget IDs

```powershell
winget search <name>
winget show <id>
```

### JavaScript — build install script

```javascript
const pkgs = await fetch('packages.json').then(r => r.json());
const essentials = pkgs.filter(p => p.tags.includes('essential'));
const script = essentials.map(p => p['install-cmd']).join('\n');
console.log(script);
```

### Shell — list open-source packages only

```bash
jq '[.[] | select(.["open-source"] == true) | {slug, id}]' packages.json
```
