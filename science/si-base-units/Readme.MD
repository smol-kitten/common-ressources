# SI Base Units

The seven SI base units — second, metre, kilogram, ampere, kelvin, mole, and candela — from which all other SI units are derived. Since the 2019 SI redefinition each base unit is defined by fixing the exact numerical value of a fundamental physical constant. Each entry gives the unit name, symbol, the physical quantity it measures, and its defining constant. Useful for scientific tooling, metrology references, and educational content.

## JSON

### Structure

```json
{
  "name": "metre",
  "symbol": "m",
  "quantity": "length",
  "defining_constant": "speed of light in vacuum c",
  "constant_value": "299792458 m/s",
  "adopted": 2019
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Unit name (BIPM spelling; `metre`, not `meter`) |
| `symbol` | string | Unit symbol |
| `quantity` | string | The base physical quantity the unit measures |
| `defining_constant` | string | The fundamental constant whose fixed value defines the unit |
| `constant_value` | string | The exact numerical value assigned to that constant |
| `adopted` | integer | Year the current (constant-based) definition took effect (2019 for all seven) |

### Notes

- The 2019 redefinition made every base unit traceable to an exactly-fixed constant, replacing the physical kilogram artefact (IPK) with a definition via the Planck constant.
- Constant values are stored as strings to preserve exact digits and units.

## Sources

- BIPM, *The International System of Units (SI Brochure)*, 9th edition (2019).
