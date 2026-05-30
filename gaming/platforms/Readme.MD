# Gaming Platforms

A structured reference for major gaming platforms spanning consoles, handhelds, hybrid devices, and PC. Covers 18 platforms from the 4th generation to present day. Useful for tagging game libraries, building compatibility matrices, or populating platform dropdowns.

## JSON

### Structure as of 24.05.2026

```json
{
  "slug": "ps5",
  "name": "PlayStation 5",
  "manufacturer": "Sony",
  "release_year": 2020,
  "type": "console",
  "generation": 9,
  "discontinued": false,
  "notes": "AMD Zen 2 CPU, RDNA 2 GPU, custom NVMe SSD"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `slug` | string | Lowercase hyphen-separated identifier |
| `name` | string | Official platform name |
| `manufacturer` | string | Hardware manufacturer |
| `release_year` | number \| null | Year of commercial release; null for open platforms |
| `type` | string | Platform type (see below) |
| `generation` | number \| null | Console generation number; null for non-generational platforms |
| `discontinued` | boolean | Whether the platform is no longer manufactured |
| `notes` | string | Technical highlights or context |

### Types

| Type | Description |
|---|---|
| `console` | Traditional living-room console |
| `handheld` | Dedicated handheld gaming device |
| `hybrid` | Can be used both docked (TV) and as handheld |
| `handheld-pc` | Handheld PC running a full desktop OS |
| `pc` | Open PC platform |

## Entries

| Slug | Name | Manufacturer | Type | Gen | Active |
|---|---|---|---|---|---|
| `pc` | PC | Various | pc | — | Yes |
| `ps5` | PlayStation 5 | Sony | console | 9 | Yes |
| `ps4` | PlayStation 4 | Sony | console | 8 | No |
| `ps3` | PlayStation 3 | Sony | console | 7 | No |
| `xbox-series-x` | Xbox Series X | Microsoft | console | 9 | Yes |
| `xbox-one` | Xbox One | Microsoft | console | 8 | No |
| `switch` | Nintendo Switch | Nintendo | hybrid | 8 | Yes |
| `switch-2` | Nintendo Switch 2 | Nintendo | hybrid | 9 | Yes |
| `wii` | Wii | Nintendo | console | 7 | No |
| `game-boy-advance` | Game Boy Advance | Nintendo | handheld | 6 | No |
| `ds` | Nintendo DS | Nintendo | handheld | 7 | No |
| `3ds` | Nintendo 3DS | Nintendo | handheld | 8 | No |
| `steam-deck` | Steam Deck | Valve | handheld-pc | — | Yes |
| `psp` | PlayStation Portable | Sony | handheld | 7 | No |
| `genesis` | Sega Genesis (Mega Drive) | Sega | console | 4 | No |
| `snes` | Super Nintendo Entertainment System | Nintendo | console | 4 | No |
| `n64` | Nintendo 64 | Nintendo | console | 5 | No |
| `dreamcast` | Dreamcast | Sega | console | 6 | No |

## Examples

### Shell — list currently active platforms

```bash
jq '[.[] | select(.discontinued == false) | {slug, name, type}]' platforms.json
```

### Shell — find all 9th-generation consoles

```bash
jq '[.[] | select(.generation == 9) | {name, manufacturer}]' platforms.json
```

### JavaScript — group platforms by manufacturer

```javascript
const platforms = await fetch('platforms.json').then(r => r.json());
const byMfr = platforms.reduce((acc, p) => {
  (acc[p.manufacturer] ??= []).push(p.name);
  return acc;
}, {});
console.log(byMfr['Nintendo']);
// ["Nintendo Switch", "Nintendo Switch 2", "Wii", ...]
```

### PHP — filter platforms by type

```php
$platforms = json_decode(file_get_contents('platforms.json'), true);

$handhelds = array_filter($platforms, fn($p) =>
    in_array($p['type'], ['handheld', 'hybrid', 'handheld-pc'])
);

foreach ($handhelds as $p) {
    $status = $p['discontinued'] ? 'discontinued' : 'active';
    echo "{$p['name']} ({$p['manufacturer']}) — $status\n";
}
```
