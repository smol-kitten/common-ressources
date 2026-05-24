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

## Rice

### Arch Linux Theme Configs

Per-theme configuration files for 10 popular terminal colour themes, targeting common Arch Linux ricing tools.  
Covers Alacritty, Kitty, Hyprland, Waybar, Rofi, Dunst, and WezTerm.  
Includes a one-liner `fetch.sh` install script and a Playwright terminal preview.

```bash
# Apply a theme in one line:
bash <(curl -fsSL https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice/fetch.sh) dracula
```

[Info & Schema](/rice/Readme.MD) · [generate.js](/rice/generate.js) · [fetch.sh](/rice/fetch.sh) · [Preview](/rice/preview.png)

Config dirs: [alacritty/](/rice/alacritty/) · [kitty/](/rice/kitty/) · [hyprland/](/rice/hyprland/) · [waybar/](/rice/waybar/) · [rofi/](/rice/rofi/) · [dunst/](/rice/dunst/) · [wezterm/](/rice/wezterm/)

Real terminal screenshots (Xvfb + xterm + scrot) are generated by `docker/Dockerfile.screenshots` and stored in [rice/screenshots/](/rice/screenshots/).

---

## Linux

### AUR Tools

Popular AUR helpers and build tools for Arch Linux.  
Covers yay, paru, trizen, pikaur, aurutils, pamac, makepkg, asp, pacaur, and bauerbill.  
Each entry includes install command, implementation language, approximate star count, and category (aur-helper, build-tool, pacman-wrapper).

[Info & Schema](/linux/packages/Readme.MD) · [aur-tools.json](/linux/packages/aur-tools.json)

### Window Manager Configs

Common Wayland and X11 window manager reference entries.  
Covers Hyprland, Sway, i3, bspwm, Openbox, Qtile, AwesomeWM, XMonad, River, and Niri.  
Includes type (tiling/floating/dynamic), display protocol, config format, config path, reload command, and feature list.

[Info & Schema](/linux/desktop/Readme.MD) · [wm-configs.json](/linux/desktop/wm-configs.json)

### Shell Prompt Themes

Zsh, Bash, and Fish prompt theme definitions.  
Covers Oh My Zsh themes (robbyrussell, agnoster, bira, ys), Powerlevel10k, Spaceship, Starship, Pure, Tide, Hydro, Bash Powerline, and Oh My Posh.  
Each entry includes shell, framework dependency, install command, preview colors, and feature list.

[Info & Schema](/linux/shell/Readme.MD) · [prompt-themes.json](/linux/shell/prompt-themes.json)

### Common Dotfile Paths

Standard XDG and dotfile paths for common Arch Linux tools.  
20 entries covering Alacritty, Kitty, Hyprland, Waybar, Rofi, Dunst, WezTerm, Zsh, Bash, Fish, Neovim, Helix, Git, SSH, GPG, GTK 3/4, Fontconfig, PipeWire, and systemd user units.  
Each entry includes config path, data path, cache path, and environment variable override.

[Info & Schema](/linux/dotfiles/Readme.MD) · [common-paths.json](/linux/dotfiles/common-paths.json)

### Pacman Mirrors

Arch Linux pacman mirror list with region metadata.  
22 mirrors across Europe (France, Germany, Denmark, Netherlands), Americas (US, Canada), and Asia/Pacific (China, Singapore, Japan, Taiwan, Australia).  
Each entry includes country code, continent, protocol, speed tier, and host notes.

[Info & Schema](/linux/system/Readme.MD) · [pacman-mirrors.json](/linux/system/pacman-mirrors.json)

---

## Windows

### Common Registry Tweaks

20 common Windows registry tweaks across performance, privacy, UI, Explorer, taskbar, and power categories.  
Includes dark mode, telemetry opt-out, classic context menu (Win11), file extensions, taskbar alignment, long path support, and more.  
Each entry includes full key path, value type (REG_DWORD/REG_SZ/etc.), current and default data, and restart requirement.

[Info & Schema](/windows/registry/Readme.MD) · [common-tweaks.json](/windows/registry/common-tweaks.json)

### Windows Terminal Profiles

11 Windows Terminal profile templates ready to paste into `settings.json`.  
Covers PowerShell 7, CMD, WSL Ubuntu 22.04/24.04, WSL Arch Linux, Git Bash, Cygwin, Azure Cloud Shell, Developer PowerShell for VS, Python REPL, and Node.js REPL.  
Each entry includes GUID, commandline, font face, font size, color scheme, and cursor shape.

[Info & Schema](/windows/terminal/Readme.MD) · [profiles.json](/windows/terminal/profiles.json)

### PowerShell Snippets

20 useful PowerShell one-liners covering system info, file operations, networking, processes, registry, WSL, and winget.  
Includes: get public IP, find large files, get disk usage, list running services, kill process by name, read/set registry values, list WSL distros, export WSL distro, install/upgrade winget packages, get open ports, get event log errors, and create symbolic links.

[Info & Schema](/windows/powershell/Readme.MD) · [snippets.json](/windows/powershell/snippets.json)

### Winget Packages

31 curated winget packages for fresh Windows installs.  
Covers browsers (Brave, Firefox, Chrome), terminals (Windows Terminal, WezTerm, Alacritty), editors (VSCode, Neovim, Notepad++), dev tools (Git, PowerShell 7, Python, Node.js, GitHub CLI, Docker), media (VLC, OBS, Spotify), utilities (PowerToys, 7-Zip, Everything, ShareX), communication (Discord, Signal), security (KeePassXC, Malwarebytes), and fonts (JetBrains Mono, Cascadia Code, Fira Code).  
Each entry includes winget ID, latest version, homepage, and free/open-source flags.

[Info & Schema](/windows/winget/Readme.MD) · [packages.json](/windows/winget/packages.json)

### WSL Distros

10 WSL distribution entries with install commands, package managers, init systems, and recommended use cases.  
Covers Ubuntu 22.04/24.04 LTS, Debian, Arch Linux (unofficial via ArchWSL), Kali Linux, openSUSE Tumbleweed, Fedora Remix, Alpine Linux, Oracle Linux 8, and SUSE Linux Enterprise.

[Info & Schema](/windows/wsl/Readme.MD) · [distros.json](/windows/wsl/distros.json)

---

## Geo

### Timezones

25 IANA timezone identifiers with UTC offsets, DST flags, region groupings, and example cities.  
Covers all major inhabited zones across Americas, Europe, Asia, Africa, and the Pacific.

[Info & Schema](/geo/timezones/Readme.MD) · [timezones.json](/geo/timezones/timezones.json)

### Currencies

25 major ISO 4217 currencies with symbol, decimal places, and issuing country.  
Handles zero-decimal currencies (JPY, KRW, IDR) and regional variations.

[Info & Schema](/geo/currencies/Readme.MD) · [currencies.json](/geo/currencies/currencies.json)

### Countries

25 countries with ISO 3166-1 alpha-2 and alpha-3 codes, capital city, continent, international dial code, currency code, and approximate population.

[Info & Schema](/geo/countries/Readme.MD) · [countries.json](/geo/countries/countries.json)

---

## Science

### Chemical Elements

30 elements from the periodic table — the first 20 by atomic number plus selected heavier elements (Cr, Fe, Ni, Cu, Zn, Br, Kr, Ag, Au, Pb).  
Each entry includes atomic number, symbol, atomic mass, group, period, category, and room-temperature phase.

[Info & Schema](/science/elements/Readme.MD) · [elements.json](/science/elements/elements.json)

### Units of Measurement

25 common SI and imperial units across length, mass, time, temperature, energy, power, pressure, and volume.  
Each entry includes a `to_si_factor` for straightforward programmatic conversion between compatible units.

[Info & Schema](/science/units/Readme.MD) · [units.json](/science/units/units.json)

---

## Gaming

### Platforms

18 gaming platforms spanning consoles, handhelds, hybrid devices, and PC — from the Sega Genesis (1989) to the Nintendo Switch 2 (2025).  
Includes manufacturer, release year, generation, type, and active/discontinued status.

[Info & Schema](/gaming/platforms/Readme.MD) · [platforms.json](/gaming/platforms/platforms.json)

---

## Music

### Genres

20 major music genres with typical BPM ranges, mood tags, geographic origin decade and region, and example artists.  
Covers rock, pop, hip-hop, electronic, jazz, classical, techno, house, ambient, reggae, metal, and more.

[Info & Schema](/music/genres/Readme.MD) · [genres.json](/music/genres/genres.json)

---

## Food

### World Cuisines

16 major world cuisines with key ingredients, staple dishes, primary cooking methods, and spice level.  
Covers Italian, Japanese, Indian, Mexican, Thai, Ethiopian, Korean, Peruvian, and more.

[Info & Schema](/food/cuisines/Readme.MD) · [cuisines.json](/food/cuisines/cuisines.json)

---

## Space

### Solar System Planets

All 8 planets of the Solar System with mass, radius, distance from the Sun, orbital and rotation periods, moon count, ring status, and average temperature.

[Info & Schema](/space/planets/Readme.MD) · [planets.json](/space/planets/planets.json)

---

## Networking

### Well-Known Ports

42 well-known TCP/UDP port assignments covering system ports and popular databases/services.  
Includes SSH (22), HTTP (80), HTTPS (443), databases (MySQL 3306, PostgreSQL 5432, Redis 6379, MongoDB 27017), VPNs (OpenVPN 1194, WireGuard 51820), and more.

[Info & Schema](/net/ports/Readme.MD) · [ports.json](/net/ports/ports.json)

---

## i18n

### Locales

25 BCP 47 locale codes with language name, language code, region, writing script, text direction (ltr/rtl), and native name.  
Covers Latin, Cyrillic, Arabic, Hebrew, CJK, Devanagari, and Hangul scripts.

[Info & Schema](/i18n/locales/Readme.MD) · [locales.json](/i18n/locales/locales.json)

---

## Biology

### Amino Acids

All 20 standard proteinogenic amino acids with single-letter code, three-letter code, molecular weight, charge, polarity, essentiality, side chain type, and structural category.

[Info & Schema](/bio/amino-acids/Readme.MD) · [amino-acids.json](/bio/amino-acids/amino-acids.json)

---

## Accessibility

### WCAG 2.1 Criteria

25 key WCAG 2.1 success criteria with conformance level (A/AA/AAA), POUR principle, guideline, title, and plain-language description.  
Covers the most commonly audited requirements across Perceivable, Operable, Understandable, and Robust principles.

[Info & Schema](/accessibility/wcag/Readme.MD) · [criteria.json](/accessibility/wcag/criteria.json)

---

## Dates

### Date Formats

17 common date and datetime format strings — ISO 8601, Unix timestamps, RFC 2822/7231, SQL, regional (US/EU/Japanese), and more.  
Each entry includes the format pattern, a concrete example, category, applicable systems, and usage notes.

[Info & Schema](/dates/formats/Readme.MD) · [formats.json](/dates/formats/formats.json)

---

## Finance

### Cryptocurrency

Top 20 cryptocurrencies by market cap rank with ticker, full name, decimal precision, consensus mechanism, protocol layer, and founding year.  
Includes BTC, ETH, SOL, XRP, DOGE, privacy coins (XMR), stablecoins (USDT, USDC), and DeFi tokens.

[Info & Schema](/finance/crypto/Readme.MD) · [crypto.json](/finance/crypto/crypto.json)

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
| **App Screenshots** | push to main (themes.json changed) or manual | Xvfb + xterm real terminal screenshots → commit PNGs |

Runs on self-hosted runners via both GitHub Actions and Gitea.
