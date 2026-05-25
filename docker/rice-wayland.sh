#!/usr/bin/env bash
# Desktop scene screenshots via pure ImageMagick composition — no compositor.
# Layers: gradient wallpaper + waybar bar + terminal window + rofi popup.
#
# Usage (inside the rice-wayland Docker image):
#   bash docker/rice-wayland.sh            # all themes, auto style
#   bash docker/rice-wayland.sh dracula    # single theme
#   STYLE=scp bash docker/rice-wayland.sh  # force a style for all
#
# Geometry env vars (all optional):
#   WIN_W, WIN_H — terminal width/height in px  (default 760x460)
#   WIN_X, WIN_Y — terminal position in px       (default 60,55)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/rice/screenshots"
THEMES_JSON="${REPO_ROOT}/colors/terminal/themes.json"

# ── canvas / window geometry ─────────────────────────────────────────────────
OUTPUT_W=1440
OUTPUT_H=900
BAR_H=32
TITLE_H=28

WIN_W="${WIN_W:-760}"
WIN_H="${WIN_H:-460}"
WIN_X="${WIN_X:-60}"
WIN_Y="${WIN_Y:-55}"

ROFI_W=400
ROFI_H=252
ROFI_X=$((OUTPUT_W - ROFI_W - 40))
ROFI_Y=$((BAR_H + 36))

FONT_UI="DejaVu-Sans"
FONT_MONO="DejaVu-Sans-Mono"

# ── theme → display style ─────────────────────────────────────────────────────
declare -A THEME_STYLE=(
  [dracula]="cyberpunk"     [nord]="science"
  [solarized-dark]="retro"  [solarized-light]="macos"
  [monokai]="neofetch"      [gruvbox-dark]="scp"
  [catppuccin-mocha]="anime" [tokyo-night]="cyberpunk"
  [one-dark]="minimal"      [material-dark]="science"
)

style_for() { [[ -n "${STYLE:-}" ]] && echo "$STYLE" || echo "${THEME_STYLE[$1]:-minimal}"; }

mkdir -p "$OUT_DIR"

ALL_SLUGS=()
while IFS= read -r s; do ALL_SLUGS+=("$s"); done < <(jq -r '.[].slug' "$THEMES_JSON")

if [[ $# -ge 1 ]]; then
  SLUGS=("$1")
else
  SLUGS=("${ALL_SLUGS[@]}")
fi

echo "==> Generating rice configs..."
cd "$REPO_ROOT" && node rice/generate.js
echo "    Done."

OK=0; FAIL=0

for SLUG in "${SLUGS[@]}"; do
  THEME_NAME=$(jq -r ".[] | select(.slug == \"$SLUG\") | .name" "$THEMES_JSON")
  if [[ -z "$THEME_NAME" || "$THEME_NAME" == "null" ]]; then
    echo "  SKIP $SLUG (not found)"; FAIL=$((FAIL+1)); continue
  fi

  STYLE_NAME=$(style_for "$SLUG")
  echo ""
  echo "==> $SLUG  [style: $STYLE_NAME]"

  # ── extract colors ────────────────────────────────────────────────────────
  TD=$(jq -r ".[] | select(.slug == \"$SLUG\")" "$THEMES_JSON")
  s() { printf '%s' "$TD" | jq -r "$1" | tr -d '#'; }

  BG=$(s '.background');  FG=$(s '.foreground')
  C0=$(s '.colors.black');   C1=$(s '.colors.red')
  C2=$(s '.colors.green');   C3=$(s '.colors.yellow')
  C4=$(s '.colors.blue');    C5=$(s '.colors.magenta')
  C6=$(s '.colors.cyan');    C7=$(s '.colors.white')
  C8=$(s '.colors["bright-black"]');  C9=$(s  '.colors["bright-red"]')
  C10=$(s '.colors["bright-green"]'); C11=$(s '.colors["bright-yellow"]')
  C12=$(s '.colors["bright-blue"]');  C13=$(s '.colors["bright-magenta"]')
  C14=$(s '.colors["bright-cyan"]');  C15=$(s '.colors["bright-white"]')

  # accent for wallpaper gradient: prefer blue, fall back to cyan, then fg
  if [[ -n "$C4" ]]; then ACCENT="$C4"
  elif [[ -n "$C6" ]]; then ACCENT="$C6"
  else ACCENT="$FG"; fi

  WP="/tmp/wp-${SLUG}.png"
  PTXT="/tmp/ptxt-${SLUG}.png"
  OUT="${OUT_DIR}/${SLUG}.png"

  # ── 1. gradient wallpaper ─────────────────────────────────────────────────
  convert -size "${OUTPUT_W}x${OUTPUT_H}" gradient:"#${BG}-#${ACCENT}" "$WP"

  # ── 2. pango terminal content (colored text) ──────────────────────────────
  TXT_W=$((WIN_W - 36))

  case "$STYLE_NAME" in
    cyberpunk)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>ssh neo@matrix.local</span>\n\
<span fgcolor='#${C6}'>Connected to matrix.local [encrypted]</span>\n\
<span fgcolor='#${C3}'>Warning: 3 new messages in /dev/null</span>\n\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>ls --color=auto /</span>\n\
<span fgcolor='#${C4}'>bin  boot  dev  etc  home  proc  sys  usr</span>\n\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C1}'>█</span></span>"
      ;;
    scp)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C1}'>[SCP-SECURE] </span><span fgcolor='#${C7}'>Accessing database...</span>\n\
<span fgcolor='#${C6}'>Object class: Keter | Clearance: O5</span>\n\
<span fgcolor='#${C3}'>[WARNING] Cognitohazard filters active</span>\n\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>query --object SCP-3125</span>\n\
<span fgcolor='#${C7}'>Containment status: Nominal</span>\n\
<span fgcolor='#${C1}'>[REDACTED] █</span></span>"
      ;;
    anime)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C5}'>(◕‿◕✿) </span><span fgcolor='#${C7}'>Welcome, senpai~</span>\n\
<span fgcolor='#${C6}'>Loading kawaii modules... done ✓</span>\n\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>neofetch</span>\n\
<span fgcolor='#${C3}'>✿ OS: Arch Linux btw  ✿ WM: Sway</span>\n\
<span fgcolor='#${C5}'>✿ Theme: ${THEME_NAME}</span>\n\
<span fgcolor='#${C6}'>UwU █</span></span>"
      ;;
    science)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C6}'>λ </span><span fgcolor='#${C7}'>python3</span>\n\
<span fgcolor='#${C2}'>&gt;&gt;&gt; </span><span fgcolor='#${C7}'>import numpy as np; np.pi</span>\n\
<span fgcolor='#${C3}'>3.141592653589793</span>\n\
<span fgcolor='#${C6}'>λ </span><span fgcolor='#${C7}'>grep -c 'TODO' src/*.py</span>\n\
<span fgcolor='#${C3}'>42</span>\n\
<span fgcolor='#${C6}'>λ █</span></span>"
      ;;
    retro)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C3}'>C:\&gt; </span><span fgcolor='#${C7}'>dir /w</span>\n\
<span fgcolor='#${C7}'> Volume in drive C is ARCH</span>\n\
<span fgcolor='#${C6}'> CONFIG.SYS  COMMAND.COM  AUTOEXEC.BAT</span>\n\
<span fgcolor='#${C3}'>C:\&gt; </span><span fgcolor='#${C7}'>edit config.sys</span>\n\
<span fgcolor='#${C2}'>[████████████████] 100%</span>\n\
<span fgcolor='#${C2}'>OK █</span></span>"
      ;;
    macos)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C2}'>~/projects </span><span fgcolor='#${C4}'>(main) </span><span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>ls -la</span>\n\
<span fgcolor='#${C4}'>drwxr-xr-x  </span><span fgcolor='#${C7}'>src    tests</span>\n\
<span fgcolor='#${C7}'>-rw-r--r--  package.json  README.md</span>\n\
<span fgcolor='#${C2}'>~/projects </span><span fgcolor='#${C4}'>(main) </span><span fgcolor='#${C2}'>❯</span>\n\
<span fgcolor='#${C3}'>⚡ </span><span fgcolor='#${C7}'>npm run build</span>\n\
<span fgcolor='#${C2}'>✓ Built in 1.2s █</span></span>"
      ;;
    neofetch)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C4}'>    .     </span><span fgcolor='#${C7}'>user</span><span fgcolor='#${C6}'>@</span><span fgcolor='#${C7}'>archbox</span>\n\
<span fgcolor='#${C4}'>   /\\     </span><span fgcolor='#${C3}'>OS: </span><span fgcolor='#${C7}'>Arch Linux</span>\n\
<span fgcolor='#${C4}'>  /  \\    </span><span fgcolor='#${C3}'>WM: </span><span fgcolor='#${C7}'>Sway</span>\n\
<span fgcolor='#${C4}'> /    \\   </span><span fgcolor='#${C3}'>Theme: </span><span fgcolor='#${C7}'>${THEME_NAME}</span>\n\
<span fgcolor='#${C4}'>/______\\  </span><span fgcolor='#${C3}'>Term: </span><span fgcolor='#${C7}'>foot</span></span>"
      ;;
    windows)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C4}'>Microsoft Windows [Version 11.0]</span>\n\
<span fgcolor='#${C7}'>(c) Microsoft Corporation.</span>\n\n\
<span fgcolor='#${C7}'>C:\Users\User&gt; </span><span fgcolor='#${C15}'>winver</span>\n\
<span fgcolor='#${C6}'>About Windows — ${THEME_NAME} Edition</span>\n\
<span fgcolor='#${C7}'>C:\Users\User&gt; █</span></span>"
      ;;
    minimal|*)
      PANGO="<span font='DejaVu Sans Mono 12'>\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>git log --oneline -3</span>\n\
<span fgcolor='#${C3}'>7a1f3b2 </span><span fgcolor='#${C15}'>(HEAD) </span><span fgcolor='#${C7}'>add rice theme configs</span>\n\
<span fgcolor='#${C3}'>3c8e5d1 </span><span fgcolor='#${C7}'>update hyprland keybinds</span>\n\
<span fgcolor='#${C3}'>9f2a4c0 </span><span fgcolor='#${C7}'>initial dotfiles</span>\n\
<span fgcolor='#${C2}'>❯ </span><span fgcolor='#${C7}'>nvim .</span>\n\
<span fgcolor='#${C2}'>❯ █</span></span>"
      ;;
  esac

  # Render pango markup → PNG; fall back to plain text if pango unsupported
  if ! convert -background "#${BG}" -size "${TXT_W}x" \
       pango:"${PANGO}" "$PTXT" 2>/dev/null; then
    # Plain-text fallback (no colors, but readable)
    PLAIN=$(printf '%s' "$PANGO" | sed 's/<[^>]*>//g' | sed 's/\\n/\n/g')
    convert -background "#${BG}" -fill "#${FG}" \
      -font "$FONT_MONO" -pointsize 12 \
      -size "${TXT_W}x160" label:"$PLAIN" "$PTXT"
  fi

  # ── 3. compose full scene ─────────────────────────────────────────────────
  # Swatch positions
  SW_X=$((WIN_X+18));  SW_Y=$((WIN_Y+TITLE_H+20))
  SW_W=28; SW_H=16; SW_GAP=4; SW_Y2=$((SW_Y+SW_H+5))
  TXT_X=$((WIN_X+18)); TXT_Y=$((SW_Y2+SW_H+20))
  CLK_X=$((OUTPUT_W/2 - 90))

  convert "$WP" \
    `# ── waybar ──` \
    -fill "#${BG}"    -draw "rectangle 0,0 $((OUTPUT_W-1)),$BAR_H" \
    -fill "#${C8}"    -draw "line 0,$BAR_H $((OUTPUT_W-1)),$BAR_H" \
    -gravity NorthWest \
    -fill "#${C15}"   -font "$FONT_UI" -pointsize 12  -annotate "+14+9"       "  1   2   3" \
    -fill "#${C2}"    -font "$FONT_UI" -pointsize 12  -annotate "+${CLK_X}+9" " 14:23   Sat 24 May" \
    -fill "#${C4}"    -font "$FONT_UI" -pointsize 12  -annotate "+$((OUTPUT_W-175))+9" " 12%   63%" \
    `# ── terminal shadow ──` \
    -fill "rgba(0,0,0,0.35)" \
    -draw "roundRectangle $((WIN_X+4)),$((WIN_Y+4)) $((WIN_X+WIN_W+4)),$((WIN_Y+WIN_H+4)) 10,10" \
    `# ── terminal body ──` \
    -fill "#${BG}" \
    -draw "roundRectangle $WIN_X,$WIN_Y $((WIN_X+WIN_W)),$((WIN_Y+WIN_H)) 8,8" \
    `# ── titlebar ──` \
    -fill "#${C8}" \
    -draw "roundRectangle $WIN_X,$WIN_Y $((WIN_X+WIN_W)),$((WIN_Y+TITLE_H)) 8,8" \
    -draw "rectangle $WIN_X,$((WIN_Y+TITLE_H/2)) $((WIN_X+WIN_W)),$((WIN_Y+TITLE_H))" \
    `# ── traffic lights ──` \
    -fill "#ff5f57" -draw "circle $((WIN_X+14)),$((WIN_Y+14)) $((WIN_X+20)),$((WIN_Y+14))" \
    -fill "#febc2e" -draw "circle $((WIN_X+30)),$((WIN_Y+14)) $((WIN_X+36)),$((WIN_Y+14))" \
    -fill "#28c840" -draw "circle $((WIN_X+46)),$((WIN_Y+14)) $((WIN_X+52)),$((WIN_Y+14))" \
    `# ── window title ──` \
    -fill "#${C15}" -font "$FONT_MONO" -pointsize 11 \
    -annotate "+$((WIN_X+WIN_W/2-50))+$((WIN_Y+9))" "bash — ${THEME_NAME}" \
    `# ── color swatches row 1 (normal) ──` \
    -fill "#${C0}" -draw "roundRectangle $((SW_X+0*32)),$SW_Y $((SW_X+0*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C1}" -draw "roundRectangle $((SW_X+1*32)),$SW_Y $((SW_X+1*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C2}" -draw "roundRectangle $((SW_X+2*32)),$SW_Y $((SW_X+2*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C3}" -draw "roundRectangle $((SW_X+3*32)),$SW_Y $((SW_X+3*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C4}" -draw "roundRectangle $((SW_X+4*32)),$SW_Y $((SW_X+4*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C5}" -draw "roundRectangle $((SW_X+5*32)),$SW_Y $((SW_X+5*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C6}" -draw "roundRectangle $((SW_X+6*32)),$SW_Y $((SW_X+6*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    -fill "#${C7}" -draw "roundRectangle $((SW_X+7*32)),$SW_Y $((SW_X+7*32+SW_W)),$((SW_Y+SW_H)) 2,2" \
    `# ── color swatches row 2 (bright) ──` \
    -fill "#${C8}"  -draw "roundRectangle $((SW_X+0*32)),$SW_Y2 $((SW_X+0*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C9}"  -draw "roundRectangle $((SW_X+1*32)),$SW_Y2 $((SW_X+1*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C10}" -draw "roundRectangle $((SW_X+2*32)),$SW_Y2 $((SW_X+2*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C11}" -draw "roundRectangle $((SW_X+3*32)),$SW_Y2 $((SW_X+3*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C12}" -draw "roundRectangle $((SW_X+4*32)),$SW_Y2 $((SW_X+4*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C13}" -draw "roundRectangle $((SW_X+5*32)),$SW_Y2 $((SW_X+5*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C14}" -draw "roundRectangle $((SW_X+6*32)),$SW_Y2 $((SW_X+6*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    -fill "#${C15}" -draw "roundRectangle $((SW_X+7*32)),$SW_Y2 $((SW_X+7*32+SW_W)),$((SW_Y2+SW_H)) 2,2" \
    `# ── rofi popup shadow ──` \
    -fill "rgba(0,0,0,0.3)" \
    -draw "roundRectangle $((ROFI_X+3)),$((ROFI_Y+3)) $((ROFI_X+ROFI_W+3)),$((ROFI_Y+ROFI_H+3)) 8,8" \
    `# ── rofi popup body ──` \
    -fill "#${BG}" \
    -draw "roundRectangle $ROFI_X,$ROFI_Y $((ROFI_X+ROFI_W)),$((ROFI_Y+ROFI_H)) 8,8" \
    -fill none -stroke "#${C4}" -strokewidth 2 \
    -draw "roundRectangle $ROFI_X,$ROFI_Y $((ROFI_X+ROFI_W)),$((ROFI_Y+ROFI_H)) 8,8" \
    -stroke none \
    `# ── rofi search bar ──` \
    -fill "#${C8}" \
    -draw "roundRectangle $((ROFI_X+10)),$((ROFI_Y+10)) $((ROFI_X+ROFI_W-10)),$((ROFI_Y+46)) 4,4" \
    -fill "#${C4}" -font "$FONT_UI" -pointsize 12 \
    -annotate "+$((ROFI_X+16))+$((ROFI_Y+16))" " Search" \
    -fill "#${C7}" \
    -annotate "+$((ROFI_X+68))+$((ROFI_Y+16))" "Type to filter..." \
    `# ── rofi items ──` \
    -fill "#${C7}" -font "$FONT_UI" -pointsize 12 \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+58))"  "Firefox" \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+88))"  "Alacritty" \
    `# selected item ──` \
    -fill "#${C4}" \
    -draw "roundRectangle $((ROFI_X+10)),$((ROFI_Y+112)) $((ROFI_X+ROFI_W-10)),$((ROFI_Y+138)) 4,4" \
    -fill "#${BG}" -font "$FONT_UI" -pointsize 12 \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+118))" "Neovim" \
    -fill "#${C7}" \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+148))" "File Manager" \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+178))" "Spotify" \
    -annotate "+$((ROFI_X+18))+$((ROFI_Y+208))" "Discord" \
    `# ── attribution ──` \
    -gravity SouthEast \
    -fill "rgba(0,0,0,0.65)" \
    -draw "roundRectangle $((OUTPUT_W-322)),$((OUTPUT_H-28)) $((OUTPUT_W-2)),$((OUTPUT_H-2)) 4,4" \
    -fill "rgba(255,255,255,0.85)" -font "$FONT_UI" -pointsize 11 \
    -annotate "0+6+8" "Theme: ${THEME_NAME} · Wallpaper: ImageMagick gradient" \
    "$OUT"

  # ── 4. composite pango text onto terminal area ────────────────────────────
  convert "$OUT" "$PTXT" -geometry "+${TXT_X}+${TXT_Y}" -composite "$OUT"

  rm -f "$WP" "$PTXT"
  echo "  OK → $OUT"
  OK=$((OK+1))
done

echo ""
echo "Done: ${OK} saved, ${FAIL} failed."
ls -lh "${OUT_DIR}"/*.png 2>/dev/null || echo "(no output files)"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
