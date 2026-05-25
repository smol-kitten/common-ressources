#!/usr/bin/env bash
# Desktop scene screenshots via pure ImageMagick composition.
# Usage:
#   bash docker/rice-wayland.sh            # all themes
#   bash docker/rice-wayland.sh dracula    # single theme
#   STYLE=scp bash docker/rice-wayland.sh  # force a style

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/rice/screenshots"
THEMES_JSON="${REPO_ROOT}/colors/terminal/themes.json"

OUTPUT_W=1440
OUTPUT_H=900
BAR_H=32
TITLE_H=28
WIN_W="${WIN_W:-760}"
WIN_H="${WIN_H:-460}"
WIN_X="${WIN_X:-60}"
WIN_Y="${WIN_Y:-55}"

mkdir -p "$OUT_DIR"

echo "==> ImageMagick version:"
convert --version

echo "==> Generating rice configs..."
cd "$REPO_ROOT"
[[ -f package.json ]] && npm install --prefer-offline 2>/dev/null || true
node rice/generate.js
echo "    Done."

declare -A THEME_STYLE=(
  [dracula]="cyberpunk"     [nord]="science"
  [solarized-dark]="retro"  [solarized-light]="macos"
  [monokai]="neofetch"      [gruvbox-dark]="scp"
  [catppuccin-mocha]="anime" [tokyo-night]="cyberpunk"
  [one-dark]="minimal"      [material-dark]="science"
)
style_for() { [[ -n "${STYLE:-}" ]] && echo "$STYLE" || echo "${THEME_STYLE[$1]:-minimal}"; }

ALL_SLUGS=()
while IFS= read -r s; do ALL_SLUGS+=("$s"); done < <(jq -r '.[].slug' "$THEMES_JSON")
if [[ $# -ge 1 ]]; then SLUGS=("$1"); else SLUGS=("${ALL_SLUGS[@]}"); fi

OK=0; FAIL=0

for SLUG in "${SLUGS[@]}"; do
  THEME_NAME=$(jq -r ".[] | select(.slug == \"$SLUG\") | .name" "$THEMES_JSON")
  if [[ -z "$THEME_NAME" || "$THEME_NAME" == "null" ]]; then
    echo "  SKIP $SLUG"; FAIL=$((FAIL+1)); continue
  fi
  STYLE_NAME=$(style_for "$SLUG")
  echo ""
  echo "==> $SLUG  [style: $STYLE_NAME]"

  # Extract colors — replace null/empty with safe gray
  TD=$(jq -r ".[] | select(.slug == \"$SLUG\")" "$THEMES_JSON")
  s() {
    local v
    v=$(printf '%s' "$TD" | jq -r "$1" | tr -d '#')
    if [[ -z "$v" || "$v" == "null" ]]; then echo "888888"; else echo "$v"; fi
  }
  BG=$(s '.background');   FG=$(s '.foreground')
  C0=$(s '.colors.black'); C1=$(s '.colors.red')
  C2=$(s '.colors.green'); C3=$(s '.colors.yellow')
  C4=$(s '.colors.blue');  C5=$(s '.colors.magenta')
  C6=$(s '.colors.cyan');  C7=$(s '.colors.white')
  C8=$(s  '.colors["bright-black"]');  C9=$(s  '.colors["bright-red"]')
  C10=$(s '.colors["bright-green"]');  C11=$(s '.colors["bright-yellow"]')
  C12=$(s '.colors["bright-blue"]');   C13=$(s '.colors["bright-magenta"]')
  C14=$(s '.colors["bright-cyan"]');   C15=$(s '.colors["bright-white"]')
  ACCENT="${C4}"

  # Swatch positions
  SW_X=$((WIN_X+18));  SW_Y=$((WIN_Y+TITLE_H+20))
  SW_W=28; SW_H=16;    SW_Y2=$((SW_Y+SW_H+5))
  TXT_X=$((WIN_X+18)); TXT_Y=$((SW_Y2+SW_H+20))
  LH=20
  CLK_X=$((OUTPUT_W/2-90))

  # Style-specific terminal lines: "COLOR_HEX|text"
  case "$STYLE_NAME" in
    cyberpunk) LINES=(
        "${C2}|> ssh neo@matrix.local"
        "${C6}|Connected to matrix.local"
        "${C3}|Warning: 3 new messages in /dev/null"
        "${C2}|> ls --color=auto /"
        "${C4}|bin  boot  dev  etc  home  proc"
        "${C2}|> _" ) ;;
    scp) LINES=(
        "${C1}|[SCP-SECURE] Accessing database..."
        "${C6}|Object class: Keter  Clearance: O5"
        "${C3}|[WARNING] Cognitohazard filters active"
        "${C2}|> query --object SCP-3125"
        "${C7}|Containment status: Nominal"
        "${C1}|[REDACTED] _" ) ;;
    anime) LINES=(
        "${C5}|(^.^) Welcome, senpai~"
        "${C6}|Loading kawaii modules... done"
        "${C2}|> neofetch"
        "${C3}|OS: Arch Linux btw  WM: Sway"
        "${C5}|Theme: ${THEME_NAME}"
        "${C6}|UwU _" ) ;;
    science) LINES=(
        "${C6}|lambda python3"
        "${C2}|>>> import numpy as np"
        "${C3}|3.141592653589793"
        "${C6}|lambda grep -c TODO src/"
        "${C3}|42"
        "${C6}|lambda _" ) ;;
    retro) LINES=(
        "${C3}|C:\> dir /w"
        "${C7}| Volume in drive C is ARCH"
        "${C6}| CONFIG.SYS  AUTOEXEC.BAT"
        "${C3}|C:\> edit config.sys"
        "${C2}|[################] 100%"
        "${C2}|OK _" ) ;;
    macos) LINES=(
        "${C2}|~/projects (main) > ls -la"
        "${C4}|drwxr-xr-x  src    tests"
        "${C7}|-rw-r--r--  package.json"
        "${C2}|~/projects (main) >"
        "${C3}|npm run build"
        "${C2}|Built in 1.2s _" ) ;;
    neofetch) LINES=(
        "${C4}|    .      user@archbox"
        "${C4}|   /\     OS: Arch Linux"
        "${C4}|  /  \    WM: Sway"
        "${C4}| /    \   Theme: ${THEME_NAME}"
        "${C4}|/______\  Term: foot"
        "${C8}| " ) ;;
    windows) LINES=(
        "${C4}|Microsoft Windows [Version 11.0]"
        "${C7}|(c) Microsoft Corporation."
        "${C8}| "
        "${C7}|C:\Users\User> winver"
        "${C6}|About Windows - ${THEME_NAME}"
        "${C7}|C:\Users\User> _" ) ;;
    minimal|*) LINES=(
        "${C2}|> git log --oneline -3"
        "${C3}|7a1f3b2 (HEAD) add rice theme configs"
        "${C3}|3c8e5d1 update hyprland keybinds"
        "${C3}|9f2a4c0 initial dotfiles"
        "${C2}|> nvim ."
        "${C2}|> _" ) ;;
  esac

  # Build text annotation args
  TEXT_ARGS=()
  for i in "${!LINES[@]}"; do
    COL="#${LINES[$i]%%|*}"
    TXT="${LINES[$i]#*|}"
    LINE_Y=$((TXT_Y + i * LH))
    [[ -n "${TXT// }" ]] && TEXT_ARGS+=(-fill "$COL" -annotate "+${TXT_X}+${LINE_Y}" "$TXT")
  done

  OUT="${OUT_DIR}/${SLUG}.png"
  WP="/tmp/wp-${SLUG}.png"

  # Step 1: gradient wallpaper
  convert -size "${OUTPUT_W}x${OUTPUT_H}" "gradient:#${BG}-#${ACCENT}" "$WP"

  # Step 2: compose full scene — one convert call, solid hex colors only
  convert "$WP" \
    -fill "#${BG}"  -draw "rectangle 0,0 $((OUTPUT_W-1)),$BAR_H" \
    -fill "#${C8}"  -draw "rectangle 0,$BAR_H $((OUTPUT_W-1)),$((BAR_H+1))" \
    -gravity NorthWest -pointsize 12 \
    -fill "#${C15}" -annotate "+14+9"            "  1   2   3" \
    -fill "#${C2}"  -annotate "+${CLK_X}+9"      " 14:23   Sat 24 May" \
    -fill "#${C4}"  -annotate "+$((OUTPUT_W-175))+9" " 12%   63%" \
    -fill "#${C8}"  \
    -draw "rectangle $((WIN_X+4)),$((WIN_Y+4)) $((WIN_X+WIN_W+4)),$((WIN_Y+WIN_H+4))" \
    -fill "#${BG}" \
    -draw "rectangle ${WIN_X},${WIN_Y} $((WIN_X+WIN_W)),$((WIN_Y+WIN_H))" \
    -fill "#${C8}" \
    -draw "rectangle ${WIN_X},${WIN_Y} $((WIN_X+WIN_W)),$((WIN_Y+TITLE_H))" \
    -fill "#ff5f57" -draw "circle $((WIN_X+14)),$((WIN_Y+14)) $((WIN_X+20)),$((WIN_Y+14))" \
    -fill "#febc2e" -draw "circle $((WIN_X+30)),$((WIN_Y+14)) $((WIN_X+36)),$((WIN_Y+14))" \
    -fill "#28c840" -draw "circle $((WIN_X+46)),$((WIN_Y+14)) $((WIN_X+52)),$((WIN_Y+14))" \
    -fill "#${C15}" -pointsize 11 \
    -annotate "+$((WIN_X+WIN_W/2-50))+$((WIN_Y+9))" "bash - ${THEME_NAME}" \
    -fill "#${C0}" -draw "rectangle $((SW_X+0*32)),${SW_Y} $((SW_X+0*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C1}" -draw "rectangle $((SW_X+1*32)),${SW_Y} $((SW_X+1*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C2}" -draw "rectangle $((SW_X+2*32)),${SW_Y} $((SW_X+2*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C3}" -draw "rectangle $((SW_X+3*32)),${SW_Y} $((SW_X+3*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C4}" -draw "rectangle $((SW_X+4*32)),${SW_Y} $((SW_X+4*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C5}" -draw "rectangle $((SW_X+5*32)),${SW_Y} $((SW_X+5*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C6}" -draw "rectangle $((SW_X+6*32)),${SW_Y} $((SW_X+6*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C7}" -draw "rectangle $((SW_X+7*32)),${SW_Y} $((SW_X+7*32+SW_W)),$((SW_Y+SW_H))" \
    -fill "#${C8}"  -draw "rectangle $((SW_X+0*32)),${SW_Y2} $((SW_X+0*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C9}"  -draw "rectangle $((SW_X+1*32)),${SW_Y2} $((SW_X+1*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C10}" -draw "rectangle $((SW_X+2*32)),${SW_Y2} $((SW_X+2*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C11}" -draw "rectangle $((SW_X+3*32)),${SW_Y2} $((SW_X+3*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C12}" -draw "rectangle $((SW_X+4*32)),${SW_Y2} $((SW_X+4*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C13}" -draw "rectangle $((SW_X+5*32)),${SW_Y2} $((SW_X+5*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C14}" -draw "rectangle $((SW_X+6*32)),${SW_Y2} $((SW_X+6*32+SW_W)),$((SW_Y2+SW_H))" \
    -fill "#${C15}" -draw "rectangle $((SW_X+7*32)),${SW_Y2} $((SW_X+7*32+SW_W)),$((SW_Y2+SW_H))" \
    -pointsize 12 \
    "${TEXT_ARGS[@]}" \
    -fill "#${C4}" -pointsize 11 \
    -annotate "+$((OUTPUT_W-175))+$((OUTPUT_H-14))" "Theme: ${THEME_NAME}  Wallpaper: ImageMagick gradient" \
    "$OUT"

  rm -f "$WP"
  echo "  OK -> $OUT"
  OK=$((OK+1))
done

echo ""
echo "Done: ${OK} saved, ${FAIL} failed."
ls -lh "${OUT_DIR}"/*.png 2>/dev/null || echo "(no output files)"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
