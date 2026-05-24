#!/usr/bin/env bash
# Real Wayland terminal screenshots of rice themes.
# Each theme gets a matching aesthetic display style.
#
# Usage (inside the rice-wayland Docker image):
#   bash docker/rice-wayland.sh            # all themes, auto style
#   bash docker/rice-wayland.sh dracula    # single theme
#   STYLE=scp bash docker/rice-wayland.sh  # force a style for all
#
# Window geometry env vars (all optional):
#   WIN_W, WIN_H — terminal width/height in px (default 900x520)
#   WIN_X, WIN_Y — window position in px       (default 40,40)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/rice/screenshots"
THEMES_JSON="${REPO_ROOT}/colors/terminal/themes.json"
STYLES_DIR="${REPO_ROOT}/docker/styles"

# ── window geometry ───────────────────────────────────────────────────────────
WIN_W="${WIN_W:-900}"
WIN_H="${WIN_H:-520}"
WIN_X="${WIN_X:-40}"
WIN_Y="${WIN_Y:-40}"
OUTPUT_W="${OUTPUT_W:-980}"
OUTPUT_H="${OUTPUT_H:-600}"

# ── theme → display style mapping ────────────────────────────────────────────
declare -A THEME_STYLE=(
  [dracula]="cyberpunk"
  [nord]="science"
  [solarized-dark]="retro"
  [solarized-light]="macos"
  [monokai]="neofetch"
  [gruvbox-dark]="scp"
  [catppuccin-mocha]="anime"
  [tokyo-night]="cyberpunk"
  [one-dark]="minimal"
  [material-dark]="science"
)

style_for() {
  local slug="$1"
  # STYLE env override takes priority
  if [[ -n "${STYLE:-}" ]]; then
    echo "$STYLE"
    return
  fi
  echo "${THEME_STYLE[$slug]:-minimal}"
}

mkdir -p "$OUT_DIR"

# ── collect theme slugs ───────────────────────────────────────────────────────
ALL_SLUGS=()
while IFS= read -r slug; do
  ALL_SLUGS+=("$slug")
done < <(jq -r '.[].slug' "$THEMES_JSON")

if [[ $# -ge 1 ]]; then
  SLUGS=("$1")
else
  SLUGS=("${ALL_SLUGS[@]}")
fi

# ── generate rice configs ─────────────────────────────────────────────────────
echo "==> Generating rice configs..."
cd "$REPO_ROOT" && node rice/generate.js
echo "    Done."

# ── Wayland / Sway environment ────────────────────────────────────────────────
export XDG_RUNTIME_DIR=/tmp/xdg-runtime
export WAYLAND_DISPLAY=wayland-1
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

SWAY_CONF="$(mktemp /tmp/sway-XXXXXX.conf)"
cat > "$SWAY_CONF" <<SWAY_EOF
output HEADLESS-1 resolution ${OUTPUT_W}x${OUTPUT_H} position 0,0
input type:keyboard xkb_layout us
default_border none
default_floating_border none
gaps inner 0
gaps outer 0
for_window [app_id="foot"] floating enable, \
    resize set ${WIN_W} ${WIN_H}, \
    move position ${WIN_X} ${WIN_Y}
SWAY_EOF

echo "==> Starting Sway headless (${OUTPUT_W}x${OUTPUT_H})..."
WLR_BACKENDS=headless WLR_RENDERER=pixman \
  sway --config "$SWAY_CONF" 2>/tmp/sway.log &
SWAY_PID=$!

for i in $(seq 1 40); do
  swaymsg -t get_version >/dev/null 2>&1 && break
  sleep 0.1
done

if ! swaymsg -t get_version >/dev/null 2>&1; then
  echo "ERROR: Sway did not start." >&2
  cat /tmp/sway.log >&2
  exit 1
fi
echo "    Sway ready."

# ── foot config generator ─────────────────────────────────────────────────────
generate_foot_config() {
  local slug="$1"
  local cfg="/tmp/foot-${slug}.ini"
  local theme
  theme=$(jq -r ".[] | select(.slug == \"$slug\")" "$THEMES_JSON")

  strip() { printf '%s' "$1" | jq -r "$2" | tr -d '#'; }

  local bg fg c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15
  bg=$(strip  "$theme" '.background')
  fg=$(strip  "$theme" '.foreground')
  c0=$(strip  "$theme" '.colors.black')
  c1=$(strip  "$theme" '.colors.red')
  c2=$(strip  "$theme" '.colors.green')
  c3=$(strip  "$theme" '.colors.yellow')
  c4=$(strip  "$theme" '.colors.blue')
  c5=$(strip  "$theme" '.colors.magenta')
  c6=$(strip  "$theme" '.colors.cyan')
  c7=$(strip  "$theme" '.colors.white')
  c8=$(strip  "$theme" '.colors["bright-black"]')
  c9=$(strip  "$theme" '.colors["bright-red"]')
  c10=$(strip "$theme" '.colors["bright-green"]')
  c11=$(strip "$theme" '.colors["bright-yellow"]')
  c12=$(strip "$theme" '.colors["bright-blue"]')
  c13=$(strip "$theme" '.colors["bright-magenta"]')
  c14=$(strip "$theme" '.colors["bright-cyan"]')
  c15=$(strip "$theme" '.colors["bright-white"]')

  cat > "$cfg" <<FOOT_EOF
[main]
font=JetBrains Mono:size=13
pad=18x18 center
[colors]
background=${bg}
foreground=${fg}
regular0=${c0}
regular1=${c1}
regular2=${c2}
regular3=${c3}
regular4=${c4}
regular5=${c5}
regular6=${c6}
regular7=${c7}
bright0=${c8}
bright1=${c9}
bright2=${c10}
bright3=${c11}
bright4=${c12}
bright5=${c13}
bright6=${c14}
bright7=${c15}
FOOT_EOF
  echo "$cfg"
}

# ── main loop ─────────────────────────────────────────────────────────────────
OK=0; FAIL=0

for SLUG in "${SLUGS[@]}"; do
  THEME_NAME=$(jq -r ".[] | select(.slug == \"$SLUG\") | .name" "$THEMES_JSON")
  STYLE_NAME=$(style_for "$SLUG")
  STYLE_SCRIPT="${STYLES_DIR}/${STYLE_NAME}.sh"

  echo ""
  echo "==> $SLUG  [style: $STYLE_NAME]"

  if [[ -z "$THEME_NAME" || "$THEME_NAME" == "null" ]]; then
    echo "  SKIP — slug not found in themes.json"
    FAIL=$((FAIL + 1)); continue
  fi
  if [[ ! -f "$STYLE_SCRIPT" ]]; then
    echo "  WARN — style script not found: $STYLE_SCRIPT, falling back to minimal"
    STYLE_SCRIPT="${STYLES_DIR}/minimal.sh"
  fi

  FOOT_CONF=$(generate_foot_config "$SLUG")

  foot \
    --config="$FOOT_CONF" \
    --app-id=foot \
    -- bash "$STYLE_SCRIPT" "$THEME_NAME" "$SLUG" &
  FOOT_PID=$!

  APPEARED=0
  for i in $(seq 1 50); do
    if swaymsg -t get_tree 2>/dev/null \
        | jq -e '.. | objects | select(.app_id == "foot")' >/dev/null 2>&1; then
      APPEARED=1; break
    fi
    sleep 0.1
  done

  if [[ $APPEARED -eq 0 ]]; then
    echo "  FAIL — foot window did not appear"
    kill "$FOOT_PID" 2>/dev/null || true
    FAIL=$((FAIL + 1)); continue
  fi

  sleep 0.4  # let the style script finish printing

  GEOM=$(swaymsg -t get_tree 2>/dev/null \
    | jq -r '.. | objects | select(.app_id == "foot") | .rect
              | "\(.x),\(.y) \(.width)x\(.height)"' \
    | head -1)

  OUT="${OUT_DIR}/${SLUG}.png"

  if [[ -n "$GEOM" && "$GEOM" != "null" ]]; then
    grim -o HEADLESS-1 -g "$GEOM" "$OUT"
    echo "  OK  $OUT  [$GEOM]"
  else
    FULL="/tmp/full-${SLUG}.png"
    grim -o HEADLESS-1 "$FULL"
    convert "$FULL" -crop "${WIN_W}x${WIN_H}+${WIN_X}+${WIN_Y}" +repage "$OUT"
    echo "  OK  $OUT  (fallback crop)"
    rm -f "$FULL"
  fi

  OK=$((OK + 1))
  kill "$FOOT_PID" 2>/dev/null || true
  wait "$FOOT_PID" 2>/dev/null || true
  sleep 0.2
done

# ── cleanup ───────────────────────────────────────────────────────────────────
kill "$SWAY_PID" 2>/dev/null || true
wait "$SWAY_PID" 2>/dev/null || true
rm -f "$SWAY_CONF" /tmp/foot-*.ini

echo ""
echo "Done: ${OK} saved, ${FAIL} failed."
ls -lh "${OUT_DIR}"/*.png 2>/dev/null || echo "(no output files)"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
