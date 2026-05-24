# Date Formats

A structured reference for 17 common date and datetime format strings used across programming languages, standards, databases, and regional conventions. Each entry includes the format pattern, a concrete example, category, and the systems or contexts where it is used.

## JSON

### Structure as of 24.05.2026

```json
{
  "slug": "iso8601-date",
  "name": "ISO 8601 Date",
  "format": "YYYY-MM-DD",
  "example": "2025-05-24",
  "category": "international",
  "used_in": ["ISO 8601", "HTML date inputs", "APIs", "databases"],
  "notes": "Universally recommended for data interchange"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `slug` | string | Lowercase hyphen-separated identifier |
| `name` | string | Human-readable format name |
| `format` | string | Format pattern string (notation varies by category) |
| `example` | string | Concrete example output |
| `category` | string | Format category (see below) |
| `used_in` | string[] | Systems, standards, or contexts where this format appears |
| `notes` | string | Usage guidance, caveats, or conversion notes |

### Categories

| Category | Description |
|---|---|
| `international` | ISO / globally portable formats |
| `machine` | Numeric formats optimized for sorting or computation |
| `internet` | Internet protocol formats (email, HTTP) |
| `regional` | Region-specific display formats |
| `system` | OS or runtime-specific formats |
| `database` | Database-specific formats |
| `display` | Human-readable display formats (not for parsing) |

## Entries

| Slug | Format | Example | Category |
|---|---|---|---|
| `iso8601-date` | YYYY-MM-DD | 2025-05-24 | international |
| `iso8601-datetime` | YYYY-MM-DDTHH:mm:ssZ | 2025-05-24T14:30:00Z | international |
| `iso8601-datetime-offset` | YYYY-MM-DDTHH:mm:ss+HH:mm | 2025-05-24T16:30:00+02:00 | international |
| `unix-timestamp` | integer seconds | 1748096400 | machine |
| `unix-ms` | integer milliseconds | 1748096400000 | machine |
| `rfc2822` | ddd, DD MMM YYYY HH:mm:ss +HHMM | Sat, 24 May 2025 14:30:00 +0000 | internet |
| `rfc7231` | ddd, DD MMM YYYY HH:mm:ss GMT | Sat, 24 May 2025 14:30:00 GMT | internet |
| `us-short` | MM/DD/YYYY | 05/24/2025 | regional |
| `eu-short` | DD/MM/YYYY | 24/05/2025 | regional |
| `eu-dot` | DD.MM.YYYY | 24.05.2025 | regional |
| `iso-short` | YYYYMMDD | 20250524 | machine |
| `strftime-c` | %a %b %e %H:%M:%S %Y | Sat May 24 14:30:00 2025 | system |
| `sql-datetime` | YYYY-MM-DD HH:mm:ss | 2025-05-24 14:30:00 | database |
| `dotnet-sortable` | yyyy-MM-ddTHH:mm:ss | 2025-05-24T14:30:00 | system |
| `excel-us` | M/D/YYYY H:MM AM/PM | 5/24/2025 2:30 PM | regional |
| `japanese-era` | Gee年MM月DD日 | 令和7年05月24日 | regional |
| `relative` | N [unit] ago | 3 days ago | display |

## Examples

### Shell — list all international formats

```bash
jq '[.[] | select(.category == "international") | {slug, format, example}]' formats.json
```

### Shell — find formats used in databases

```bash
jq '[.[] | select(.used_in | contains(["databases"])) | {slug, example}]' formats.json
```

### JavaScript — get format info by slug

```javascript
const formats = await fetch('formats.json').then(r => r.json());
const bySlug = Object.fromEntries(formats.map(f => [f.slug, f]));

const iso = bySlug['iso8601-datetime'];
console.log(`Format: ${iso.format}`);
console.log(`Example: ${iso.example}`);
console.log(`Used in: ${iso.used_in.join(', ')}`);
```

### PHP — find regional formats and their example outputs

```php
$formats = json_decode(file_get_contents('formats.json'), true);
$regional = array_filter($formats, fn($f) => $f['category'] === 'regional');

foreach ($regional as $f) {
    printf("%-20s %s  (%s)\n",
        $f['slug'],
        $f['example'],
        implode(', ', array_slice($f['used_in'], 0, 2))
    );
}
```
