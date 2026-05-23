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

### MIME Type Mappings

A large list of file extension to MIME type mappings.

[mappings.json](/web/mime/mappings.json)

---

## Validation

A `validate.sh` script at the root validates JSON syntax and checks required fields for each resource type.

```bash
bash validate.sh
```

CI runs automatically on push and pull requests via GitHub Actions and Gitea workflows.
