#!/usr/bin/env bash
# Full desktop scene screenshots of rice themes — 1440x900.
# Renders: gradient wallpaper + waybar + foot terminal + rofi launcher.
#
# Usage (inside the rice-wayland Docker image):
#   bash docker/rice-wayland.sh            # all themes, auto style
#   bash docker/rice-wayland.sh dracula    # single theme
#   STYLE=scp bash docker/rice-wayland.sh  # force a style for all
#
# Geometry env vars (all optional):
#   WIN_W, WIN_H — foot terminal width/height in px (default 760x460)
#   WIN_X, WIN_Y — foot terminal position in px     (default 60,55)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/rice/screenshots"
THEMES_JSON="${REPO_ROOT}/colors/terminal/themes.json"
STYLES_DIR="${REPO_ROOT}/docker/styles"

# ── output / window geometry ──────────────────────────────────────────────────
OUTPUT_W=1440
OUTPUT_H=900

WIN_W="${WIN_W:-760}"
WIN_H="${WIN_H:-460}"
WIN_X="${WIN_X:-60}"
WIN_Y="${WIN_Y:-55}"

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
# foot terminal: left side, mid-height
for_window [app_id="foot"] floating enable, \
    resize set ${WIN_W} ${WIN_H}, \
    move position ${WIN_X} ${WIN_Y}
# rofi: floating, sway will place it centered
for_window [app_id="rofi"] floating enable
SWAY_EOF

echo "==> Starting Sway headless (${OUTPUT_W}x${OUTPUT_H})..."
# LIBSEAT_BACKEND=noop  — skip seat acquisition (no logind/seatd in Docker)
# WLR_LIBINPUT_NO_DEVICES=1 — don't fail on missing /dev/input devices
# XKB_DEFAULT_RULES=evdev   — safe keymap rules that don't require kernel keyctl
WLR_BACKENDS=headless \
WLR_RENDERER=pixman \
LIBSEAT_BACKEND=noop \
WLR_LIBINPUT_NO_DEVICES=1 \
XKB_DEFAULT_RULES=evdev \
  sway --config "$SWAY_CONF" 2>/tmp/sway.log &
SWAY_PID=$!

# Wait up to 4 seconds for sway to become responsive
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

  # ── a. read theme colors for wallpaper ──────────────────────────────────────
  THEME_DATA=$(jq -r ".[] | select(.slug == \"$SLUG\")" "$THEMES_JSON")
  BG_COLOR=$(printf '%s' "$THEME_DATA" | jq -r '.background')
  # Prefer blue, fall back to cyan, then foreground
  ACCENT_COLOR=$(printf '%s' "$THEME_DATA" | jq -r '
    if .colors.blue and (.colors.blue != "") then .colors.blue
    elif .colors.cyan and (.colors.cyan != "") then .colors.cyan
    else .foreground
    end')

  # ── b. generate gradient wallpaper ──────────────────────────────────────────
  WALLPAPER="/tmp/wallpaper-${SLUG}.png"
  echo "  Generating wallpaper: ${BG_COLOR} → ${ACCENT_COLOR}"
  convert -size "${OUTPUT_W}x${OUTPUT_H}" \
    gradient:"${BG_COLOR}-${ACCENT_COLOR}" \
    -alpha set -channel Alpha -evaluate set 100% \
    "$WALLPAPER"

  # ── c. set wallpaper via swaybg ──────────────────────────────────────────────
  # Kill any previous swaybg instance
  pkill -x swaybg 2>/dev/null || true
  sleep 0.1
  SWAYBG_PID=""
  swaybg -o HEADLESS-1 -i "$WALLPAPER" -m fill &
  SWAYBG_PID=$!
  sleep 0.5

  # ── d. generate foot config ──────────────────────────────────────────────────
  FOOT_CONF=$(generate_foot_config "$SLUG")

  # ── e. generate and launch waybar ────────────────────────────────────────────
  # Kill any previous waybar instance
  pkill -x waybar 2>/dev/null || true
  sleep 0.2

  # Write waybar JSON config
  WAYBAR_JSON="/tmp/waybar-${SLUG}.json"
  cat > "$WAYBAR_JSON" <<WAYBAR_JSON_EOF
{
  "layer": "top",
  "position": "top",
  "height": 32,
  "output": "HEADLESS-1",
  "modules-left": ["sway/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["cpu", "memory"],
  "sway/workspaces": {
    "disable-scroll": true,
    "all-outputs": true,
    "format": "{icon}",
    "format-icons": {
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5",
      "urgent": "",
      "focused": "",
      "default": ""
    },
    "persistent_workspaces": {
      "1": [],
      "2": [],
      "3": []
    }
  },
  "clock": {
    "format": " {:%H:%M   %a %d %b}",
    "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
  },
  "cpu": {
    "format": " {usage}%",
    "interval": 5,
    "tooltip": false
  },
  "memory": {
    "format": " {}%",
    "interval": 5,
    "tooltip": false
  }
}
WAYBAR_JSON_EOF

  # Build waybar CSS: start with the theme's CSS variables, then append layout rules
  WAYBAR_CSS="/tmp/waybar-${SLUG}.css"
  THEME_CSS="${REPO_ROOT}/rice/waybar/${SLUG}.css"

  if [[ -f "$THEME_CSS" ]]; then
    cp "$THEME_CSS" "$WAYBAR_CSS"
  else
    # Fallback: empty :root block so CSS vars resolve to safe defaults
    printf ':root {}\n' > "$WAYBAR_CSS"
  fi

  # Append full layout rules after the theme variables
  cat >> "$WAYBAR_CSS" <<WAYBAR_CSS_EOF

/* ── layout rules appended by rice-wayland.sh ── */
* {
  font-family: "JetBrains Mono", monospace;
  font-size: 13px;
  border: none;
  margin: 0;
  padding: 0 8px;
}

window#waybar {
  background-color: var(--background);
  color: var(--foreground);
  border-bottom: 2px solid var(--bright-black);
}

#workspaces {
  padding: 0;
}

#workspaces button {
  color: var(--bright-black);
  background: transparent;
  padding: 0 6px;
  border-radius: 0;
  box-shadow: none;
  text-shadow: none;
}

#workspaces button:hover {
  background: transparent;
  color: var(--foreground);
  box-shadow: none;
}

#workspaces button.focused {
  color: var(--cyan);
  font-weight: bold;
  border-bottom: 2px solid var(--cyan);
}

#workspaces button.urgent {
  color: var(--red);
  border-bottom: 2px solid var(--red);
}

#clock {
  color: var(--green);
  font-weight: bold;
  padding: 0 16px;
}

#cpu {
  color: var(--blue);
  padding: 0 8px;
}

#memory {
  color: var(--magenta);
  padding: 0 8px;
}

tooltip {
  background: var(--background);
  border: 1px solid var(--bright-black);
  border-radius: 4px;
}

tooltip label {
  color: var(--foreground);
}
WAYBAR_CSS_EOF

  echo "  Launching waybar..."
  DBUS_SESSION_BUS_ADDRESS="" \
  waybar --config "$WAYBAR_JSON" --style "$WAYBAR_CSS" \
    2>/tmp/waybar-${SLUG}.log &
  WAYBAR_PID=$!
  # Give waybar time to render its bar
  sleep 1.0

  # ── f. generate and launch rofi ──────────────────────────────────────────────
  # Kill any previous rofi instance
  pkill -x rofi 2>/dev/null || true
  sleep 0.1

  ROFI_RASI="/tmp/rofi-${SLUG}.rasi"
  THEME_RASI="${REPO_ROOT}/rice/rofi/${SLUG}.rasi"

  if [[ -f "$THEME_RASI" ]]; then
    cp "$THEME_RASI" "$ROFI_RASI"
  else
    # Minimal fallback color block so layout rules compile
    cat > "$ROFI_RASI" <<ROFI_FALLBACK_EOF
* {
  background-color: #1e1e2e;
  foreground: #cdd6f4;
  normal-background: #1e1e2e;
  normal-foreground: #cdd6f4;
  selected-normal-background: #89b4fa;
  selected-normal-foreground: #1e1e2e;
  border-color: #6c7086;
}
ROFI_FALLBACK_EOF
  fi

  # Append full layout rules after the theme color definitions
  cat >> "$ROFI_RASI" <<ROFI_LAYOUT_EOF

/* ── layout rules appended by rice-wayland.sh ── */
window {
  width: 480px;
  padding: 12px;
  background-color: @background-color;
  border: 2px solid @border-color;
  border-radius: 8px;
  x-offset: $((OUTPUT_W - 540));
  y-offset: 40;
  location: northwest;
  anchor: northwest;
}

mainbox {
  background-color: transparent;
  spacing: 8px;
  children: [inputbar, listview];
}

inputbar {
  background-color: @normal-background;
  padding: 8px 12px;
  border-radius: 4px;
  children: [prompt, entry];
}

prompt {
  background-color: transparent;
  text-color: @selected-normal-background;
  padding: 0 6px 0 0;
}

entry {
  background-color: transparent;
  text-color: @foreground;
  placeholder: "Type to filter...";
  placeholder-color: @border-color;
}

listview {
  lines: 6;
  scrollbar: false;
  background-color: transparent;
  spacing: 4px;
}

element {
  padding: 8px 12px;
  border-radius: 4px;
  background-color: @normal-background;
  text-color: @normal-foreground;
}

element selected {
  background-color: @selected-normal-background;
  text-color: @selected-normal-foreground;
}

element-text {
  background-color: transparent;
  text-color: inherit;
}
ROFI_LAYOUT_EOF

  echo "  Launching rofi..."
  printf 'Firefox\nAlacritty\nKitty\nNeovim\nFile Manager\nSpotify\nDiscord\nVS Code\nTerminal\nFiles\nBrave\nMPV' \
    | rofi -dmenu -p "Search" \
           -config "$ROFI_RASI" \
           -no-custom \
           -selected-row 2 \
    2>/tmp/rofi-${SLUG}.log &
  ROFI_PID=$!
  # Give rofi time to render
  sleep 0.8

  # ── g. launch foot terminal ───────────────────────────────────────────────────
  echo "  Launching foot..."
  foot \
    --config="$FOOT_CONF" \
    --app-id=foot \
    -- bash "$STYLE_SCRIPT" "$THEME_NAME" "$SLUG" &
  FOOT_PID=$!

  # ── h. wait for foot window to appear in sway tree ───────────────────────────
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
    kill "$FOOT_PID"  2>/dev/null || true
    kill "$ROFI_PID"  2>/dev/null || true
    kill "$WAYBAR_PID" 2>/dev/null || true
    [[ -n "${SWAYBG_PID:-}" ]] && kill "$SWAYBG_PID" 2>/dev/null || true
    FAIL=$((FAIL + 1)); continue
  fi

  # ── i. wait for rendering to settle ─────────────────────────────────────────
  sleep 0.5

  # ── j. screenshot the full HEADLESS-1 output ─────────────────────────────────
  SHOT_RAW="/tmp/shot-${SLUG}.png"
  grim -o HEADLESS-1 "$SHOT_RAW"
  echo "  Captured full output → $SHOT_RAW"

  # ── k. burn attribution text onto the bottom-right corner ────────────────────
  OUT="${OUT_DIR}/${SLUG}.png"

  convert "$SHOT_RAW" \
    -font DejaVu-Sans \
    -pointsize 11 \
    -gravity SouthEast \
    -fill "rgba(0,0,0,0.65)" \
    -draw "roundRectangle $((OUTPUT_W-322)),$((OUTPUT_H-28)) $((OUTPUT_W-2)),$((OUTPUT_H-2)) 4,4" \
    -fill "rgba(255,255,255,0.85)" \
    -annotate "0+6+8" "Theme: ${THEME_NAME} · Wallpaper: ImageMagick gradient" \
    "$OUT"

  echo "  OK  $OUT"
  OK=$((OK + 1))

  # ── l. kill foot, rofi, waybar, swaybg ───────────────────────────────────────
  kill "$FOOT_PID"   2>/dev/null || true
  wait "$FOOT_PID"   2>/dev/null || true
  kill "$ROFI_PID"   2>/dev/null || true
  wait "$ROFI_PID"   2>/dev/null || true
  kill "$WAYBAR_PID" 2>/dev/null || true
  wait "$WAYBAR_PID" 2>/dev/null || true
  [[ -n "${SWAYBG_PID:-}" ]] && { kill "$SWAYBG_PID" 2>/dev/null || true; wait "$SWAYBG_PID" 2>/dev/null || true; }

  # ── m. clean up temp files ────────────────────────────────────────────────────
  rm -f "$SHOT_RAW" "$WALLPAPER" "$FOOT_CONF" \
        "$WAYBAR_JSON" "$WAYBAR_CSS" "$ROFI_RASI"

  sleep 0.2
done

# ── cleanup ───────────────────────────────────────────────────────────────────
kill "$SWAY_PID" 2>/dev/null || true
wait "$SWAY_PID" 2>/dev/null || true
rm -f "$SWAY_CONF" /tmp/sway.log /tmp/waybar-*.log /tmp/rofi-*.log

echo ""
echo "Done: ${OK} saved, ${FAIL} failed."
ls -lh "${OUT_DIR}"/*.png 2>/dev/null || echo "(no output files)"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
