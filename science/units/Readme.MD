# Units of Measurement

A structured reference for common SI and imperial units covering length, mass, time, temperature, energy, power, pressure, and volume. Each entry includes a conversion factor to the SI base unit, making programmatic unit conversion straightforward.

## JSON

### Structure as of 24.05.2026

```json
{
  "slug": "kilometer",
  "name": "Kilometer",
  "symbol": "km",
  "quantity": "length",
  "system": "SI",
  "to_si_factor": 1000,
  "notes": "1 km = 1000 m"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `slug` | string | Lowercase hyphen-separated identifier |
| `name` | string | Human-readable unit name |
| `symbol` | string | Standard unit symbol |
| `quantity` | string | Physical quantity measured (length, mass, time, temperature, energy, power, pressure, volume) |
| `system` | string | Measurement system: `SI`, `imperial`, `metric`, `CGS` |
| `to_si_factor` | number \| null | Multiply by this to convert to SI base unit. `null` for temperature (non-linear) |
| `notes` | string | Conversion notes or formula |

### Quantities

| Quantity | SI Base Unit |
|---|---|
| length | meter (m) |
| mass | kilogram (kg) |
| time | second (s) |
| temperature | kelvin (K) — note: Celsius/Fahrenheit use offset formulas |
| energy | joule (J) |
| power | watt (W) |
| pressure | pascal (Pa) |
| volume | cubic meter (m³) |

## Entries

| Slug | Symbol | Quantity | System | SI Factor |
|---|---|---|---|---|
| meter | m | length | SI | 1 |
| kilometer | km | length | SI | 1000 |
| centimeter | cm | length | SI | 0.01 |
| millimeter | mm | length | SI | 0.001 |
| inch | in | length | imperial | 0.0254 |
| foot | ft | length | imperial | 0.3048 |
| mile | mi | length | imperial | 1609.344 |
| kilogram | kg | mass | SI | 1 |
| gram | g | mass | SI | 0.001 |
| pound | lb | mass | imperial | 0.453592 |
| ounce | oz | mass | imperial | 0.0283495 |
| second | s | time | SI | 1 |
| minute | min | time | SI | 60 |
| hour | h | time | SI | 3600 |
| day | d | time | SI | 86400 |
| kelvin | K | temperature | SI | 1 |
| celsius | °C | temperature | SI | null |
| fahrenheit | °F | temperature | imperial | null |
| joule | J | energy | SI | 1 |
| calorie | cal | energy | CGS | 4.184 |
| watt | W | power | SI | 1 |
| pascal | Pa | pressure | SI | 1 |
| bar | bar | pressure | metric | 100000 |
| liter | L | volume | SI | 0.001 |
| gallon-us | gal | volume | imperial | 0.003785 |

## Examples

### Shell — list all imperial units

```bash
jq '[.[] | select(.system == "imperial") | {slug, symbol, quantity}]' units.json
```

### Shell — convert 5 miles to kilometers

```bash
jq '(.[] | select(.slug == "mile") | .to_si_factor) / (.[] | select(.slug == "kilometer") | .to_si_factor) * 5' units.json
```

### JavaScript — convert any two compatible units

```javascript
const units = await fetch('units.json').then(r => r.json());
const bySlug = Object.fromEntries(units.map(u => [u.slug, u]));

function convert(value, fromSlug, toSlug) {
  const from = bySlug[fromSlug];
  const to = bySlug[toSlug];
  if (!from || !to || from.quantity !== to.quantity) return null;
  return (value * from.to_si_factor) / to.to_si_factor;
}

console.log(convert(100, 'kilometer', 'mile').toFixed(2)); // "62.14"
console.log(convert(1, 'kilogram', 'pound').toFixed(4));   // "2.2046"
```

### PHP — list units by quantity

```php
$units = json_decode(file_get_contents('units.json'), true);
$byQuantity = [];
foreach ($units as $unit) {
    $byQuantity[$unit['quantity']][] = $unit;
}
foreach ($byQuantity as $qty => $items) {
    echo "$qty: " . implode(', ', array_column($items, 'symbol')) . "\n";
}
```
