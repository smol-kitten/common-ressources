# Timezones

A structured reference for IANA timezone identifiers with UTC offsets, DST information, and region groupings. Covers major zones across all inhabited continents — useful for building timezone pickers, scheduling tools, or localizing datetime output.

## JSON

### Structure as of 24.05.2026

```json
{
  "iana": "America/New_York",
  "utc_offset": "-05:00",
  "dst_offset": "-04:00",
  "dst": true,
  "region": "Americas",
  "abbreviation": "EST/EDT",
  "example_cities": ["New York", "Miami", "Toronto"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `iana` | string | IANA timezone identifier (e.g. `America/New_York`) |
| `utc_offset` | string | Standard UTC offset in `+HH:MM` / `-HH:MM` format |
| `dst_offset` | string | DST UTC offset (same as `utc_offset` when `dst` is false) |
| `dst` | boolean | Whether this zone observes Daylight Saving Time |
| `region` | string | Broad geographic region |
| `abbreviation` | string | Common abbreviation(s); slash-separated for standard/DST |
| `example_cities` | string[] | Representative cities in this timezone |

### Regions

| Region | Description |
|---|---|
| `Universal` | UTC / no region |
| `Americas` | North, Central, and South America |
| `Europe` | European timezones |
| `Asia` | Asian timezones |
| `Africa` | African timezones |
| `Pacific` | Pacific / Oceania timezones |

## Entries

| IANA | UTC Offset | DST | Region |
|---|---|---|---|
| `UTC` | +00:00 | No | Universal |
| `America/New_York` | -05:00 | Yes | Americas |
| `America/Chicago` | -06:00 | Yes | Americas |
| `America/Denver` | -07:00 | Yes | Americas |
| `America/Los_Angeles` | -08:00 | Yes | Americas |
| `America/Anchorage` | -09:00 | Yes | Americas |
| `Pacific/Honolulu` | -10:00 | No | Pacific |
| `America/Sao_Paulo` | -03:00 | No | Americas |
| `America/Argentina/Buenos_Aires` | -03:00 | No | Americas |
| `Europe/London` | +00:00 | Yes | Europe |
| `Europe/Paris` | +01:00 | Yes | Europe |
| `Europe/Helsinki` | +02:00 | Yes | Europe |
| `Europe/Moscow` | +03:00 | No | Europe |
| `Asia/Dubai` | +04:00 | No | Asia |
| `Asia/Karachi` | +05:00 | No | Asia |
| `Asia/Kolkata` | +05:30 | No | Asia |
| `Asia/Dhaka` | +06:00 | No | Asia |
| `Asia/Bangkok` | +07:00 | No | Asia |
| `Asia/Shanghai` | +08:00 | No | Asia |
| `Asia/Tokyo` | +09:00 | No | Asia |
| `Australia/Sydney` | +10:00 | Yes | Pacific |
| `Pacific/Auckland` | +12:00 | Yes | Pacific |
| `Africa/Cairo` | +02:00 | No | Africa |
| `Africa/Lagos` | +01:00 | No | Africa |
| `Africa/Nairobi` | +03:00 | No | Africa |

## Examples

### Shell — list all zones that observe DST

```bash
jq '[.[] | select(.dst == true) | .iana]' timezones.json
```

### Shell — find zones in Europe

```bash
jq '[.[] | select(.region == "Europe") | {iana, utc_offset, abbreviation}]' timezones.json
```

### JavaScript — build a timezone picker array

```javascript
const zones = await fetch('timezones.json').then(r => r.json());
const options = zones.map(z => ({
  value: z.iana,
  label: `(UTC${z.utc_offset}) ${z.iana.replace('_', ' ')} — ${z.example_cities[0]}`
}));
console.log(options[0]);
// { value: 'UTC', label: '(UTC+00:00) UTC — Reykjavik' }
```

### PHP — get the offset for a given IANA name

```php
$zones = json_decode(file_get_contents('timezones.json'), true);
$byIana = array_column($zones, null, 'iana');

$tz = $byIana['Asia/Tokyo'];
echo $tz['abbreviation'];  // "JST"
echo $tz['utc_offset'];    // "+09:00"
```
