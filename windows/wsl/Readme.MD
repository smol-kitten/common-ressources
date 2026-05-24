# WSL Distro Reference

8 WSL-compatible Linux distributions with install commands, package managers, and notes on use cases.

## JSON

### Structure

```json
{
  "name": "Ubuntu 24.04 LTS",
  "slug": "ubuntu-2404",
  "id": "Ubuntu-24.04",
  "install-cmd": "wsl --install -d Ubuntu-24.04",
  "base": "Ubuntu",
  "version": "24.04",
  "lts": true,
  "default-user": "your-username",
  "package-manager": "apt",
  "init-system": "systemd",
  "notes": "Noble Numbat. Ships with Python 3.12, supports WSL2 systemd natively.",
  "tags": ["ubuntu", "lts", "popular", "recommended"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Full distro display name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `id` | string | WSL distro ID (used with `wsl --install -d`) |
| `install-cmd` | string | Command to install this distro |
| `base` | string | Upstream Linux base distribution |
| `version` | string | Version or `"rolling"` |
| `lts` | boolean | Whether this is a Long Term Support release |
| `default-user` | string | Default login user after first-run setup |
| `package-manager` | string | Primary package manager (`apt`, `pacman`, `dnf`, etc.) |
| `init-system` | string | Init system (`systemd`, `openrc`) |
| `notes` | string | Additional context, caveats, or recommended use cases |
| `tags` | string[] | Keywords for filtering |

## Distros Included

| Slug | Base | Version | LTS | Package Manager |
|---|---|---|---|---|
| `ubuntu-2404` | Ubuntu | 24.04 | yes | apt |
| `ubuntu-2204` | Ubuntu | 22.04 | yes | apt |
| `debian` | Debian | 12 | yes | apt |
| `arch-wsl` | Arch | rolling | no | pacman |
| `fedora-remix` | Fedora | 39 | no | dnf |
| `opensuse-tumbleweed` | openSUSE | rolling | no | zypper |
| `kali-linux` | Debian | rolling | no | apt |
| `alpine` | Alpine | 3.x | no | apk |

## Usage

### List installed distros

```powershell
wsl --list --verbose
```

### Set default distro

```powershell
wsl --set-default Ubuntu-24.04
```

### Install a new distro

```powershell
wsl --install -d Debian
```

### Terminate a running distro

```powershell
wsl --terminate Ubuntu-24.04
```

### PowerShell — install from JSON by slug

```powershell
$distros = Get-Content distros.json | ConvertFrom-Json
$d = $distros | Where-Object slug -eq 'debian'
Invoke-Expression $d.'install-cmd'
```

### JavaScript — filter LTS distros

```javascript
const distros = await fetch('distros.json').then(r => r.json());
const lts = distros.filter(d => d.lts);
lts.forEach(d => console.log(`${d.name} — ${d['package-manager']}`));
```

### Shell — list by package manager

```bash
jq 'group_by(.["package-manager"]) | map({manager: .[0]["package-manager"], distros: map(.name)})' distros.json
```
