# common-ressources

A growing collection of structured JSON resources for recurring use in projects.

All data is stored as plain JSON — no images bundled, no runtime dependencies.  
PHP rendering examples are provided where visual output is useful (e.g. flags).  
Run `bash validate.sh` locally to verify JSON syntax and schema integrity.

---

## LGBTQ Resources

### Pride Flags

A JSON list of common and niche pride flags with colors, metadata, and type information.  
Includes horizontal, vertical, and diagonal stripe layouts.  
A PHP renderer is included for generating PNG previews.

[Info & Schema](/lgbtq/flags/Readme.MD) · [flags.json](/lgbtq/flags/flags.json) · [Preview](/lgbtq/flags/colortest.png)

### Pronouns

A structured reference for gender pronouns — traditional, neutral, and neopronouns.  
Includes full conjugation sets (subject, object, possessive, reflexive) and example sentences.

[Info & Schema](/lgbtq/pronouns/Readme.MD) · [pronouns.json](/lgbtq/pronouns/pronouns.json)

### MOTD Messages

Multilingual message-of-the-day snippets organized by pride theme.  
Languages: English, Spanish, German, French.

[motds.json](/lgbtq/motd/motds.json)

### LGBTQ+ Terminology

36-entry glossary covering gender, sexuality, identity, community, medical, and legal terms.  
Each entry includes definition, category, neopronoun flag, and related terms.

[Info & Schema](/lgbtq/terms/Readme.MD) · [terms.json](/lgbtq/terms/terms.json)

---

## Flags

### Country Flags

Simple stripe-based national flags using the same rendering schema as pride flags.  
Covers horizontal and vertical stripe designs for ~23 countries across Europe, Africa, and the Americas.  
Flags with complex heraldic emblems or crosses are not included.

[Info & Schema](/flags/countries/Readme.MD) · [flags.json](/flags/countries/flags.json)

### Fetish / Kink Flags

A small and growing collection of fetish community flags, including support for custom overlay elements (bones, cat ears, etc.).  
Work in progress — contributions welcome.

[Info & Status](/flags/fetish/Readme.MD) · [flags.json](/flags/fetish/flags.json)

---

## Colors

### CSS Named Colors

All 148 standard CSS named colors with hex values and RGB tuples.

[Info & Schema](/colors/Readme.MD) · [named.json](/colors/named.json)

### Color Palettes

16 curated themed palettes: pride flags, ANSI 16, Material Design, pastels, earth tones, cyberpunk neon, Dracula, Nord, Gruvbox, Catppuccin, Tokyo Night, and Solarized.  
Includes a PHP renderer (`colortest.php`) that outputs a swatch sheet PNG with hex labels.

[Info & Schema](/colors/Readme.MD) · [palettes.json](/colors/palettes.json) · [Preview](/colors/colortest.png)

### Terminal Color Themes

10 popular terminal themes (Dracula, Nord, Solarized, Monokai, Gruvbox, Catppuccin, Tokyo Night, One Dark, Material Dark) in a structured JSON format.  
Includes exports for Windows Terminal and Alacritty, and a PHP renderer that generates terminal-window-style preview cards.

[Info & Schema](/colors/terminal/Readme.MD) · [themes.json](/colors/terminal/themes.json) · [Preview](/colors/terminal/colortest.png)  
Exports: [Windows Terminal](/colors/terminal/export/windows-terminal.json) · [Alacritty](/colors/terminal/export/alacritty.toml)

---

## Social

### Platform Metadata

Structured metadata for 15+ social media and community platforms.  
Includes brand colors, federation status (ActivityPub / AT Protocol), handle formats, character limits, and content type support.  
Includes a PHP renderer (`brandsheet.php`) that generates a brand color reference sheet PNG.

[Info & Schema](/social/Readme.MD) · [platforms.json](/social/platforms.json) · [Preview](/social/brandsheet.png)

---

## Web Resources

### HTTP Status Codes

35+ HTTP response codes with names, descriptions, categories (1xx–5xx), cacheability, and RFC sources.  
Includes a PHP renderer (`reference.php`) that generates a color-coded reference sheet PNG grouped by category.

[Info & Schema](/web/http/Readme.MD) · [status-codes.json](/web/http/status-codes.json) · [Preview](/web/http/reference.png)

### HTTP Methods

All 9 standard HTTP methods with safe/idempotent/cacheable flags and RFC references.

[Info & Schema](/web/http/Readme.MD) · [methods.json](/web/http/methods.json)

### HTTP Headers

25+ common request and response headers with descriptions, direction, category, and usage examples.

[Info & Schema](/web/http/Readme.MD) · [headers.json](/web/http/headers.json)

### Regex Patterns

20 common validation patterns (email, URL, IPv4/6, UUID, slug, phone, dates, hex color, JWT, semver, and more).  
Each entry includes valid/invalid examples, category, and caveats.

[Info & Schema](/web/regex/Readme.MD) · [patterns.json](/web/regex/patterns.json)

### MIME Type Mappings

A large list of file extension to MIME type mappings.

[mappings.json](/web/mime/mappings.json)

---

## Fonts

### Web Font Stacks

15 CSS font stacks covering system fonts, Google Fonts pairings, and specialty categories (serif, sans-serif, monospace, display, handwriting).  
Each entry includes a ready-to-paste `css` value, category, and usage guidance.

[Info & Schema](/fonts/Readme.MD) · [stacks.json](/fonts/stacks.json)

---

## Validation

### validate.sh

Validates JSON syntax for all files and runs per-resource schema checks (required fields, value ranges, hex format).

```bash
bash validate.sh
```

### Playwright tests

`tests/previews.spec.js` validates all JSON schemas and generates PNG preview images via Playwright.

```bash
npm install
npx playwright test          # run all tests + regenerate all PNGs
npx playwright test --ui     # interactive mode
```

### Docker

A `docker/Dockerfile` based on the official Playwright image (includes Node.js + Chromium + PHP):

```bash
docker build -t cr-preview docker/
docker run --rm -v $PWD:/repo cr-preview npx playwright test
docker run --rm -v $PWD:/repo cr-preview node tests/generate-previews.js
```

### CI / Workflows

| Workflow | Trigger | Action |
|---|---|---|
| **Validate** | push + PR | JSON syntax + schema checks |
| **Generate Previews** | push to main (JSON/HTML changed) | Playwright screenshots → commit PNGs |
| **PR Previews** | pull request | Generate PNGs → commit to PR branch → post comment with image embeds |

Runs on self-hosted runners via both GitHub Actions and Gitea.
