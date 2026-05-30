# Solar System Planets

Physical and orbital data for all 8 planets of the Solar System. Each entry includes mass, radius, distance from the Sun, orbital and rotation periods, moon count, ring status, and average surface temperature.

## JSON

### Structure as of 24.05.2026

```json
{
  "name": "Mars",
  "order": 4,
  "type": "terrestrial",
  "mass_kg": 6.39e+23,
  "radius_km": 3389.5,
  "distance_from_sun_km": 227939200,
  "orbital_period_days": 686.97,
  "rotation_period_days": 1.03,
  "moons": 2,
  "has_rings": false,
  "avg_temperature_c": -65
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Planet name |
| `order` | number | Orbital order from the Sun (1 = Mercury) |
| `type` | string | Planet classification |
| `mass_kg` | number | Mass in kilograms (scientific notation) |
| `radius_km` | number | Mean radius in kilometers |
| `distance_from_sun_km` | number | Semi-major axis distance from Sun in kilometers |
| `orbital_period_days` | number | Time to complete one orbit around the Sun (Earth days) |
| `rotation_period_days` | number | Sidereal rotation period (Earth days) |
| `moons` | number | Number of confirmed natural satellites |
| `has_rings` | boolean | Whether the planet has a ring system |
| `avg_temperature_c` | number | Average surface/cloud-top temperature in Celsius |

### Planet Types

| Type | Members |
|---|---|
| `terrestrial` | Mercury, Venus, Earth, Mars |
| `gas-giant` | Jupiter, Saturn |
| `ice-giant` | Uranus, Neptune |

## Entries

| Name | Order | Type | Moons | Rings | Avg Temp (°C) |
|---|---|---|---|---|---|
| Mercury | 1 | terrestrial | 0 | No | 167 |
| Venus | 2 | terrestrial | 0 | No | 464 |
| Earth | 3 | terrestrial | 1 | No | 15 |
| Mars | 4 | terrestrial | 2 | No | -65 |
| Jupiter | 5 | gas-giant | 95 | Yes | -110 |
| Saturn | 6 | gas-giant | 146 | Yes | -140 |
| Uranus | 7 | ice-giant | 28 | Yes | -195 |
| Neptune | 8 | ice-giant | 16 | Yes | -200 |

## Examples

### Shell — list planets sorted by distance from the Sun

```bash
jq '[.[] | {name, distance_from_sun_km}] | sort_by(.distance_from_sun_km)' planets.json
```

### Shell — find all planets with rings

```bash
jq '[.[] | select(.has_rings == true) | .name]' planets.json
```

### JavaScript — calculate total moons in the solar system

```javascript
const planets = await fetch('planets.json').then(r => r.json());
const totalMoons = planets.reduce((sum, p) => sum + p.moons, 0);
console.log(`Total confirmed moons: ${totalMoons}`);
// Total confirmed moons: 288
```

### PHP — display planets by type

```php
$planets = json_decode(file_get_contents('planets.json'), true);
$byType = [];
foreach ($planets as $p) {
    $byType[$p['type']][] = $p['name'];
}
foreach ($byType as $type => $names) {
    echo "$type: " . implode(', ', $names) . "\n";
}
// terrestrial: Mercury, Venus, Earth, Mars
// gas-giant: Jupiter, Saturn
// ice-giant: Uranus, Neptune
```
