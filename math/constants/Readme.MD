# Mathematical Constants

Famous mathematical constants — π, e, the golden ratio, √2, Euler–Mascheroni, Apéry's and Catalan's constants, and more — each to 30 significant figures. Values were computed with arbitrary-precision arithmetic (mpmath), not transcribed, so every digit is correct. Each entry includes the symbol, an exact-as-stored high-precision value string, a double-precision approximation for quick use, a short definition, and the OEIS sequence for the digits. Distinct from `science/constants`, which covers *physical* constants. Useful for math tooling, high-precision computation references, and education.

## JSON

### Structure

```json
{
  "name": "Pi",
  "symbol": "π",
  "slug": "pi",
  "value": "3.14159265358979323846264338328",
  "approx": 3.141592653589793,
  "description": "Ratio of a circle's circumference to its diameter.",
  "oeis": "A000796"
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Constant name |
| `symbol` | string | Conventional symbol (`π`, `e`, `φ`, `γ`, …) |
| `slug` | string | Lowercase hyphenated identifier |
| `value` | string | Value to 30 significant figures, stored as a string to preserve all digits |
| `approx` | number | IEEE-754 double approximation for convenient numeric use |
| `description` | string | Short definition |
| `oeis` | string | OEIS identifier for the constant's decimal expansion |

### Notes

- `value` is a **string** because 30 significant figures exceed double precision; parse it with a big-decimal / arbitrary-precision library when you need the full precision. `approx` is provided for the common case where a double is enough.
- The last emitted digit is correctly rounded from higher internal precision.

## Sources

- Values computed with [mpmath](https://mpmath.org/) at 40-digit working precision.
- OEIS (Online Encyclopedia of Integer Sequences) for decimal-expansion identifiers.
