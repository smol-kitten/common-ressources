# Contributing to common-ressources

This repo is a collection of structured-JSON reference datasets. Contributions that
add data, extend existing lists, or improve accuracy are welcome. A few conventions
keep the collection consistent and trustworthy.

## Before you push

Run the full quality gate — it's what CI runs:

```bash
make check
```

That runs, in order:

1. `bash validate.sh` — JSON syntax + per-dataset schema checks.
2. `python3 tools/verify.py` — semantic verification (duplicates, hex↔rgb integrity, cross-file referential checks, format/range sanity).
3. `python3 tools/check_corrections.py` — asserts every logged correction is still applied.
4. `tools/build_*.py --check` — asserts generated files (`geo/currencies/currencies.json`, `meta/catalog.json`, `meta/sources.json`, the README stats block) are up to date.

Everything is stdlib Python 3 + `jq` — no install step, no third-party dependencies.

## Adding or editing a dataset

- **Format.** One dataset per file, `2`-space indented JSON, UTF-8, trailing newline. Prefer a top-level array of objects with a consistent shape; use a keyed object only when the data is naturally a map (e.g. MIME mappings).
- **Stable keys.** Give each entry a stable identifier (`code`, `iso2`, `id`, `slug`, …). These must be unique — `verify.py` treats a repeat as an error.
- **Colors.** Store hex as `#RRGGBB`; if you also include an `rgb` tuple it must match the hex (checked automatically).
- **Regenerate derived files.** If you add a dataset, run `make build` so the catalog and README stats pick it up. Never hand-edit `meta/catalog.json` or the README `STATS` block.
- **Generated data.** `geo/currencies/currencies.json` is generated from `tools/build_currencies.py`. Edit the canonical table in the script, not the JSON.
- **Document it.** Add a short `Readme.MD` next to the data (used for the catalog description) and a section link in the top-level `README.md`.

## Provenance & accuracy

The disclaimer in the README is real: verify safety/compliance-critical values against
primary sources. To keep the collection honest:

- **Cite sources.** Add the dataset's authoritative source to `tools/build_sources.py` (it regenerates `meta/sources.json`). Classify it `standard` (ISO/IETF/IANA/IUPAC/Unicode/W3C/OWASP…), `official` (vendor/project docs), or `curated` (editorial).
- **Log corrections.** When you fix a factual value, add an entry to [`meta/corrections.json`](meta/corrections.json) with `file`, `entry`, `field`, `old_value`, `new_value`, `reason`, and `source`. `check_corrections.py` verifies the new value is actually present, so the log can't rot.
- **Don't invent data.** If you can't verify a field (an obscure Unicode range, a volatile price), leave it out rather than guess. Partial-but-correct beats complete-but-wrong.

## Finding gaps

`python3 tools/gap.py` reports where datasets fall short of their canonical universe
(e.g. ISO 4217 currencies, ISO 639-1 languages), which optional fields are sparsely
populated, and any cross-reference gaps. It's a good place to find something to work on.
