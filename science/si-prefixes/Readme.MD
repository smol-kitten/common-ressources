# SI Prefixes

All 24 SI (metric) prefixes defined by the BIPM, from quetta (10³⁰) down to quecto (10⁻³⁰), including the four prefixes added by the 27th CGPM in 2022 (ronna, quetta, ronto, quecto). Each entry gives the prefix name, symbol, power-of-ten exponent, exact decimal multiplier, and the year it was introduced. Useful for unit-conversion tools, scientific formatting, and educational references.

## JSON

### Structure

```json
{
  "name": "kilo",
  "symbol": "k",
  "base10": 3,
  "value": "1000",
  "adopted": 1795
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Prefix name (lowercase, as written by BIPM) |
| `symbol` | string | Prefix symbol; note `da` (deca) is two letters and `µ` (micro) is U+00B5 |
| `base10` | integer | Power of ten the prefix represents (e.g. `3` for kilo = 10³) |
| `value` | string | Exact decimal multiplier as a string (avoids float precision loss for large/small factors) |
| `adopted` | integer | Year the prefix was introduced: 1795 (original metric system), 1873 (CGS), or the CGPM year for SI-era additions (1960/1964/1975/1991/2022) |

### Notes

- `value` is a string rather than a number so exact multipliers such as 10⁻³⁰ survive JSON round-tripping without floating-point error.
- The `micro` symbol uses the micro sign `µ` (U+00B5); some systems prefer the Greek small letter mu `μ` (U+03BC). They are visually similar but distinct code points.

## Sources

- BIPM, *The International System of Units (SI Brochure)*, 9th edition, and 27th CGPM (2022) Resolution 3 (ronna, quetta, ronto, quecto).
