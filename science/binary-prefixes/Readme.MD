# Binary Prefixes (IEC)

The 8 IEC 80000-13 binary prefixes — kibi (2¹⁰) through yobi (2⁸⁰) — used to express powers of two unambiguously (e.g. `KiB` = 1024 bytes, distinct from the SI `kB` = 1000 bytes). Each entry gives the prefix name, symbol, power-of-two exponent, exact value, and the SI decimal prefix it is commonly (mis)used in place of. Useful for storage/memory tooling, human-readable byte formatting, and clearing up KB-vs-KiB confusion.

## JSON

### Structure

```json
{
  "name": "kibi",
  "symbol": "Ki",
  "base2": 10,
  "value": "1024",
  "si_approx_prefix": "kilo",
  "si_approx_base10": 3
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Prefix name (IEC spelling) |
| `symbol` | string | Two-letter prefix symbol (always ends in `i`, e.g. `Ki`, `Mi`) |
| `base2` | integer | Power of two the prefix represents (e.g. `10` for kibi = 2¹⁰) |
| `value` | string | Exact value as a decimal string (`2^base2`) |
| `si_approx_prefix` | string | The SI decimal prefix the binary one is closest to and often confused with |
| `si_approx_base10` | integer | Power-of-ten exponent of that SI prefix (kibi≈kilo = 10³) |

### Notes

- Binary prefixes end in **-bi** (name) and **i** (symbol): kibi/Ki, mebi/Mi, gibi/Gi, tebi/Ti, pebi/Pi, exbi/Ei, zebi/Zi, yobi/Yi.
- Only these eight are standardised by IEC 80000-13. Prefixes for 2⁹⁰ / 2¹⁰⁰ (to parallel the 2022 SI ronna/quetta) have been *proposed* but are **not** standardised, so they are intentionally excluded here.
- `value` is a string to preserve exact large integers without floating-point loss.

## Sources

- IEC 80000-13:2008, *Quantities and units — Part 13: Information science and technology*.
