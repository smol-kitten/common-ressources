# tools/

Dependency-free (stdlib Python 3 + `jq`) tooling for keeping the datasets correct,
complete, discoverable, and sourced. Everything is deterministic and CI-friendly.

Run the whole gate with `make check` (or the individual commands below).

## Verification & analysis

| Command | Purpose |
|---|---|
| `python3 tools/verify.py` | **Semantic verification** beyond JSON syntax: strict-ID / full-row duplicate detection, hex↔rgb color integrity, and cross-file referential checks (country→currency, language→script, timezone/element/planet/HTTP sanity). Exit 1 on errors; `--warn-as-error` to also fail on warnings; `--json` writes `tools/reports/verify.json`. |
| `python3 tools/gap.py` | **Coverage & completeness gap analysis**: entry count vs canonical universe sizes (118 elements, 88 constellations, ~180 ISO 4217 currencies…), sparsely-populated optional fields, and cross-reference gaps. `--json`, `--top N`. |
| `python3 tools/check_corrections.py` | **Fact-check log integrity**: asserts every correction in `meta/corrections.json` is actually applied in the data (catches regressions / mis-logged fixes). |
| `bash validate.sh` | Original JSON syntax + per-dataset schema checks (unchanged). |

## Generators (auto-builds)

Each generator is idempotent and supports `--check` (exit 1 if the committed output
is stale) so CI can assert the tree is current.

| Command | Output | Source of truth |
|---|---|---|
| `python3 tools/build_currencies.py` | `geo/currencies/currencies.json` | canonical ISO 4217 table in the script; issuing country derived from `geo/countries/countries.json` |
| `python3 tools/build_catalog.py` | `meta/catalog.json` | walks every dataset — path, category, entry count, fields, description, provenance flag |
| `python3 tools/build_sources.py` | `meta/sources.json` | curated authoritative-source map (`--coverage` reports undocumented datasets) |
| `python3 tools/build_readme_stats.py` | `README.md` stats block | dataset/entry/category counts + per-category table, between the `STATS` markers |

## Conventions

- **No third-party dependencies.** CI runs on a self-hosted runner with `python3` + `jq` only.
- **Deterministic output.** Generators sort keys / entries so diffs are minimal and `--check` is stable.
- **Provenance classes** (`meta/sources.json`): `standard` (ISO/IETF/IANA/IUPAC/Unicode/W3C/OWASP…), `official` (vendor/project docs), `curated` (editorial, no single authority).
- Factual changes to data are logged in [`meta/corrections.json`](../meta/corrections.json) with old/new value, reason, and source.
