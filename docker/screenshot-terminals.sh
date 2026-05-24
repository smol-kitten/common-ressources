#!/usr/bin/env bash
# Takes real terminal screenshots of rice themes using Xvfb + xterm + scrot.
# Saves output PNGs to rice/screenshots/<slug>.png.
#
# Usage (inside the rice-screenshots Docker image):
#   bash docker/screenshot-terminals.sh [slug]
#   bash docker/screenshot-terminals.sh dracula
#   bash docker/screenshot-terminals.sh          # all themes

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RICE_DIR="${REPO_ROOT}/rice"
SCREENSHOT_DIR="${RICE_DIR}/screenshots"

mkdir -p "$SCREENSHOT_DIR"

ALL_SLUGS=(
  dracula
  nord
  solarized-dark
  solarized-light
  monokai
  gruvbox-dark
  catppuccin-mocha
  tokyo-night
  one-dark
  material-dark
)

# ── argument handling ─────────────────────────────────────────────────────────

if [[ $# -ge 1 ]]; then
  SLUGS=("$1")
else
  SLUGS=("${ALL_SLUGS[@]}")
fi

# ── start Xvfb ───────────────────────────────────────────────────────────────

export DISPLAY=:99
if ! pgrep -x Xvfb >/dev/null; then
  Xvfb :99 -screen 0 1280x800x24 &
  XVFB_PID=$!
  sleep 1
  echo "Started Xvfb (PID $XVFB_PID)"
else
  echo "Xvfb already running."
fi

# ── helper: write an xterm resource file for a theme ─────────────────────────

write_xterm_resources() {
  local bg="$1" fg="$2"
  local xres="${TMPDIR:-/tmp}/xterm-${SLUG}.Xresources"
  cat > "$xres" <<EOF
XTerm*background:  ${bg}
XTerm*foreground:  ${fg}
XTerm*faceName:    Hack
XTerm*faceSize:    11
XTerm*scrollBar:   false
XTerm*geometry:    80x24
EOF
  echo "$xres"
}

# ── neofetch script to run inside xterm ──────────────────────────────────────

write_neofetch_script() {
  local slug="$1"
  local script="${TMPDIR:-/tmp}/nf-${slug}.sh"
  cat > "$script" <<'SCRIPT'
#!/usr/bin/env bash
neofetch --ascii_distro Arch
sleep 3
SCRIPT
  chmod +x "$script"
  echo "$script"
}

# ── main loop ─────────────────────────────────────────────────────────────────

for SLUG in "${SLUGS[@]}"; do
  echo ""
  echo "==> Screenshot: $SLUG"

  # Read theme colours from the alacritty TOML (simple grep approach)
  TOML="${RICE_DIR}/alacritty/${SLUG}.toml"
  if [[ ! -f "$TOML" ]]; then
    echo "  SKIP — alacritty config not found: $TOML"
    continue
  fi

  BG=$(grep '^background' "$TOML" | head -1 | sed 's/.*"\(#[0-9A-Fa-f]*\)".*/\1/')
  FG=$(grep '^foreground' "$TOML" | head -1 | sed 's/.*"\(#[0-9A-Fa-f]*\)".*/\1/')

  echo "  BG=$BG  FG=$FG"

  # Write X resources
  XRES="$(write_xterm_resources "$BG" "$FG")"
  xrdb -merge "$XRES" 2>/dev/null || true

  # Write neofetch runner script
  NF_SCRIPT="$(write_neofetch_script "$SLUG")"

  # Launch xterm running neofetch, capture its window ID
  xterm \
    -bg "$BG" -fg "$FG" \
    -fa 'Hack' -fs 11 \
    -geometry 90x26+0+0 \
    -e "$NF_SCRIPT" &
  XTERM_PID=$!

  # Give xterm time to render
  sleep 2

  # Take screenshot of the whole display, then crop to terminal window
  TMPSHOT="${TMPDIR:-/tmp}/shot-${SLUG}.png"
  scrot "$TMPSHOT" 2>/dev/null || import -window root "$TMPSHOT" 2>/dev/null || true

  OUT="${SCREENSHOT_DIR}/${SLUG}.png"

  if [[ -f "$TMPSHOT" ]]; then
    # Crop to 800x500 from top-left (where xterm opened)
    convert "$TMPSHOT" -crop 800x500+0+0 +repage -resize 800x500 "$OUT" 2>/dev/null || \
      cp "$TMPSHOT" "$OUT"
    echo "  Saved: $OUT"
  else
    echo "  WARN: Screenshot failed for $SLUG"
  fi

  # Kill xterm
  kill "$XTERM_PID" 2>/dev/null || true
  wait "$XTERM_PID" 2>/dev/null || true

  # Small pause between screenshots
  sleep 0.5
done

echo ""
echo "Screenshots complete. Files in: $SCREENSHOT_DIR"
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null || echo "(no files)"
