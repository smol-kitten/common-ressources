# Pacman Mirrors

A structured JSON reference for Arch Linux pacman mirrors with region metadata. Covers fast and reliable mirrors across Europe, the Americas, and Asia sourced from the official Arch Linux mirror list.

## JSON

### Structure as of 24.05.2026

```json
{
  "url": "https://mirror.rackspace.com/archlinux/$repo/os/$arch",
  "country": "United States",
  "code": "US",
  "continent": "Americas",
  "protocol": "https",
  "active": true,
  "speed-tier": "fast",
  "notes": "Rackspace CDN mirror, high bandwidth"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `url` | string | Mirror URL with pacman variables (`$repo`, `$arch`) |
| `country` | string | Full country name |
| `code` | string | ISO 3166-1 alpha-2 country code |
| `continent` | string | Continental region: `Europe`, `Americas`, or `Asia` |
| `protocol` | string | Transfer protocol: `https` or `http` |
| `active` | boolean | Whether the mirror is currently active |
| `speed-tier` | string | Relative speed: `fast`, `medium`, or `slow` |
| `notes` | string | Additional context about the mirror host |

## Mirrors by region

### Americas (6 mirrors)
US (4) · Canada (1) · Anonymous/CDN (1)

### Europe (10 mirrors)
France (3) · Germany (4) · Denmark (1) · Netherlands (1) · OVH (1)

### Asia / Pacific (6 mirrors)
China (2) · Singapore (1) · Japan (1) · Taiwan (1) · Australia (1)

## Usage

To use these mirrors, paste URLs into `/etc/pacman.d/mirrorlist`. The fastest approach is to use `reflector` or `rate-mirrors` to auto-rank and apply:

```bash
# Install reflector
sudo pacman -S reflector

# Generate a ranked mirrorlist from this data (example)
sudo reflector --country "Germany,France" --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist
```

## Examples

### Shell — list all mirrors in a given continent

```bash
jq '[.[] | select(.continent == "Europe") | {country, url}]' pacman-mirrors.json
```

### Shell — get only fast HTTPS mirrors

```bash
jq '[.[] | select(.["speed-tier"] == "fast" and .protocol == "https") | .url]' pacman-mirrors.json
```

### Shell — generate a mirrorlist snippet

```bash
jq -r '[.[] | select(.continent == "Europe")] | .[] | "Server = \(.url)"' pacman-mirrors.json
```

### JavaScript — build a mirrorlist for a region

```javascript
const mirrors = await fetch('pacman-mirrors.json').then(r => r.json());
const eu = mirrors.filter(m => m.continent === 'Europe' && m.active);
const mirrorlist = eu.map(m => `Server = ${m.url}`).join('\n');
console.log(mirrorlist);
```

### JavaScript — group mirrors by country

```javascript
const mirrors = await fetch('pacman-mirrors.json').then(r => r.json());
const byCountry = mirrors.reduce((acc, m) => {
  (acc[m.code] = acc[m.code] || []).push(m);
  return acc;
}, {});
console.log(Object.keys(byCountry));
// ["US", "CA", "FR", "DE", "DK", "NL", "CN", "SG", "JP", "TW", "AU"]
```

### PHP — generate a mirrorlist file

```php
$mirrors = json_decode(file_get_contents('pacman-mirrors.json'), true);
$continent = 'Europe';
$lines = [];
foreach ($mirrors as $m) {
    if ($m['continent'] === $continent && $m['active']) {
        $lines[] = "# {$m['country']}";
        $lines[] = "Server = {$m['url']}";
    }
}
file_put_contents('/tmp/mirrorlist', implode("\n", $lines));
```
