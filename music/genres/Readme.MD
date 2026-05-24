# Music Genres

A structured reference for 20 major music genres with BPM ranges, mood tags, geographic origin, and example artists. Useful for music recommendation systems, playlist generators, content tagging, and metadata enrichment.

## JSON

### Structure as of 24.05.2026

```json
{
  "slug": "jazz",
  "name": "Jazz",
  "bpm_range": [60, 200],
  "mood": ["improvisational", "sophisticated", "cool"],
  "origin_decade": "1910s",
  "origin_region": "New Orleans, USA",
  "example_artists": ["Miles Davis", "John Coltrane", "Thelonious Monk"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `slug` | string | Lowercase hyphen-separated identifier |
| `name` | string | Genre name |
| `bpm_range` | [number, number] | Typical BPM range `[min, max]` |
| `mood` | string[] | Mood/energy descriptors |
| `origin_decade` | string | Decade the genre emerged (e.g. `"1970s"`) |
| `origin_region` | string | Geographic origin |
| `example_artists` | string[] | Representative well-known artists |

## Entries

| Slug | Name | BPM Range | Origin |
|---|---|---|---|
| `rock` | Rock | 100–140 | United States, 1950s |
| `pop` | Pop | 100–130 | US/UK, 1960s |
| `hip-hop` | Hip-Hop | 75–115 | New York, 1970s |
| `electronic` | Electronic | 110–180 | Europe, 1970s |
| `jazz` | Jazz | 60–200 | New Orleans, 1910s |
| `classical` | Classical | 40–200 | Europe, 1600s |
| `country` | Country | 80–130 | Southern US, 1920s |
| `reggae` | Reggae | 60–90 | Jamaica, 1960s |
| `blues` | Blues | 60–120 | Deep South, 1900s |
| `metal` | Metal | 100–250 | United Kingdom, 1970s |
| `punk` | Punk | 150–220 | US/UK, 1970s |
| `rnb` | R&B | 70–110 | United States, 1940s |
| `soul` | Soul | 60–110 | United States, 1950s |
| `funk` | Funk | 85–115 | United States, 1960s |
| `techno` | Techno | 130–160 | Detroit, 1980s |
| `house` | House | 120–130 | Chicago, 1980s |
| `ambient` | Ambient | 50–90 | United Kingdom, 1970s |
| `latin` | Latin | 90–180 | Latin America, 1930s |
| `folk` | Folk | 60–110 | US/UK, 1940s |
| `indie` | Indie | 90–140 | US/UK, 1980s |

## Examples

### Shell — find genres with BPM above 140

```bash
jq '[.[] | select(.[1:1] | . ; .bpm_range[0] > 140 or .bpm_range[1] > 140) | {slug, bpm_range}]' genres.json
```

### Shell — list genres that originated in the 1970s

```bash
jq '[.[] | select(.origin_decade == "1970s") | .name]' genres.json
```

### JavaScript — find a genre by slug and get moods

```javascript
const genres = await fetch('genres.json').then(r => r.json());
const bySlug = Object.fromEntries(genres.map(g => [g.slug, g]));

const jazz = bySlug['jazz'];
console.log(jazz.mood.join(', '));
// "improvisational, sophisticated, cool"
```

### PHP — find genres suitable for a given BPM

```php
$genres = json_decode(file_get_contents('genres.json'), true);

function matchBpm(array $genres, int $bpm): array {
    return array_filter($genres, fn($g) =>
        $bpm >= $g['bpm_range'][0] && $bpm <= $g['bpm_range'][1]
    );
}

$matches = matchBpm($genres, 125);
foreach ($matches as $g) {
    echo "{$g['name']} ({$g['bpm_range'][0]}–{$g['bpm_range'][1]} BPM)\n";
}
```
