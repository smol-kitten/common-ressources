# SI Derived Units (Special Names)

The 22 SI derived units that have special names and symbols — from hertz and newton to katal — each expressed both in terms of other SI units and in SI base units. These cover frequency, force, energy, power, electricity, magnetism, light, radioactivity, and catalytic activity. Useful for unit-conversion tools, dimensional-analysis engines, and physics/engineering references.

## JSON

### Structure

```json
{
  "name": "watt",
  "symbol": "W",
  "quantity": "power, radiant flux",
  "expression_si": "J/s",
  "expression_base": "kg·m²·s⁻³"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Unit name (BIPM spelling) |
| `symbol` | string | Unit symbol (e.g. `Ω`, `°C`) |
| `quantity` | string | The physical quantity the unit measures |
| `expression_si` | string \| null | Expression in terms of other SI units; `null` where the unit is expressed directly in base units (e.g. hertz, newton) |
| `expression_base` | string | Expression in SI base units (dimensionless units use `1`) |

### Notes

- These are exactly the 22 named derived units listed in the SI Brochure. Other derived units (e.g. m/s, m², kg/m³) are combinations without special names and are not included here.
- Powers use Unicode superscripts and the middle dot `·` (U+00B7) as the multiplication separator, matching BIPM typographic conventions.
- `radian` and `steradian` are dimensionless (base expression `1`).

## Sources

- BIPM, *The International System of Units (SI Brochure)*, 9th edition — Table 4 (coherent derived units with special names).
