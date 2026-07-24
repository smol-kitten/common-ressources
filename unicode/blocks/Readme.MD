# Unicode Blocks

Every named block in the Unicode Character Database (Unicode 17.0) — all 346 contiguous code-point ranges, from Basic Latin to the Supplementary Private Use Area. Each entry gives the block name, slug, start and end code points, the number of code points the range spans, a broad category, and a description. Useful for code-point routing, font-coverage tooling, script detection, and Unicode education.

## JSON

### Structure

```json
{
  "name": "Cyrillic",
  "slug": "cyrillic",
  "start": "U+0400",
  "end": "U+04FF",
  "count": 256,
  "category": "scripts",
  "description": "..."
}
```

### Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Official Unicode block name |
| `slug` | string | Lowercase hyphenated identifier derived from the name |
| `start` | string | First code point of the block, `U+XXXX` (uppercase hex, ≥4 digits) |
| `end` | string | Last code point of the block |
| `count` | integer | Number of code points in the range (`end − start + 1`; not all are assigned) |
| `category` | string | Broad grouping: `scripts`, `cjk`, `symbols`, `technical`, `emoji`, `punctuation`, or `control` |
| `description` | string | Human-readable note on the block's contents |

### Notes

- `start`, `end`, and `count` are sourced directly from the Unicode Character Database `Blocks.txt` and are authoritative; blocks are listed in ascending code-point order and never overlap (enforced by `tools/verify.py`).
- `count` is the size of the code-point *range*, not the number of *assigned* characters — most blocks contain reserved (unassigned) positions.
- `category` is an editorial grouping to aid browsing, not a Unicode property. A curated core of common blocks carries a hand-written `description`; the remaining blocks carry a concise generated description.

## Sources

- Unicode Character Database — [`Blocks.txt`](https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt) (Unicode 17.0).
