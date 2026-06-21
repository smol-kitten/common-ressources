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

Expected output:
```
=== Summary ===
  JSON files checked: 179
  JSON files valid:   179
  All checks passed
```

## Generate rice/dotfile configs

```bash
node rice/generate.js
```

Reads `colors/terminal/themes.json` (22 themes) and writes one config per theme per tool into `rice/<tool>/<slug>.<ext>`. Also emits `rice/index.html`.

Expected output ends with:
```
Done. Generated 331 files (configs + interactive index)
```

## Run the full test suite

```bash
npx playwright test --reporter=list
```

16 tests: 9 JSON integrity checks + 7 preview screenshot tests. All should pass in ~6 seconds.

```
  16 passed (5.7s)
```

## Run a single test / preview generator

```bash
# Regenerate one preview PNG (flags, palettes, themes, social, http, rice, pride):
node tests/generate-previews.js flags
node tests/generate-previews.js themes

# Run only integrity tests:
npx playwright test --grep "JSON data integrity" --reporter=list
```

## Smoke script

Run all three surfaces and confirm they pass:

```bash
#!/usr/bin/env bash
set -e
cd /home/user/common-ressources

echo "=== validate ===" && bash validate.sh | tail -3
echo "=== generate ===" && node rice/generate.js 2>&1 | tail -2
echo "=== tests ===" && npx playwright test --reporter=list 2>&1 | tail -3
```

## Key data files

| File | Contents |
|---|---|
| `colors/terminal/themes.json` | 22 terminal color schemes (source of truth for rice generator) |
| `colors/terminal/export/windows-terminal.json` | Derived from themes.json; regenerate with the Python snippet below if themes change |
| `flags/countries/flags.json` | 50+ country flags with SVG geometry type + colors |
| `geo/countries/countries.json` | 195 countries with ISO codes, capital, dial code, currency |
| `science/elements/elements.json` | 118 elements, IUPAC 2021 masses |
| `meta/corrections.json` | Audit log of factual corrections made to all JSON files |

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
- **windows-terminal.json is derived, not hand-edited**: it must be regenerated whenever `themes.json` changes. The Playwright test "Windows Terminal export matches themes count" will catch drift.
- **rice/generate.js overwrites 331 files silently**: safe to re-run at any time; idempotent.
- **validate.sh counts only `*.json` files** in checked directories — adding a new domain directory requires a new `check_json` line in `validate.sh`.
- **PNG preview files are committed**: `tests/generate-previews.js` writes PNGs to the repo root and domain dirs. These are intentional (shown in README and PR previews), not artifacts to gitignore.
- **Flag renderer has two implementations** that must stay in sync: `tests/generate-previews.js` (Node/SVG) and `flags/countries/colortest.php` (PHP/GD). Adding a new `type:` to `flags.json` requires updating both.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Error: browserType.launch: Executable doesn't exist` | Run `npx playwright install chromium` |
| `validate.sh: JSON files checked: N` (lower than expected) | New directory not registered in `validate.sh` — add `check_json` lines |
| `Windows Terminal export matches themes count` test fails | themes.json and windows-terminal.json are out of sync — run the Python re-sync snippet above |
| `node rice/generate.js` outputs fewer than 331 files | themes.json entry count × tool count changed — expected: 22 themes × 15 tools + 1 index = 331 |
