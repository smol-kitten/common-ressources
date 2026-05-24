# WSL Distros

A structured JSON reference for WSL (Windows Subsystem for Linux) distributions with install commands, init system, package manager, and recommended use cases.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Ubuntu 22.04 LTS",
  "slug": "ubuntu-2204",
  "wsl-version": 2,
  "install-cmd": "wsl --install -d Ubuntu-22.04",
  "default-user": "your-username",
  "init-system": "systemd",
  "package-manager": "apt",
  "notes": "Jammy Jellyfish. Most CI/CD pipelines target this release.",
  "good-for": ["general-development", "ci-cd", "docker"],
  "tags": ["ubuntu", "lts", "popular", "ci"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Full distro display name |
| `slug` | string | Lowercase hyphen-separated identifier |
| `wsl-version` | number | Required WSL version (1 or 2) |
| `install-cmd` | string | Shell command to install the distro |
| `default-user` | string | Default login user after initial setup |
| `init-system` | string | Init system: `systemd` or `openrc` |
| `package-manager` | string | Primary package manager (apt, pacman, dnf, zypper, apk) |
| `notes` | string | Additional context, caveats, and version details |
| `good-for` | string[] | Recommended use cases |
| `tags` | string[] | Keywords for filtering and discovery |

## Distros included

| Slug | Name | Package Manager | Init System |
|---|---|---|---|
| `ubuntu-2204` | Ubuntu 22.04 LTS | apt | systemd |
| `ubuntu-2404` | Ubuntu 24.04 LTS | apt | systemd |
| `debian` | Debian | apt | systemd |
| `arch-wsl` | Arch Linux (unofficial) | pacman | systemd |
| `kali-linux` | Kali Linux | apt | systemd |
| `opensuse-tumbleweed` | openSUSE Tumbleweed | zypper | systemd |
| `fedora-remix` | Fedora Remix for WSL | dnf | systemd |
| `alpine` | Alpine Linux | apk | openrc |
| `oracle-linux-8` | Oracle Linux 8 | dnf | systemd |
| `sles` | SUSE Linux Enterprise | zypper | systemd |

## Prerequisites

WSL 2 is required for all entries. Enable it once:

```powershell
# Run as Administrator
wsl --install
wsl --set-default-version 2
```

## Examples

### Shell (PowerShell) — install a distro by slug

```powershell
$distros = Get-Content distros.json | ConvertFrom-Json
$d = $distros | Where-Object slug -eq 'debian'
Write-Host "Running: $($d.'install-cmd')"
# Execute manually or: Invoke-Expression $d.'install-cmd'
```

### Shell — list all distros and their package managers

```bash
jq '[.[] | {slug, name, "package-manager"}]' distros.json
```

### Shell — find distros using apt

```bash
jq '[.[] | select(.["package-manager"] == "apt") | .name]' distros.json
```

### Shell — find distros good for a use case

```bash
jq '[.[] | select(.["good-for"] | contains(["docker"])) | .name]' distros.json
```

### JavaScript — look up a distro by slug

```javascript
const distros = await fetch('distros.json').then(r => r.json());
const bySlug = Object.fromEntries(distros.map(d => [d.slug, d]));

const arch = bySlug['arch-wsl'];
console.log(arch['install-cmd']);
// "# Download from ... wsl --import Arch ..."
```

### JavaScript — group by package manager

```javascript
const distros = await fetch('distros.json').then(r => r.json());
const byPM = distros.reduce((acc, d) => {
  (acc[d['package-manager']] = acc[d['package-manager']] || []).push(d.name);
  return acc;
}, {});
console.log(byPM);
// { apt: ["Ubuntu 22.04 LTS", "Ubuntu 24.04 LTS", ...], pacman: [...], ... }
```

### PHP — display distros grouped by package manager

```php
$distros = json_decode(file_get_contents('distros.json'), true);
$byPM = [];
foreach ($distros as $d) {
    $byPM[$d['package-manager']][] = $d;
}
foreach ($byPM as $pm => $group) {
    echo "$pm:\n";
    foreach ($group as $d) {
        echo "  {$d['name']}: {$d['install-cmd']}\n";
    }
}
```
