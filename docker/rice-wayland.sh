#!/usr/bin/env bash
# Real Wayland terminal screenshots of rice themes.
# Starts Sway headless, launches a themed foot terminal, screenshots with grim.
# Saves output to rice/screenshots/<slug>.png.
#
# Usage (inside the rice-wayland Docker image):
#   bash docker/rice-wayland.sh          # all themes
#   bash docker/rice-wayland.sh dracula  # single theme

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/rice/screenshots"
THEMES_JSON="${REPO_ROOT}/colors/terminal/themes.json"

# ── window geometry (override via env) ────────────────────────────────────────
WIN_W="${WIN_W:-900}"
WIN_H="${WIN_H:-520}"
WIN_X="${WIN_X:-40}"
WIN_Y="${WIN_Y:-40}"
OUTPUT_W="${OUTPUT_W:-980}"
OUTPUT_H="${OUTPUT_H:-600}"

mkdir -p "$OUT_DIR"

# ── collect theme slugs ────────────────────────────────────────────────────────

ALL_SLUGS=()
while IFS= read -r slug; do
  ALL_SLUGS+=("$slug")
done < <(jq -r '.[].slug' "$THEMES_JSON")

if [[ $# -ge 1 ]]; then
  SLUGS=("$1")
else
  SLUGS=("${ALL_SLUGS[@]}")
fi

# ── generate rice configs (alacritty, kitty, etc.) ───────────────────────────

echo "==> Generating rice configs..."
cd "$REPO_ROOT" && node rice/generate.js
echo "    Done."

# ── Wayland / Sway environment ────────────────────────────────────────────────

export XDG_RUNTIME_DIR=/tmp/xdg-runtime
export WAYLAND_DISPLAY=wayland-1
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Sway headless config: one virtual output, floating layout, no decorations
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

echo "==> Starting Sway headless..."
WLR_BACKENDS=headless WLR_RENDERER=pixman \
  sway --config "$SWAY_CONF" 2>/tmp/sway.log &
SWAY_PID=$!

# Wait for compositor to be ready
for i in $(seq 1 30); do
  if swaymsg -t get_version >/dev/null 2>&1; then
    echo "    Sway ready (${i}00ms)."
    break
  fi
  sleep 0.1
done

if ! swaymsg -t get_version >/dev/null 2>&1; then
  echo "ERROR: Sway did not start. Log:" >&2
  cat /tmp/sway.log >&2
  exit 1
fi

# ── display script (runs inside foot) ────────────────────────────────────────

DISPLAY_SCRIPT="$(mktemp /tmp/display-XXXXXX.sh)"
chmod +x "$DISPLAY_SCRIPT"
cat > "$DISPLAY_SCRIPT" <<'DISPLAY_EOF'
#!/usr/bin/env bash
THEME_NAME="${1:-theme}"

clear
printf "\n"
printf "  \033[1m%-30s\033[0m\n" "$THEME_NAME"
printf "\n"

# 8 normal ANSI colors
printf "  "
for i in 0 1 2 3 4 5 6 7; do
  printf "\033[4${i}m    \033[0m"
done
printf "\n"

# 8 bright ANSI colors
printf "  "
for i in 0 1 2 3 4 5 6 7; do
  printf "\033[10${i}m    \033[0m"
done
printf "\n\n"

# Fake shell session
printf "  \033[32;1muser\033[0m\033[37m@arch\033[0m:\033[34;1m~/dotfiles\033[0m \033[32;1m❯\033[0m ls\n"
printf "  \033[34malacritty\033[0m  \033[34mdunst\033[0m  \033[34mhyprland\033[0m"
printf "  \033[34mkitty\033[0m  \033[34mrofi\033[0m  \033[34mwaybar\033[0m  \033[34mwezterm\033[0m\n"
printf "\n"
printf "  \033[32;1muser\033[0m\033[37m@arch\033[0m:\033[34;1m~/dotfiles\033[0m \033[32;1m❯\033[0m \033[90m█\033[0m\n"
printf "\n"
sleep 999
DISPLAY_EOF

# ── foot config generator ─────────────────────────────────────────────────────

generate_foot_config() {
  local slug="$1"
  local cfg="/tmp/foot-${slug}.ini"

  local theme
  theme=$(jq -r ".[] | select(.slug == \"$slug\")" "$THEMES_JSON")

  local bg fg c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15
  bg=$(printf '%s' "$theme"  | jq -r '.background'              | tr -d '#')
  fg=$(printf '%s' "$theme"  | jq -r '.foreground'              | tr -d '#')
  c0=$(printf '%s' "$theme"  | jq -r '.colors.black'            | tr -d '#')
  c1=$(printf '%s' "$theme"  | jq -r '.colors.red'              | tr -d '#')
  c2=$(printf '%s' "$theme"  | jq -r '.colors.green'            | tr -d '#')
  c3=$(printf '%s' "$theme"  | jq -r '.colors.yellow'           | tr -d '#')
  c4=$(printf '%s' "$theme"  | jq -r '.colors.blue'             | tr -d '#')
  c5=$(printf '%s' "$theme"  | jq -r '.colors.magenta'          | tr -d '#')
  c6=$(printf '%s' "$theme"  | jq -r '.colors.cyan'             | tr -d '#')
  c7=$(printf '%s' "$theme"  | jq -r '.colors.white'            | tr -d '#')
  c8=$(printf '%s' "$theme"  | jq -r '.colors["bright-black"]'  | tr -d '#')
  c9=$(printf '%s' "$theme"  | jq -r '.colors["bright-red"]'    | tr -d '#')
  c10=$(printf '%s' "$theme" | jq -r '.colors["bright-green"]'  | tr -d '#')
  c11=$(printf '%s' "$theme" | jq -r '.colors["bright-yellow"]' | tr -d '#')
  c12=$(printf '%s' "$theme" | jq -r '.colors["bright-blue"]'   | tr -d '#')
  c13=$(printf '%s' "$theme" | jq -r '.colors["bright-magenta"]'| tr -d '#')
  c14=$(printf '%s' "$theme" | jq -r '.colors["bright-cyan"]'   | tr -d '#')
  c15=$(printf '%s' "$theme" | jq -r '.colors["bright-white"]'  | tr -d '#')

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
  echo ""
  echo "==> $SLUG"

  # Resolve display name from JSON
  THEME_NAME=$(jq -r ".[] | select(.slug == \"$SLUG\") | .name" "$THEMES_JSON")
  if [[ -z "$THEME_NAME" || "$THEME_NAME" == "null" ]]; then
    echo "  SKIP — slug '$SLUG' not found in themes.json"
    FAIL=$((FAIL + 1))
    continue
  fi

  FOOT_CONF=$(generate_foot_config "$SLUG")

  # Launch foot with the theme config, running the display script
  foot \
    --config="$FOOT_CONF" \
    --app-id=foot \
    -- bash "$DISPLAY_SCRIPT" "$THEME_NAME" &
  FOOT_PID=$!

  # Wait for the window to appear in the compositor tree
  APPEARED=0
  for i in $(seq 1 40); do
    if swaymsg -t get_tree 2>/dev/null | jq -e '.. | objects | select(.app_id == "foot")' >/dev/null 2>&1; then
      APPEARED=1
      break
    fi
    sleep 0.1
  done

  if [[ $APPEARED -eq 0 ]]; then
    echo "  FAIL — foot window did not appear"
    kill "$FOOT_PID" 2>/dev/null || true
    FAIL=$((FAIL + 1))
    continue
  fi

  # Give foot 300ms to finish rendering the display script output
  sleep 0.3

  # Capture the exact window geometry from swaymsg
  GEOM=$(swaymsg -t get_tree 2>/dev/null \
    | jq -r '.. | objects | select(.app_id == "foot") | .rect | "\(.x),\(.y) \(.width)x\(.height)"' \
    | head -1)

  OUT="${OUT_DIR}/${SLUG}.png"

  if [[ -n "$GEOM" ]]; then
    grim -o HEADLESS-1 -g "$GEOM" "$OUT"
    echo "  OK  $OUT  ($GEOM)"
    OK=$((OK + 1))
  else
    # Fallback: screenshot the full output and crop manually
    FULL="/tmp/full-${SLUG}.png"
    grim -o HEADLESS-1 "$FULL"
    convert "$FULL" -crop "${WIN_W}x${WIN_H}+${WIN_X}+${WIN_Y}" +repage "$OUT"
    echo "  OK  $OUT  (fallback crop)"
    OK=$((OK + 1))
  fi

  kill "$FOOT_PID" 2>/dev/null || true
  wait "$FOOT_PID" 2>/dev/null || true
  sleep 0.2
done

# ── cleanup ───────────────────────────────────────────────────────────────────

kill "$SWAY_PID" 2>/dev/null || true
wait "$SWAY_PID" 2>/dev/null || true
rm -f "$SWAY_CONF" "$DISPLAY_SCRIPT" /tmp/foot-*.ini /tmp/full-*.png

echo ""
echo "Done: ${OK} saved, ${FAIL} failed."
ls -lh "${OUT_DIR}"/*.png 2>/dev/null || echo "(no files)"
if [[ $FAIL -gt 0 ]]; then exit 1; fi
