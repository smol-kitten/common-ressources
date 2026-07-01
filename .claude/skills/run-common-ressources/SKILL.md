---
name: run-common-ressources
description: Run, validate, test, and generate output for the common-ressources repo. Use when asked to run, build, test, validate, generate, or screenshot this project.
---

# common-ressources

A curated JSON reference library with a Hyprland rice generator. No server or GUI — three runnable surfaces: a JSON validator, a config file generator, and a Playwright test suite.

All commands run from the repo root (`/home/user/common-ressources`).

## Prerequisites

```bash
node --version   # v18+ required
jq --version     # for ad-hoc JSON queries
npx playwright install chromium   # one-time; needed for tests and previews
```

## Validate all JSON files

```bash
bash validate.sh
```

Expected output ends with:
```
=== Summary ===
  JSON files checked: NNN
  JSON files valid:   NNN
  All checks passed
```

Also runs cross-reference checks (flag ISO codes vs countries, airport country codes, currency consistency, Windows Terminal export count sync).

## Generate rice/dotfile configs

```bash
node rice/generate.js
```

Reads `colors/terminal/themes.json` (22 themes) and writes one config per theme per tool into `rice/<tool>/<slug>.<ext>`. Also emits `rice/index.html`.

Expected output ends with:
```
Done. Generated 331 files (configs + interactive index)
```

## Build the manifest

```bash
node scripts/build-manifest.js
```

Regenerates `meta/manifest.json` — the machine-readable catalog of all JSON data files with entry counts and field lists.

## Link checker

```bash
bash scripts/link-check.sh
```

Checks HTTP status of all source URLs in `meta/corrections.json` and key data files. Exits 0 (advisory only, never blocks CI).

## Run the full test suite

```bash
npx playwright test --reporter=list
```

16 tests: 9 JSON integrity checks + 7 preview screenshot tests. All should pass in ~6 seconds.

## Run a single preview / test

```bash
# Regenerate one preview PNG:
node tests/generate-previews.js flags
node tests/generate-previews.js themes

# Run only integrity tests:
npx playwright test --grep "JSON data integrity" --reporter=list
```

## Smoke script

```bash
#!/usr/bin/env bash
set -e
cd /home/user/common-ressources

echo "=== validate ===" && bash validate.sh | tail -4
echo "=== generate ===" && node rice/generate.js 2>&1 | tail -2
echo "=== manifest ===" && node scripts/build-manifest.js
echo "=== tests ===" && npx playwright test --reporter=list 2>&1 | tail -3
```

## Key data files

| File | Contents |
|---|---|
| `colors/terminal/themes.json` | 22 terminal color schemes (source of truth for rice generator) |
| `colors/terminal/export/windows-terminal.json` | Derived — regenerate with `python3` snippet if themes change |
| `flags/countries/flags.json` | 50+ country flags with SVG geometry type + colors |
| `geo/countries/countries.json` | 195 countries with ISO codes, capital, dial code, currency |
| `science/elements/elements.json` | 118 elements, IUPAC 2021 masses |
| `meta/corrections.json` | Audit log of factual corrections |
| `meta/sources.json` | Authoritative sources per domain with update schedules |
| `meta/manifest.json` | Machine-readable catalog of all JSON files (auto-generated) |

### Re-sync windows-terminal.json after themes change

```bash
python3 - <<'EOF'
import json
with open('colors/terminal/themes.json') as f: themes = json.load(f)
out = [{"name":t['name'],"background":t['background'],"foreground":t['foreground'],
        "cursorColor":t['cursor'],"selectionBackground":t['selection-background'],
        "black":t['colors']['black'],"red":t['colors']['red'],"green":t['colors']['green'],
        "yellow":t['colors']['yellow'],"blue":t['colors']['blue'],
        "purple":t['colors']['magenta'],"cyan":t['colors']['cyan'],"white":t['colors']['white'],
        "brightBlack":t['colors']['bright-black'],"brightRed":t['colors']['bright-red'],
        "brightGreen":t['colors']['bright-green'],"brightYellow":t['colors']['bright-yellow'],
        "brightBlue":t['colors']['bright-blue'],"brightPurple":t['colors']['bright-magenta'],
        "brightCyan":t['colors']['bright-cyan'],"brightWhite":t['colors']['bright-white']} for t in themes]
with open('colors/terminal/export/windows-terminal.json','w') as f: json.dump(out,f,indent=2); f.write('\n')
print(f"Written {len(out)} themes")
EOF
```

## Gotchas

- **Playwright must be installed separately**: `npm install` does not install browser binaries. Run `npx playwright install chromium` once per machine/container before tests or preview generation.
- **windows-terminal.json is derived, not hand-edited**: regenerate whenever `themes.json` changes. The Playwright test "Windows Terminal export matches themes count" will catch drift.
- **validate.sh runs cross-reference checks**: airport country_iso2 codes, flag ISO codes, and currency codes are verified against `geo/countries/countries.json`. Hong Kong (HK) produces a known warning since it has its own ISO code but is not a sovereign country in countries.json.
- **rice/generate.js overwrites 331 files silently**: idempotent, safe to re-run.
- **meta/manifest.json is auto-generated**: run `node scripts/build-manifest.js` to rebuild after adding new JSON files.
- **Flag renderer has two implementations**: `tests/generate-previews.js` (Node/SVG) and `flags/countries/colortest.php` (PHP/GD). Adding a new `type:` requires updating both.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Error: browserType.launch: Executable doesn't exist` | Run `npx playwright install chromium` |
| `Windows Terminal export matches themes count` test fails | Run the python3 re-sync snippet above |
| Cross-ref warning about HK/Hong Kong airport | Known — HK is a valid ISO 3166-1 alpha-2 code but not in countries.json |
| `node scripts/build-manifest.js` fails with import error | Script uses ES modules; requires Node 18+ |
