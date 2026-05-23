# Colors

Structured color references — CSS named colors and curated themed palettes.

## Files

| File | Description |
|---|---|
| [`named.json`](named.json) | All 148 CSS named colors with hex and RGB values |
| [`palettes.json`](palettes.json) | Curated color palettes for various use cases |

---

## named.json

All standard CSS named colors as defined in the CSS Color Level 4 specification.

### Structure as of 23.05.2026

```json
{
  "name": "cornflowerblue",
  "hex": "#6495ED",
  "rgb": [100, 149, 237]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | CSS color name (lowercase, no spaces) |
| `hex` | string | Hexadecimal color value |
| `rgb` | number[3] | RGB values as [red, green, blue], each 0–255 |

---

## palettes.json

Curated palettes for UI design, pride themes, terminal styling, and more.

### Structure as of 23.05.2026

```json
{
  "name": "Pride Rainbow",
  "slug": "pride-rainbow",
  "description": "Description of the palette.",
  "colors": [
    { "name": "red", "hex": "#E40303" },
    { "name": "orange", "hex": "#FF8C00" }
  ],
  "tags": ["lgbtq", "pride", "rainbow"]
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Human-readable palette name |
| `slug` | string | URL-safe identifier |
| `description` | string | Purpose and background of the palette |
| `colors` | object[] | Ordered list of named hex colors |
| `tags` | string[] | Categorization tags |

### Available palettes

| Slug | Description |
|---|---|
| `pride-rainbow` | Classic 6-color LGBTQ+ rainbow |
| `trans-pride` | Transgender flag colors |
| `nonbinary-pride` | Nonbinary flag colors |
| `bisexual-pride` | Bisexual flag colors |
| `ansi-16` | Standard 16 ANSI terminal colors |
| `pastel-dream` | Soft pastels for gentle UI |
| `material-primary` | Material Design primary hues |
| `grayscale` | 11-step grayscale |
| `earth-tones` | Natural earth-inspired palette |
| `cyberpunk-neon` | High-contrast neon for dark themes |

---

## Examples

### Shell — find a CSS color by name

```bash
jq '.[] | select(.name == "cornflowerblue")' named.json
```

### Shell — get all colors in a palette

```bash
jq '.[] | select(.slug == "pride-rainbow") | .colors[].hex' palettes.json
```

### PHP — hex to CSS name lookup

```php
$colors = json_decode(file_get_contents('named.json'), true);
$byHex = array_column($colors, 'name', 'hex');
echo $byHex['#FF0000']; // "red"
```

### JavaScript — build a CSS variable block from a palette

```javascript
const palettes = await fetch('palettes.json').then(r => r.json());
const pride = palettes.find(p => p.slug === 'pride-rainbow');
const css = pride.colors
  .map(c => `  --pride-${c.name.replace(/\s+/g, '-')}: ${c.hex};`)
  .join('\n');
console.log(`:root {\n${css}\n}`);
```
