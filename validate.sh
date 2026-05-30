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
