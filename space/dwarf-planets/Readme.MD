# Dwarf Planets

The five bodies officially recognised as dwarf planets by the International
Astronomical Union (IAU): **Ceres** (asteroid belt), **Pluto**, **Haumea**,
**Makemake** (Kuiper belt), and **Eris** (scattered disc).

A dwarf planet orbits the Sun and is massive enough to be rounded by its own
gravity, but — unlike the eight planets — has **not** cleared its orbital
neighbourhood of other bodies.

## Structure

```json
{
  "name": "Pluto",
  "type": "dwarf planet",
  "region": "Kuiper belt",
  "mass_kg": 1.303e22,
  "radius_km": 1188.3,
  "distance_from_sun_km": 5906380000,
  "orbital_period_days": 90560,
  "moons": 5,
  "avg_temperature_c": -229,
  "discovered": 1930,
  "designation": "134340 Pluto"
}
```

| Field | Description |
|---|---|
| `name` | Common name |
| `region` | Dynamical population (asteroid belt / Kuiper belt / scattered disc) |
| `mass_kg` | Mass in kilograms |
| `radius_km` | Mean radius in km (Haumea is markedly ellipsoidal) |
| `distance_from_sun_km` | Semi-major axis of the orbit |
| `orbital_period_days` | Sidereal orbital period |
| `moons` | Number of known natural satellites |
| `avg_temperature_c` | Approximate mean surface temperature |
| `discovered` | Year of discovery |
| `designation` | Minor-planet designation |

**Source:** [IAU — Pluto and the Solar System](https://www.iau.org/public/themes/pluto/),
[NASA Solar System Exploration](https://science.nasa.gov/dwarf-planets/). Values are
approximate; verify against [JPL Small-Body Database](https://ssd.jpl.nasa.gov/) for
precise work. See also [`space/planets/planets.json`](/space/planets/planets.json).
