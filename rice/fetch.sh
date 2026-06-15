#!/usr/bin/env bash
# Usage: bash <(curl -s https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice/fetch.sh) <slug>
# Example: bash <(curl -s https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice/fetch.sh) dracula
#
# Fetches and installs a rice theme for common Arch Linux tools:
#   alacritty, kitty, hyprland, waybar, rofi, dunst, wezterm

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/smol-kitten/common-ressources/main/rice"

AVAILABLE_SLUGS=(
  dracula
  nord
  solarized-dark
  solarized-light
  monokai
  gruvbox-dark
  catppuccin-mocha
  catppuccin-latte
  catppuccin-frappe
  tokyo-night
  one-dark
  material-dark
  rose-pine
  rose-pine-moon
  everforest-dark
  kanagawa
  ayu-dark
  ayu-light
  palenight
  flexoki-dark
  nightfox
  modus-vivendi
)

# ── helpers ───────────────────────────────────────────────────────────────────

info()    { echo -e "\033[1;34m==>\033[0m $*"; }
success() { echo -e "\033[1;32m  ✓\033[0m $*"; }
warn()    { echo -e "\033[1;33m  !\033[0m $*"; }
error()   { echo -e "\033[1;31mERROR:\033[0m $*" >&2; }

download() {
  local url="$1"
  local dest="$2"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest"
  else
    error "Neither curl nor wget found. Please install one of them."
    exit 1
  fi
}

ensure_dir() { mkdir -p "$1"; }

# ── no argument → list available slugs ────────────────────────────────────────

if [[ $# -eq 0 ]]; then
  echo ""
  echo "  common-ressources rice themes"
  echo "  ─────────────────────────────"
  echo ""
  echo "  Usage: bash fetch.sh <slug>"
  echo ""
  echo "  Available themes:"
  for slug in "${AVAILABLE_SLUGS[@]}"; do
    echo "    • $slug"
  done
  echo ""
  echo "  Example:"
  echo "    bash <(curl -s ${RAW_BASE}/fetch.sh) dracula"
  echo ""
  exit 0
fi

SLUG="$1"

# Validate slug
VALID=false
for s in "${AVAILABLE_SLUGS[@]}"; do
  [[ "$s" == "$SLUG" ]] && VALID=true && break
done

if [[ "$VALID" == "false" ]]; then
  error "Unknown theme slug: '$SLUG'"
  echo ""
  echo "Available slugs:"
  for s in "${AVAILABLE_SLUGS[@]}"; do echo "  • $s"; done
  echo ""
  exit 1
fi

info "Fetching theme: $SLUG"
echo ""

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# ── download all config files ─────────────────────────────────────────────────

info "Downloading config files..."

download "${RAW_BASE}/alacritty/${SLUG}.toml"    "${TMPDIR}/${SLUG}-alacritty.toml"
download "${RAW_BASE}/kitty/${SLUG}.conf"         "${TMPDIR}/${SLUG}-kitty.conf"
download "${RAW_BASE}/hyprland/${SLUG}.conf"      "${TMPDIR}/${SLUG}-hyprland.conf"
download "${RAW_BASE}/waybar/${SLUG}.css"         "${TMPDIR}/${SLUG}-waybar.css"
download "${RAW_BASE}/rofi/${SLUG}.rasi"          "${TMPDIR}/${SLUG}-rofi.rasi"
download "${RAW_BASE}/dunst/${SLUG}.conf"         "${TMPDIR}/${SLUG}-dunst.conf"
download "${RAW_BASE}/wezterm/${SLUG}.lua"        "${TMPDIR}/${SLUG}-wezterm.lua"
download "${RAW_BASE}/helix/${SLUG}.toml"         "${TMPDIR}/${SLUG}-helix.toml"
download "${RAW_BASE}/foot/${SLUG}.ini"           "${TMPDIR}/${SLUG}-foot.ini"
download "${RAW_BASE}/nvim/${SLUG}.lua"           "${TMPDIR}/${SLUG}-nvim.lua"
download "${RAW_BASE}/fish/${SLUG}.fish"          "${TMPDIR}/${SLUG}-fish.fish"

success "All config files downloaded."
echo ""

# ── alacritty ─────────────────────────────────────────────────────────────────

ALACRITTY_DIR="${HOME}/.config/alacritty"
if ensure_dir "$ALACRITTY_DIR"; then
  cp "${TMPDIR}/${SLUG}-alacritty.toml" "${ALACRITTY_DIR}/colors.toml"

  # Ensure alacritty.toml imports colors.toml (add import line if missing)
  ALACRITTY_CONF="${ALACRITTY_DIR}/alacritty.toml"
  if [[ -f "$ALACRITTY_CONF" ]]; then
    if ! grep -q 'colors.toml' "$ALACRITTY_CONF"; then
      # Prepend import statement
      TMPFILE="$(mktemp)"
      echo '[general]' > "$TMPFILE"
      echo 'import = ["~/.config/alacritty/colors.toml"]' >> "$TMPFILE"
      echo '' >> "$TMPFILE"
      cat "$ALACRITTY_CONF" >> "$TMPFILE"
      mv "$TMPFILE" "$ALACRITTY_CONF"
      warn "Prepended import of colors.toml to alacritty.toml"
    fi
  else
    # Create a minimal alacritty.toml that imports colors
    cat > "$ALACRITTY_CONF" <<'EOF'
[general]
import = ["~/.config/alacritty/colors.toml"]
EOF
    warn "Created minimal alacritty.toml with color import."
  fi
  success "Alacritty → ${ALACRITTY_DIR}/colors.toml"
fi

# ── kitty ─────────────────────────────────────────────────────────────────────

KITTY_DIR="${HOME}/.config/kitty"
if ensure_dir "$KITTY_DIR"; then
  cp "${TMPDIR}/${SLUG}-kitty.conf" "${KITTY_DIR}/colors.conf"

  KITTY_CONF="${KITTY_DIR}/kitty.conf"
  if [[ -f "$KITTY_CONF" ]]; then
    if ! grep -q 'colors.conf' "$KITTY_CONF"; then
      echo "" >> "$KITTY_CONF"
      echo "# Rice theme colors" >> "$KITTY_CONF"
      echo "include colors.conf" >> "$KITTY_CONF"
      warn "Added 'include colors.conf' to kitty.conf"
    fi
  else
    echo "include colors.conf" > "$KITTY_CONF"
    warn "Created minimal kitty.conf with color include."
  fi
  success "Kitty → ${KITTY_DIR}/colors.conf"
fi

# ── hyprland ──────────────────────────────────────────────────────────────────

HYPR_DIR="${HOME}/.config/hypr"
if ensure_dir "$HYPR_DIR"; then
  cp "${TMPDIR}/${SLUG}-hyprland.conf" "${HYPR_DIR}/colors.conf"

  HYPR_CONF="${HYPR_DIR}/hyprland.conf"
  if [[ -f "$HYPR_CONF" ]]; then
    if ! grep -q 'colors.conf' "$HYPR_CONF"; then
      echo "" >> "$HYPR_CONF"
      echo "# Rice theme colors" >> "$HYPR_CONF"
      echo "source = ~/.config/hypr/colors.conf" >> "$HYPR_CONF"
      warn "Added 'source = colors.conf' to hyprland.conf"
    fi
  else
    echo "source = ~/.config/hypr/colors.conf" > "$HYPR_CONF"
    warn "Created minimal hyprland.conf with color source."
  fi
  success "Hyprland → ${HYPR_DIR}/colors.conf"
fi

# ── waybar ────────────────────────────────────────────────────────────────────

WAYBAR_DIR="${HOME}/.config/waybar"
if ensure_dir "$WAYBAR_DIR"; then
  cp "${TMPDIR}/${SLUG}-waybar.css" "${WAYBAR_DIR}/colors.css"
  success "Waybar → ${WAYBAR_DIR}/colors.css"
  warn "Add '@import url(\"colors.css\");' to the top of your waybar/style.css"
fi

# ── rofi ──────────────────────────────────────────────────────────────────────

ROFI_DIR="${HOME}/.config/rofi"
if ensure_dir "$ROFI_DIR"; then
  cp "${TMPDIR}/${SLUG}-rofi.rasi" "${ROFI_DIR}/colors.rasi"
  success "Rofi → ${ROFI_DIR}/colors.rasi"
  warn "Add '@import \"colors.rasi\";' to your rofi/config.rasi"
fi

# ── dunst ─────────────────────────────────────────────────────────────────────

DUNST_DIR="${HOME}/.config/dunst"
if ensure_dir "$DUNST_DIR"; then
  cp "${TMPDIR}/${SLUG}-dunst.conf" "${DUNST_DIR}/colors.conf"
  success "Dunst → ${DUNST_DIR}/colors.conf"

  DUNST_CONF="${DUNST_DIR}/dunstrc"
  if [[ -f "$DUNST_CONF" ]]; then
    if ! grep -q 'colors.conf' "$DUNST_CONF"; then
      warn "To apply dunst colors, copy the urgency blocks from ${DUNST_DIR}/colors.conf into your dunstrc manually."
    fi
  else
    warn "No dunstrc found. Manually copy urgency color blocks from ${DUNST_DIR}/colors.conf."
  fi
fi

# ── wezterm ───────────────────────────────────────────────────────────────────

WEZTERM_DIR="${HOME}/.config/wezterm"
if ensure_dir "$WEZTERM_DIR"; then
  cp "${TMPDIR}/${SLUG}-wezterm.lua" "${WEZTERM_DIR}/colors.lua"
  success "WezTerm → ${WEZTERM_DIR}/colors.lua  (manual step required)"
  echo ""
  warn "WezTerm requires a manual step. Add to your wezterm.lua:"
  echo ""
  echo '    local colors = require("colors")'
  echo '    config.colors = colors.colors'
  echo ""
fi

# ── helix ────────────────────────────────────────────────────────────────────

HELIX_THEMES_DIR="${HOME}/.config/helix/themes"
if ensure_dir "$HELIX_THEMES_DIR"; then
  cp "${TMPDIR}/${SLUG}-helix.toml" "${HELIX_THEMES_DIR}/${SLUG}.toml"
  success "Helix → ${HELIX_THEMES_DIR}/${SLUG}.toml"
  warn "Add 'theme = \"${SLUG}\"' to your ~/.config/helix/config.toml"
fi

# ── foot ──────────────────────────────────────────────────────────────────────

FOOT_THEMES_DIR="${HOME}/.config/foot/themes"
if ensure_dir "$FOOT_THEMES_DIR"; then
  cp "${TMPDIR}/${SLUG}-foot.ini" "${FOOT_THEMES_DIR}/${SLUG}.ini"
  success "Foot → ${FOOT_THEMES_DIR}/${SLUG}.ini"
  warn "Add 'include=~/.config/foot/themes/${SLUG}.ini' to your foot.ini [colors] section"
fi

# ── neovim ────────────────────────────────────────────────────────────────────

NVIM_COLORS_DIR="${HOME}/.config/nvim/colors"
if ensure_dir "$NVIM_COLORS_DIR"; then
  cp "${TMPDIR}/${SLUG}-nvim.lua" "${NVIM_COLORS_DIR}/${SLUG}.lua"
  success "Neovim → ${NVIM_COLORS_DIR}/${SLUG}.lua"
  warn "Run ':colorscheme ${SLUG}' in Neovim, or add 'vim.cmd.colorscheme(\"${SLUG}\")' to your init.lua"
fi

# ── fish ──────────────────────────────────────────────────────────────────────

FISH_THEMES_DIR="${HOME}/.config/fish/themes"
if ensure_dir "$FISH_THEMES_DIR"; then
  cp "${TMPDIR}/${SLUG}-fish.fish" "${FISH_THEMES_DIR}/${SLUG}.fish"
  success "Fish → ${FISH_THEMES_DIR}/${SLUG}.fish"
  warn "Add 'source ~/.config/fish/themes/${SLUG}.fish' to your config.fish"
fi

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Theme '$SLUG' applied!"
echo ""
echo "  Files written:"
echo "    ~/.config/alacritty/colors.toml"
echo "    ~/.config/kitty/colors.conf"
echo "    ~/.config/hypr/colors.conf"
echo "    ~/.config/waybar/colors.css"
echo "    ~/.config/rofi/colors.rasi"
echo "    ~/.config/dunst/colors.conf"
echo "    ~/.config/wezterm/colors.lua"
echo "    ~/.config/helix/themes/${SLUG}.toml"
echo "    ~/.config/foot/themes/${SLUG}.ini"
echo "    ~/.config/nvim/colors/${SLUG}.lua"
echo "    ~/.config/fish/themes/${SLUG}.fish"
echo ""
echo "  Restart your terminals / reload your compositor"
echo "  to see the new colors take effect."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
