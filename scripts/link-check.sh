#!/usr/bin/env bash
# Checks HTTP status of all source URLs referenced in corrections.json and key data files.
# Run from repo root: bash scripts/link-check.sh
# Returns exit code 0 even on failures — reports only, does not block CI.

set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
SKIP=0
TIMEOUT=10

check_url() {
    local url="$1"
    local context="$2"

    # Skip non-HTTP URLs
    if [[ "$url" != http://* && "$url" != https://* ]]; then
        SKIP=$((SKIP + 1))
        return
    fi

    local status
    status=$(curl -o /dev/null -s -w "%{http_code}" \
        --max-time "$TIMEOUT" \
        --connect-timeout "$TIMEOUT" \
        -L \
        -H "User-Agent: Mozilla/5.0 (compatible; link-checker/1.0)" \
        "$url" 2>/dev/null || echo "000")

    if [[ "$status" =~ ^(200|201|203|204|301|302|303|307|308)$ ]]; then
        echo "  OK  [$status] $url"
        PASS=$((PASS + 1))
    elif [ "$status" = "000" ]; then
        echo " FAIL [timeout/conn] $url  ($context)"
        FAIL=$((FAIL + 1))
    else
        echo " FAIL [$status] $url  ($context)"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Link checker ==="
echo ""

# Extract URLs from corrections.json
if [ -f "meta/corrections.json" ]; then
    echo "--- meta/corrections.json (correction sources) ---"
    while IFS= read -r line; do
        url=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source',''))" 2>/dev/null || true)
        context=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file','') + ' / ' + d.get('entry',''))" 2>/dev/null || true)
        [ -n "$url" ] && check_url "$url" "$context"
    done < <(python3 -c "
import json
data = json.load(open('meta/corrections.json'))
for item in data.get('corrections', []) + data.get('no_action_items', []):
    print(json.dumps(item))
")
    echo ""
fi

# Check source fields in ai/models.json if present
if [ -f "ai/models.json" ]; then
    echo "--- ai/models.json (provider pages) ---"
    while IFS= read -r url; do
        [ -n "$url" ] && [ "$url" != "null" ] && check_url "$url" "ai/models.json"
    done < <(jq -r '.[].source_url? // empty' ai/models.json 2>/dev/null || true)
    echo ""
fi

# Check URLs in security/headers/security-headers.json
if [ -f "security/headers/security-headers.json" ]; then
    echo "--- security/headers/security-headers.json (spec sources) ---"
    while IFS= read -r url; do
        [ -n "$url" ] && [ "$url" != "null" ] && check_url "$url" "security headers"
    done < <(jq -r '.[].source? // empty' security/headers/security-headers.json 2>/dev/null || true)
    echo ""
fi

# Check URLs in devops/ci-platforms/platforms.json
if [ -f "devops/ci-platforms/platforms.json" ]; then
    echo "--- devops/ci-platforms/platforms.json ---"
    while IFS= read -r url; do
        [ -n "$url" ] && [ "$url" != "null" ] && check_url "$url" "ci-platforms"
    done < <(jq -r '.[].website? // empty' devops/ci-platforms/platforms.json 2>/dev/null || true)
    echo ""
fi

# Check URLs in programming/frameworks/frameworks.json
if [ -f "programming/frameworks/frameworks.json" ]; then
    echo "--- programming/frameworks/frameworks.json ---"
    while IFS= read -r url; do
        [ -n "$url" ] && [ "$url" != "null" ] && check_url "$url" "frameworks"
    done < <(jq -r '.[].website? // empty' programming/frameworks/frameworks.json 2>/dev/null || true)
    echo ""
fi

echo "=== Summary ==="
echo "  OK:      $PASS"
echo "  FAILED:  $FAIL"
echo "  SKIPPED: $SKIP (non-HTTP)"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo "  $FAIL link(s) failed — update corrections.json or data files as needed."
    echo "  (This script exits 0 to avoid blocking CI; failures are advisory.)"
fi
