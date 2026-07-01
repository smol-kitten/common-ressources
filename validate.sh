#!/usr/bin/env bash
# JSON validation and schema checks for all resource files

set -euo pipefail

ERRORS=0
PASS=0

check_json() {
    local file="$1"
    if python3 -c "import json,sys; json.load(open('$file'))" 2>/dev/null; then
        echo "  OK  $file"
        PASS=$((PASS + 1))
    else
        echo " FAIL $file — invalid JSON"
        ERRORS=$((ERRORS + 1))
    fi
}

check_field() {
    local file="$1"
    local jq_expr="$2"
    local label="$3"
    local result
    result=$(jq -e "$jq_expr" "$file" 2>/dev/null) || true
    if [ -z "$result" ] || [ "$result" = "null" ] || [ "$result" = "[]" ]; then
        echo " WARN $file — $label"
    fi
}

require_fields() {
    local file="$1"
    shift
    for field in "$@"; do
        local missing
        missing=$(jq "[.[] | select(.$field == null or .$field == \"\")] | length" "$file" 2>/dev/null || echo "ERR")
        if [ "$missing" != "0" ] && [ "$missing" != "ERR" ]; then
            echo " WARN $file — $missing entries missing field '$field'"
        fi
    done
}

echo "=== Validating JSON syntax ==="

JSON_FILES=$(find . -name "*.json" ! -path "./.git/*" | sort)
JSON_COUNT=0
JSON_ERRORS=0

for f in $JSON_FILES; do
    JSON_COUNT=$((JSON_COUNT + 1))
    if python3 -c "import json,sys; json.load(open('$f'))" 2>/dev/null; then
        echo "  OK  $f"
        PASS=$((PASS + 1))
    else
        echo " FAIL $f — invalid JSON"
        ERRORS=$((ERRORS + 1))
        JSON_ERRORS=$((JSON_ERRORS + 1))
    fi
done

echo ""
echo "=== Schema checks ==="

# LGBTQ pride flags
if [ -f "lgbtq/flags/flags.json" ]; then
    echo "  Checking lgbtq/flags/flags.json..."
    COUNT=$(jq 'length' lgbtq/flags/flags.json)
    echo "    $COUNT flags"
    MISSING_COLORS=$(jq '[.[] | select(.colors == null or (.colors | length) == 0)] | length' lgbtq/flags/flags.json)
    [ "$MISSING_COLORS" != "0" ] && echo " WARN lgbtq/flags/flags.json — $MISSING_COLORS entries without colors"
    MISSING_TYPE=$(jq '[.[] | select(.type == null or .type == "")] | length' lgbtq/flags/flags.json)
    [ "$MISSING_TYPE" != "0" ] && echo " WARN lgbtq/flags/flags.json — $MISSING_TYPE entries without type"
fi

# Country flags
if [ -f "flags/countries/flags.json" ]; then
    echo "  Checking flags/countries/flags.json..."
    COUNT=$(jq 'length' flags/countries/flags.json)
    echo "    $COUNT country flags"
    MISSING_ISO=$(jq '[.[] | select(.iso == null or .iso == "")] | length' flags/countries/flags.json)
    [ "$MISSING_ISO" != "0" ] && echo " WARN flags/countries/flags.json — $MISSING_ISO entries without ISO code"
    MISSING_CONT=$(jq '[.[] | select(.continent == null or .continent == "")] | length' flags/countries/flags.json)
    [ "$MISSING_CONT" != "0" ] && echo " WARN flags/countries/flags.json — $MISSING_CONT entries without continent"
fi

# HTTP status codes
if [ -f "web/http/status-codes.json" ]; then
    echo "  Checking web/http/status-codes.json..."
    COUNT=$(jq 'length' web/http/status-codes.json)
    echo "    $COUNT status codes"
    INVALID=$(jq '[.[] | select(.code < 100 or .code > 599)] | length' web/http/status-codes.json)
    [ "$INVALID" != "0" ] && echo " WARN web/http/status-codes.json — $INVALID entries with out-of-range code"
    MISSING_CAT=$(jq '[.[] | select(.category == null or .category == "")] | length' web/http/status-codes.json)
    [ "$MISSING_CAT" != "0" ] && echo " WARN web/http/status-codes.json — $MISSING_CAT entries without category"
fi

# HTTP methods
if [ -f "web/http/methods.json" ]; then
    echo "  Checking web/http/methods.json..."
    COUNT=$(jq 'length' web/http/methods.json)
    echo "    $COUNT HTTP methods"
fi

# HTTP headers
if [ -f "web/http/headers.json" ]; then
    echo "  Checking web/http/headers.json..."
    COUNT=$(jq 'length' web/http/headers.json)
    echo "    $COUNT headers"
    INVALID_DIR=$(jq '[.[] | select(.direction != "request" and .direction != "response" and .direction != "both")] | length' web/http/headers.json)
    [ "$INVALID_DIR" != "0" ] && echo " WARN web/http/headers.json — $INVALID_DIR entries with unexpected direction value"
fi

# Pronouns
if [ -f "lgbtq/pronouns/pronouns.json" ]; then
    echo "  Checking lgbtq/pronouns/pronouns.json..."
    COUNT=$(jq 'length' lgbtq/pronouns/pronouns.json)
    echo "    $COUNT pronoun sets"
    MISSING=$(jq '[.[] | select(.subject == null or .object == null or .reflexive == null)] | length' lgbtq/pronouns/pronouns.json)
    [ "$MISSING" != "0" ] && echo " WARN lgbtq/pronouns/pronouns.json — $MISSING entries missing core fields"
fi

# Color palettes
if [ -f "colors/palettes.json" ]; then
    echo "  Checking colors/palettes.json..."
    COUNT=$(jq 'length' colors/palettes.json)
    echo "    $COUNT palettes"
    MISSING_SLUG=$(jq '[.[] | select(.slug == null or .slug == "")] | length' colors/palettes.json)
    [ "$MISSING_SLUG" != "0" ] && echo " WARN colors/palettes.json — $MISSING_SLUG palettes without slug"
    EMPTY=$(jq '[.[] | select((.colors | length) == 0)] | length' colors/palettes.json)
    [ "$EMPTY" != "0" ] && echo " WARN colors/palettes.json — $EMPTY palettes with no colors"
fi

# Named colors
if [ -f "colors/named.json" ]; then
    echo "  Checking colors/named.json..."
    COUNT=$(jq 'length' colors/named.json)
    echo "    $COUNT named colors"
    INVALID_HEX=$(jq '[.[] | select(.hex | test("^#[0-9A-Fa-f]{6}$") | not)] | length' colors/named.json)
    [ "$INVALID_HEX" != "0" ] && echo " WARN colors/named.json — $INVALID_HEX entries with invalid hex"
fi

# Social platforms
if [ -f "social/platforms.json" ]; then
    echo "  Checking social/platforms.json..."
    COUNT=$(jq 'length' social/platforms.json)
    echo "    $COUNT platforms"
    MISSING_SLUG=$(jq '[.[] | select(.slug == null or .slug == "")] | length' social/platforms.json)
    [ "$MISSING_SLUG" != "0" ] && echo " WARN social/platforms.json — $MISSING_SLUG platforms without slug"
fi

# MOTD messages
if [ -f "lgbtq/motd/motds.json" ]; then
    echo "  Checking lgbtq/motd/motds.json..."
    COUNT=$(jq 'length' lgbtq/motd/motds.json)
    echo "    $COUNT MOTD entries"
fi

# Terminal themes
if [ -f "colors/terminal/themes.json" ]; then
    echo "  Checking colors/terminal/themes.json..."
    COUNT=$(jq 'length' colors/terminal/themes.json)
    echo "    $COUNT terminal themes"
    REQUIRED_KEYS='["black","red","green","yellow","blue","magenta","cyan","white","bright-black","bright-red","bright-green","bright-yellow","bright-blue","bright-magenta","bright-cyan","bright-white"]'
    INCOMPLETE=$(jq --argjson req "$REQUIRED_KEYS" \
        '[.[] | select((.colors | keys) as $k | ($req | map(. as $r | $k | index($r) != null) | all) | not)] | length' \
        colors/terminal/themes.json)
    [ "$INCOMPLETE" != "0" ] && echo " WARN colors/terminal/themes.json — $INCOMPLETE themes missing color keys"
    MISSING_BG=$(jq '[.[] | select(.background == null or .background == "")] | length' colors/terminal/themes.json)
    [ "$MISSING_BG" != "0" ] && echo " WARN colors/terminal/themes.json — $MISSING_BG themes without background"
fi

# Windows Terminal export
if [ -f "colors/terminal/export/windows-terminal.json" ]; then
    echo "  Checking colors/terminal/export/windows-terminal.json..."
    COUNT=$(jq 'length' colors/terminal/export/windows-terminal.json)
    echo "    $COUNT Windows Terminal schemes"
fi

# LGBTQ terms
if [ -f "lgbtq/terms/terms.json" ]; then
    echo "  Checking lgbtq/terms/terms.json..."
    COUNT=$(jq 'length' lgbtq/terms/terms.json)
    echo "    $COUNT terms"
    VALID_CATS='["gender","sexuality","identity","community","medical","legal"]'
    BAD_CAT=$(jq --argjson v "$VALID_CATS" '[.[] | select(.category as $c | ($v | index($c)) == null)] | length' lgbtq/terms/terms.json)
    [ "$BAD_CAT" != "0" ] && echo " WARN lgbtq/terms/terms.json — $BAD_CAT entries with unexpected category"
fi

# Regex patterns
if [ -f "web/regex/patterns.json" ]; then
    echo "  Checking web/regex/patterns.json..."
    COUNT=$(jq 'length' web/regex/patterns.json)
    echo "    $COUNT regex patterns"
    MISSING_PAT=$(jq '[.[] | select(.pattern == null or .pattern == "")] | length' web/regex/patterns.json)
    [ "$MISSING_PAT" != "0" ] && echo " WARN web/regex/patterns.json — $MISSING_PAT entries without pattern"
    MISSING_SLUG=$(jq '[.[] | select(.slug == null or .slug == "")] | length' web/regex/patterns.json)
    [ "$MISSING_SLUG" != "0" ] && echo " WARN web/regex/patterns.json — $MISSING_SLUG entries without slug"
fi

# Font stacks
if [ -f "fonts/stacks.json" ]; then
    echo "  Checking fonts/stacks.json..."
    COUNT=$(jq 'length' fonts/stacks.json)
    echo "    $COUNT font stacks"
    MISSING_CSS=$(jq '[.[] | select(.css == null or .css == "")] | length' fonts/stacks.json)
    [ "$MISSING_CSS" != "0" ] && echo " WARN fonts/stacks.json — $MISSING_CSS entries without css value"
fi

# Winget packages
if [ -f "windows/winget/packages.json" ]; then
    echo "  Checking windows/winget/packages.json..."
    COUNT=$(jq 'length' windows/winget/packages.json)
    echo "    $COUNT winget packages"
    MISSING_ID=$(jq '[.[] | select(.id == null or .id == "")] | length' windows/winget/packages.json)
    [ "$MISSING_ID" != "0" ] && echo " WARN windows/winget/packages.json — $MISSING_ID entries missing field 'id'"
    MISSING_CAT=$(jq '[.[] | select(.category == null or .category == "")] | length' windows/winget/packages.json)
    [ "$MISSING_CAT" != "0" ] && echo " WARN windows/winget/packages.json — $MISSING_CAT entries missing field 'category'"
    MISSING_SLUG=$(jq '[.[] | select(.slug == null or .slug == "")] | length' windows/winget/packages.json)
    [ "$MISSING_SLUG" != "0" ] && echo " WARN windows/winget/packages.json — $MISSING_SLUG entries missing field 'slug'"
fi

# Registry tweaks
if [ -f "windows/registry/common-tweaks.json" ]; then
    echo "  Checking windows/registry/common-tweaks.json..."
    COUNT=$(jq 'length' windows/registry/common-tweaks.json)
    echo "    $COUNT registry tweaks"
    MISSING_KEY=$(jq '[.[] | select(.key == null or .key == "")] | length' windows/registry/common-tweaks.json)
    [ "$MISSING_KEY" != "0" ] && echo " WARN windows/registry/common-tweaks.json — $MISSING_KEY entries missing field 'key'"
    MISSING_TYPE=$(jq '[.[] | select(.["value-type"] == null or .["value-type"] == "")] | length' windows/registry/common-tweaks.json)
    [ "$MISSING_TYPE" != "0" ] && echo " WARN windows/registry/common-tweaks.json — $MISSING_TYPE entries missing field 'value-type'"
    VALID_TYPES='["REG_DWORD","REG_SZ","REG_BINARY","REG_QWORD"]'
    BAD_TYPE=$(jq --argjson v "$VALID_TYPES" '[.[] | select(.["value-type"] as $t | ($v | index($t)) == null)] | length' windows/registry/common-tweaks.json)
    [ "$BAD_TYPE" != "0" ] && echo " WARN windows/registry/common-tweaks.json — $BAD_TYPE entries with unexpected value-type"
fi

# AUR tools
if [ -f "linux/packages/aur-tools.json" ]; then
    echo "  Checking linux/packages/aur-tools.json..."
    COUNT=$(jq 'length' linux/packages/aur-tools.json)
    echo "    $COUNT AUR tools"
    MISSING_SLUG=$(jq '[.[] | select(.slug == null or .slug == "")] | length' linux/packages/aur-tools.json)
    [ "$MISSING_SLUG" != "0" ] && echo " WARN linux/packages/aur-tools.json — $MISSING_SLUG entries missing field 'slug'"
    MISSING_CAT=$(jq '[.[] | select(.category == null or .category == "")] | length' linux/packages/aur-tools.json)
    [ "$MISSING_CAT" != "0" ] && echo " WARN linux/packages/aur-tools.json — $MISSING_CAT entries missing field 'category'"
fi

# WM configs
if [ -f "linux/desktop/wm-configs.json" ]; then
    echo "  Checking linux/desktop/wm-configs.json..."
    COUNT=$(jq 'length' linux/desktop/wm-configs.json)
    echo "    $COUNT window manager configs"
    MISSING_PROTO=$(jq '[.[] | select(.protocol == null or .protocol == "")] | length' linux/desktop/wm-configs.json)
    [ "$MISSING_PROTO" != "0" ] && echo " WARN linux/desktop/wm-configs.json — $MISSING_PROTO entries missing field 'protocol'"
fi

# Pacman mirrors
if [ -f "linux/system/pacman-mirrors.json" ]; then
    echo "  Checking linux/system/pacman-mirrors.json..."
    COUNT=$(jq 'length' linux/system/pacman-mirrors.json)
    echo "    $COUNT pacman mirrors"
    MISSING_URL=$(jq '[.[] | select(.url == null or .url == "")] | length' linux/system/pacman-mirrors.json)
    [ "$MISSING_URL" != "0" ] && echo " WARN linux/system/pacman-mirrors.json — $MISSING_URL entries missing field 'url'"
    MISSING_CODE=$(jq '[.[] | select(.code == null or .code == "")] | length' linux/system/pacman-mirrors.json)
    [ "$MISSING_CODE" != "0" ] && echo " WARN linux/system/pacman-mirrors.json — $MISSING_CODE entries missing field 'code'"
fi

# Design
if [ -f "design/breakpoints/breakpoints.json" ]; then
    echo "  Checking design/breakpoints/breakpoints.json..."
    COUNT=$(jq 'length' design/breakpoints/breakpoints.json)
    echo "    $COUNT breakpoint systems"
    require_fields "design/breakpoints/breakpoints.json" slug system approach
fi

if [ -f "design/spacing/scales.json" ]; then
    echo "  Checking design/spacing/scales.json..."
    COUNT=$(jq 'length' design/spacing/scales.json)
    echo "    $COUNT spacing systems"
    require_fields "design/spacing/scales.json" slug system
fi

if [ -f "design/z-index/conventions.json" ]; then
    echo "  Checking design/z-index/conventions.json..."
    COUNT=$(jq 'length' design/z-index/conventions.json)
    echo "    $COUNT z-index layers"
    require_fields "design/z-index/conventions.json" slug name value
fi

# Database
if [ -f "database/sql-keywords/keywords.json" ]; then
    echo "  Checking database/sql-keywords/keywords.json..."
    COUNT=$(jq 'length' database/sql-keywords/keywords.json)
    echo "    $COUNT SQL keywords"
    require_fields "database/sql-keywords/keywords.json" slug keyword category
fi

if [ -f "database/engines/engines.json" ]; then
    echo "  Checking database/engines/engines.json..."
    COUNT=$(jq 'length' database/engines/engines.json)
    echo "    $COUNT database engines"
    require_fields "database/engines/engines.json" slug name type
fi

# Security
if [ -f "security/headers/security-headers.json" ]; then
    echo "  Checking security/headers/security-headers.json..."
    COUNT=$(jq 'length' security/headers/security-headers.json)
    echo "    $COUNT security headers"
    require_fields "security/headers/security-headers.json" slug name header
fi

if [ -f "security/tls/versions.json" ]; then
    echo "  Checking security/tls/versions.json..."
    COUNT=$(jq 'length' security/tls/versions.json)
    echo "    $COUNT TLS/SSL versions"
    require_fields "security/tls/versions.json" slug version status
fi

# DevOps
if [ -f "devops/docker/objects.json" ]; then
    echo "  Checking devops/docker/objects.json..."
    COUNT=$(jq 'length' devops/docker/objects.json)
    echo "    $COUNT Docker objects/instructions"
    require_fields "devops/docker/objects.json" slug name category
fi

if [ -f "devops/kubernetes/objects.json" ]; then
    echo "  Checking devops/kubernetes/objects.json..."
    COUNT=$(jq 'length' devops/kubernetes/objects.json)
    echo "    $COUNT Kubernetes resource kinds"
    require_fields "devops/kubernetes/objects.json" slug kind category
fi

if [ -f "devops/ci-platforms/platforms.json" ]; then
    echo "  Checking devops/ci-platforms/platforms.json..."
    COUNT=$(jq 'length' devops/ci-platforms/platforms.json)
    echo "    $COUNT CI platforms"
    require_fields "devops/ci-platforms/platforms.json" slug name config_file
fi

# Math
if [ -f "math/formulas/formulas.json" ]; then
    echo "  Checking math/formulas/formulas.json..."
    COUNT=$(jq 'length' math/formulas/formulas.json)
    echo "    $COUNT math formulas"
    require_fields "math/formulas/formulas.json" slug name category formula
fi

if [ -f "math/symbols/symbols.json" ]; then
    echo "  Checking math/symbols/symbols.json..."
    COUNT=$(jq 'length' math/symbols/symbols.json)
    echo "    $COUNT math symbols"
    require_fields "math/symbols/symbols.json" slug name symbol
fi

if [ -f "math/number-systems/bases.json" ]; then
    echo "  Checking math/number-systems/bases.json..."
    COUNT=$(jq 'length' math/number-systems/bases.json)
    echo "    $COUNT number systems"
    require_fields "math/number-systems/bases.json" slug name base
fi

# Airports
if [ -f "geo/airports/airports.json" ]; then
    echo "  Checking geo/airports/airports.json..."
    COUNT=$(jq 'length' geo/airports/airports.json)
    echo "    $COUNT airports"
    require_fields "geo/airports/airports.json" iata name city country_iso2
    MISSING_IATA=$(jq '[.[] | select(.iata | test("^[A-Z]{3}$") | not)] | length' geo/airports/airports.json)
    [ "$MISSING_IATA" != "0" ] && echo " WARN geo/airports/airports.json — $MISSING_IATA entries with invalid IATA code"
fi

# Finance
if [ -f "finance/forex/pairs.json" ]; then
    echo "  Checking finance/forex/pairs.json..."
    COUNT=$(jq 'length' finance/forex/pairs.json)
    echo "    $COUNT forex pairs"
    require_fields "finance/forex/pairs.json" slug pair base quote category
fi

if [ -f "finance/indices/indices.json" ]; then
    echo "  Checking finance/indices/indices.json..."
    COUNT=$(jq 'length' finance/indices/indices.json)
    echo "    $COUNT market indices"
    require_fields "finance/indices/indices.json" slug name ticker exchange
fi

# macOS
if [ -f "macos/defaults/commands.json" ]; then
    echo "  Checking macos/defaults/commands.json..."
    COUNT=$(jq 'length' macos/defaults/commands.json)
    echo "    $COUNT macOS defaults commands"
    require_fields "macos/defaults/commands.json" slug name category command
fi

if [ -f "macos/homebrew/packages.json" ]; then
    echo "  Checking macos/homebrew/packages.json..."
    COUNT=$(jq 'length' macos/homebrew/packages.json)
    echo "    $COUNT Homebrew packages"
    require_fields "macos/homebrew/packages.json" slug name category
fi

if [ -f "macos/keyboard/shortcuts.json" ]; then
    echo "  Checking macos/keyboard/shortcuts.json..."
    COUNT=$(jq 'length' macos/keyboard/shortcuts.json)
    echo "    $COUNT macOS shortcuts"
    require_fields "macos/keyboard/shortcuts.json" slug name category
fi

# Unicode
if [ -f "unicode/blocks/blocks.json" ]; then
    echo "  Checking unicode/blocks/blocks.json..."
    COUNT=$(jq 'length' unicode/blocks/blocks.json)
    echo "    $COUNT Unicode blocks"
    require_fields "unicode/blocks/blocks.json" slug name start end
fi

if [ -f "unicode/symbols/special-chars.json" ]; then
    echo "  Checking unicode/symbols/special-chars.json..."
    COUNT=$(jq 'length' unicode/symbols/special-chars.json)
    echo "    $COUNT special characters"
    require_fields "unicode/symbols/special-chars.json" slug name char codepoint
fi

# Typography
if [ -f "typography/type-scale/scales.json" ]; then
    echo "  Checking typography/type-scale/scales.json..."
    COUNT=$(jq 'length' typography/type-scale/scales.json)
    echo "    $COUNT type scales"
    require_fields "typography/type-scale/scales.json" slug name ratio
fi

if [ -f "typography/font-weights/weights.json" ]; then
    echo "  Checking typography/font-weights/weights.json..."
    COUNT=$(jq 'length' typography/font-weights/weights.json)
    echo "    $COUNT font weights"
    require_fields "typography/font-weights/weights.json" slug name numeric
fi

if [ -f "typography/line-height/guidelines.json" ]; then
    echo "  Checking typography/line-height/guidelines.json..."
    COUNT=$(jq 'length' typography/line-height/guidelines.json)
    echo "    $COUNT line-height guidelines"
    require_fields "typography/line-height/guidelines.json" slug name value
fi

# Keyboard shortcuts
if [ -f "keyboard/vscode/shortcuts.json" ]; then
    echo "  Checking keyboard/vscode/shortcuts.json..."
    COUNT=$(jq 'length' keyboard/vscode/shortcuts.json)
    echo "    $COUNT VS Code shortcuts"
    require_fields "keyboard/vscode/shortcuts.json" slug name category
fi

if [ -f "keyboard/browser/shortcuts.json" ]; then
    echo "  Checking keyboard/browser/shortcuts.json..."
    COUNT=$(jq 'length' keyboard/browser/shortcuts.json)
    echo "    $COUNT browser shortcuts"
    require_fields "keyboard/browser/shortcuts.json" slug name category
fi

if [ -f "keyboard/terminal-multiplexers/shortcuts.json" ]; then
    echo "  Checking keyboard/terminal-multiplexers/shortcuts.json..."
    COUNT=$(jq 'length' keyboard/terminal-multiplexers/shortcuts.json)
    echo "    $COUNT terminal multiplexer shortcuts"
    require_fields "keyboard/terminal-multiplexers/shortcuts.json" slug name
fi

# Networking
if [ -f "networking/subnets/cidr.json" ]; then
    echo "  Checking networking/subnets/cidr.json..."
    COUNT=$(jq 'length' networking/subnets/cidr.json)
    echo "    $COUNT CIDR ranges"
    require_fields "networking/subnets/cidr.json" cidr subnet_mask total_hosts
fi

if [ -f "networking/protocols/ip-protocols.json" ]; then
    echo "  Checking networking/protocols/ip-protocols.json..."
    COUNT=$(jq 'length' networking/protocols/ip-protocols.json)
    echo "    $COUNT IP protocols"
    require_fields "networking/protocols/ip-protocols.json" slug name number
fi

if [ -f "networking/devices/device-types.json" ]; then
    echo "  Checking networking/devices/device-types.json..."
    COUNT=$(jq 'length' networking/devices/device-types.json)
    echo "    $COUNT device types"
    require_fields "networking/devices/device-types.json" slug name osi_layer
fi

# Astronomy
if [ -f "astronomy/moons/moons.json" ]; then
    echo "  Checking astronomy/moons/moons.json..."
    COUNT=$(jq 'length' astronomy/moons/moons.json)
    echo "    $COUNT moons"
    require_fields "astronomy/moons/moons.json" slug name planet
fi

if [ -f "astronomy/stars/notable-stars.json" ]; then
    echo "  Checking astronomy/stars/notable-stars.json..."
    COUNT=$(jq 'length' astronomy/stars/notable-stars.json)
    echo "    $COUNT notable stars"
    require_fields "astronomy/stars/notable-stars.json" slug name constellation
fi

if [ -f "astronomy/constellations/constellations.json" ]; then
    echo "  Checking astronomy/constellations/constellations.json..."
    COUNT=$(jq 'length' astronomy/constellations/constellations.json)
    echo "    $COUNT constellations"
    require_fields "astronomy/constellations/constellations.json" slug name iau_abbreviation
fi

# Expanded datasets
if [ -f "geo/countries/countries.json" ]; then
    echo "  Checking geo/countries/countries.json..."
    COUNT=$(jq 'length' geo/countries/countries.json)
    echo "    $COUNT countries"
    [ "$COUNT" -lt 190 ] && echo " WARN geo/countries/countries.json — expected ~195 countries, got $COUNT"
    require_fields "geo/countries/countries.json" iso2 iso3 name capital continent
fi

if [ -f "science/elements/elements.json" ]; then
    echo "  Checking science/elements/elements.json..."
    COUNT=$(jq 'length' science/elements/elements.json)
    echo "    $COUNT elements"
    [ "$COUNT" -lt 118 ] && echo " WARN science/elements/elements.json — expected 118 elements, got $COUNT"
    require_fields "science/elements/elements.json" number symbol name mass
fi

if [ -f "geo/timezones/timezones.json" ]; then
    echo "  Checking geo/timezones/timezones.json..."
    COUNT=$(jq 'length' geo/timezones/timezones.json)
    echo "    $COUNT timezones"
    [ "$COUNT" -lt 90 ] && echo " WARN geo/timezones/timezones.json — expected ~100+ timezones, got $COUNT"
    require_fields "geo/timezones/timezones.json" iana utc_offset
fi

if [ -f "ai/models.json" ]; then
    echo "  Checking ai/models.json..."
    COUNT=$(jq 'length' ai/models.json)
    echo "    $COUNT AI models"
    require_fields "ai/models.json" slug name provider
fi

# Programming
if [ -f "programming/languages/languages.json" ]; then
    echo "  Checking programming/languages/languages.json..."
    COUNT=$(jq 'length' programming/languages/languages.json)
    echo "    $COUNT programming languages"
    require_fields "programming/languages/languages.json" slug name year
fi

if [ -f "programming/frameworks/frameworks.json" ]; then
    echo "  Checking programming/frameworks/frameworks.json..."
    COUNT=$(jq 'length' programming/frameworks/frameworks.json)
    echo "    $COUNT frameworks"
    require_fields "programming/frameworks/frameworks.json" slug name language type
fi

# Web browsers
if [ -f "web/browsers/browsers.json" ]; then
    echo "  Checking web/browsers/browsers.json..."
    COUNT=$(jq 'length' web/browsers/browsers.json)
    echo "    $COUNT browsers"
    require_fields "web/browsers/browsers.json" slug name engine vendor
fi

# History
if [ -f "history/eras/eras.json" ]; then
    echo "  Checking history/eras/eras.json..."
    COUNT=$(jq 'length' history/eras/eras.json)
    echo "    $COUNT historical eras"
    require_fields "history/eras/eras.json" slug name start_year
fi

if [ -f "history/inventions/inventions.json" ]; then
    echo "  Checking history/inventions/inventions.json..."
    COUNT=$(jq 'length' history/inventions/inventions.json)
    echo "    $COUNT inventions"
    require_fields "history/inventions/inventions.json" slug name year category
fi

# Space
if [ -f "space/missions/missions.json" ]; then
    echo "  Checking space/missions/missions.json..."
    COUNT=$(jq 'length' space/missions/missions.json)
    echo "    $COUNT space missions"
    require_fields "space/missions/missions.json" slug name agency year
    VALID_STATUS='["completed","active","failed","planned"]'
    BAD_STATUS=$(jq --argjson v "$VALID_STATUS" '[.[] | select(.status as $s | ($v | index($s)) == null)] | length' space/missions/missions.json 2>/dev/null || echo "0")
    [ "$BAD_STATUS" != "0" ] && echo " WARN space/missions/missions.json — $BAD_STATUS entries with unexpected status"
fi

if [ -f "space/dwarf-planets/dwarf-planets.json" ]; then
    echo "  Checking space/dwarf-planets/dwarf-planets.json..."
    COUNT=$(jq 'length' space/dwarf-planets/dwarf-planets.json)
    echo "    $COUNT dwarf planets"
    require_fields "space/dwarf-planets/dwarf-planets.json" slug name iau_status
fi

# Chemistry / Physics
if [ -f "chemistry/functional-groups/groups.json" ]; then
    echo "  Checking chemistry/functional-groups/groups.json..."
    COUNT=$(jq 'length' chemistry/functional-groups/groups.json)
    echo "    $COUNT functional groups"
    require_fields "chemistry/functional-groups/groups.json" slug name formula
fi

if [ -f "physics/laws/laws.json" ]; then
    echo "  Checking physics/laws/laws.json..."
    COUNT=$(jq 'length' physics/laws/laws.json)
    echo "    $COUNT physics laws/principles"
    require_fields "physics/laws/laws.json" slug name field
fi

# Medicine / Sports / Biology
if [ -f "medicine/specialties/specialties.json" ]; then
    echo "  Checking medicine/specialties/specialties.json..."
    COUNT=$(jq 'length' medicine/specialties/specialties.json)
    echo "    $COUNT medical specialties"
    require_fields "medicine/specialties/specialties.json" slug name type focus
fi

if [ -f "sports/sports.json" ]; then
    echo "  Checking sports/sports.json..."
    COUNT=$(jq 'length' sports/sports.json)
    echo "    $COUNT sports"
    require_fields "sports/sports.json" slug name category
fi

if [ -f "biology/taxonomy/taxonomy.json" ]; then
    echo "  Checking biology/taxonomy/taxonomy.json..."
    COUNT=$(jq 'length' biology/taxonomy/taxonomy.json)
    echo "    $COUNT taxonomic entries"
    require_fields "biology/taxonomy/taxonomy.json" slug name rank
    MISSING_DOMAIN=$(jq '[.[] | select(.rank != "domain" and (.domain == null or .domain == ""))] | length' biology/taxonomy/taxonomy.json 2>/dev/null || echo "0")
    [ "$MISSING_DOMAIN" != "0" ] && echo " WARN biology/taxonomy/taxonomy.json — $MISSING_DOMAIN non-domain entries missing 'domain' field"
fi

# Food / Music / Gaming expansions
if [ -f "food/cuisines/cuisines.json" ]; then
    echo "  Checking food/cuisines/cuisines.json..."
    COUNT=$(jq 'length' food/cuisines/cuisines.json)
    echo "    $COUNT cuisines"
    [ "$COUNT" -lt 30 ] && echo " WARN food/cuisines/cuisines.json — expected 50+ cuisines, got $COUNT"
    require_fields "food/cuisines/cuisines.json" slug name country continent
fi

if [ -f "food/nutrition/nutrients.json" ]; then
    echo "  Checking food/nutrition/nutrients.json..."
    COUNT=$(jq 'length' food/nutrition/nutrients.json)
    echo "    $COUNT nutrients"
    require_fields "food/nutrition/nutrients.json" slug name category
fi

if [ -f "music/genres/genres.json" ]; then
    echo "  Checking music/genres/genres.json..."
    COUNT=$(jq 'length' music/genres/genres.json)
    echo "    $COUNT music genres"
    require_fields "music/genres/genres.json" slug name origin_decade
fi

if [ -f "gaming/genres/genres.json" ]; then
    echo "  Checking gaming/genres/genres.json..."
    COUNT=$(jq 'length' gaming/genres/genres.json)
    echo "    $COUNT gaming genres"
    require_fields "gaming/genres/genres.json" slug name
fi

if [ -f "gaming/platforms/platforms.json" ]; then
    echo "  Checking gaming/platforms/platforms.json..."
    COUNT=$(jq 'length' gaming/platforms/platforms.json)
    echo "    $COUNT gaming platforms"
    require_fields "gaming/platforms/platforms.json" slug name manufacturer
fi

# Geo expansions
if [ -f "geo/mountains/peaks.json" ]; then
    echo "  Checking geo/mountains/peaks.json..."
    COUNT=$(jq 'length' geo/mountains/peaks.json)
    echo "    $COUNT peaks"
    require_fields "geo/mountains/peaks.json" slug name elevation_m country_iso2
    NEG_ELEV=$(jq '[.[] | select(.elevation_m <= 0)] | length' geo/mountains/peaks.json 2>/dev/null || echo "0")
    [ "$NEG_ELEV" != "0" ] && echo " WARN geo/mountains/peaks.json — $NEG_ELEV entries with non-positive elevation"
fi

if [ -f "geo/rivers/rivers.json" ]; then
    echo "  Checking geo/rivers/rivers.json..."
    COUNT=$(jq 'length' geo/rivers/rivers.json)
    echo "    $COUNT rivers"
    require_fields "geo/rivers/rivers.json" slug name length_km continent
fi

if [ -f "geo/oceans/oceans.json" ]; then
    echo "  Checking geo/oceans/oceans.json..."
    COUNT=$(jq 'length' geo/oceans/oceans.json)
    echo "    $COUNT oceans/seas"
    require_fields "geo/oceans/oceans.json" slug name type area_km2
fi

if [ -f "geo/currencies/currencies.json" ]; then
    echo "  Checking geo/currencies/currencies.json..."
    COUNT=$(jq 'length' geo/currencies/currencies.json)
    echo "    $COUNT currencies"
    [ "$COUNT" -lt 50 ] && echo " WARN geo/currencies/currencies.json — expected 80+ currencies, got $COUNT"
    require_fields "geo/currencies/currencies.json" code name symbol decimals
    DUPE_CODES=$(jq '[.[].code] | group_by(.) | map(select(length > 1)) | length' geo/currencies/currencies.json 2>/dev/null || echo "0")
    [ "$DUPE_CODES" != "0" ] && echo " WARN geo/currencies/currencies.json — $DUPE_CODES duplicate currency codes"
fi

echo ""
echo "=== Cross-reference checks ==="

# Check: ISO codes in flags/countries/flags.json exist in geo/countries/countries.json
if [ -f "flags/countries/flags.json" ] && [ -f "geo/countries/countries.json" ]; then
    echo "  Cross-checking flag ISO codes against countries..."
    ORPHAN_FLAGS=$(python3 - <<'PYEOF'
import json
flags = json.load(open('flags/countries/flags.json'))
countries = json.load(open('geo/countries/countries.json'))
country_iso2s = {c['iso2'] for c in countries}
missing = [f.get('iso', f.get('name', '?')) for f in flags if f.get('iso') and f['iso'] not in country_iso2s]
print(len(missing))
if missing: print('  Missing in countries.json:', ', '.join(missing[:10]))
PYEOF
)
    COUNT=$(echo "$ORPHAN_FLAGS" | head -1)
    [ "$COUNT" != "0" ] && echo " WARN $COUNT flag ISO code(s) not found in geo/countries/countries.json" && echo "$ORPHAN_FLAGS" | tail -1
    [ "$COUNT" = "0" ] && echo "  OK  All flag ISO codes found in countries.json"
fi

# Check: country_iso2 in geo/airports/airports.json exist in geo/countries/countries.json
if [ -f "geo/airports/airports.json" ] && [ -f "geo/countries/countries.json" ]; then
    echo "  Cross-checking airport country codes against countries..."
    ORPHAN_AIRPORTS=$(python3 - <<'PYEOF'
import json
airports = json.load(open('geo/airports/airports.json'))
countries = json.load(open('geo/countries/countries.json'))
country_iso2s = {c['iso2'] for c in countries}
missing = [a.get('iata','?') for a in airports if a.get('country_iso2') and a['country_iso2'] not in country_iso2s]
print(len(missing))
if missing: print('  Missing airports:', ', '.join(missing[:10]))
PYEOF
)
    COUNT=$(echo "$ORPHAN_AIRPORTS" | head -1)
    [ "$COUNT" != "0" ] && echo " WARN $COUNT airport(s) reference unknown country_iso2" && echo "$ORPHAN_AIRPORTS" | tail -1
    [ "$COUNT" = "0" ] && echo "  OK  All airport country_iso2 codes found in countries.json"
fi

# Check: currency_code in geo/countries/countries.json exist in geo/currencies/currencies.json
if [ -f "geo/countries/countries.json" ] && [ -f "geo/currencies/currencies.json" ]; then
    echo "  Cross-checking country currency codes against currencies..."
    ORPHAN_CURRENCIES=$(python3 - <<'PYEOF'
import json
countries = json.load(open('geo/countries/countries.json'))
currencies = json.load(open('geo/currencies/currencies.json'))
currency_codes = {c['code'] for c in currencies}
missing = [c['iso2'] + '/' + c.get('currency_code','?') for c in countries if c.get('currency_code') and c['currency_code'] not in currency_codes]
print(len(missing))
if missing: print('  Unknown currency codes:', ', '.join(missing[:10]))
PYEOF
)
    COUNT=$(echo "$ORPHAN_CURRENCIES" | head -1)
    [ "$COUNT" != "0" ] && echo " WARN $COUNT country/ies reference currency code not in geo/currencies/currencies.json" && echo "$ORPHAN_CURRENCIES" | tail -1
    [ "$COUNT" = "0" ] && echo "  OK  All country currency codes found in currencies.json"
fi

# Check: Windows Terminal export count matches themes count
if [ -f "colors/terminal/themes.json" ] && [ -f "colors/terminal/export/windows-terminal.json" ]; then
    echo "  Cross-checking Windows Terminal export count..."
    THEME_COUNT=$(jq 'length' colors/terminal/themes.json)
    WT_COUNT=$(jq 'length' colors/terminal/export/windows-terminal.json)
    if [ "$THEME_COUNT" != "$WT_COUNT" ]; then
        echo " WARN colors/terminal/export/windows-terminal.json has $WT_COUNT entries but themes.json has $THEME_COUNT — run: python3 scripts/build-manifest.js"
    else
        echo "  OK  Windows Terminal export count matches themes ($WT_COUNT)"
    fi
fi

# Check: country_iso2 in geo/mountains/peaks.json exist in geo/countries/countries.json
if [ -f "geo/mountains/peaks.json" ] && [ -f "geo/countries/countries.json" ]; then
    echo "  Cross-checking mountain country codes against countries..."
    ORPHAN_PEAKS=$(python3 - <<'PYEOF'
import json
peaks = json.load(open('geo/mountains/peaks.json'))
countries = json.load(open('geo/countries/countries.json'))
iso2s = {c['iso2'] for c in countries}
missing = [p.get('name','?') for p in peaks if p.get('country_iso2') and p['country_iso2'] not in iso2s]
print(len(missing))
if missing: print('  Unknown country_iso2:', ', '.join(missing[:10]))
PYEOF
)
    COUNT=$(echo "$ORPHAN_PEAKS" | head -1)
    [ "$COUNT" != "0" ] && echo " WARN $COUNT peak(s) reference unknown country_iso2" && echo "$ORPHAN_PEAKS" | tail -1
    [ "$COUNT" = "0" ] && echo "  OK  All peak country_iso2 codes found in countries.json"
fi

echo ""
echo "=== Summary ==="
echo "  JSON files checked: $JSON_COUNT"
echo "  JSON files valid:   $PASS"
if [ "$ERRORS" -gt 0 ]; then
    echo "  FAILED: $ERRORS error(s)"
    exit 1
else
    echo "  All checks passed"
fi
