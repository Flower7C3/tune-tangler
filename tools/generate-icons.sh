#!/usr/bin/env bash
set -euo pipefail

# Generate launcher icons, adaptive icons (light/dark/monochrome), and splash
# screens for Android and iOS from a single SVG source + JSON configuration.
#
# Dependencies: rsvg-convert (librsvg), jq, sips (macOS) or ImageMagick

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="${1:-assets/svg/logo-rgb.svg.json}"
CONFIG_PATH="$PROJECT_DIR/$CONFIG_FILE"

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "❌ Config file not found: $CONFIG_PATH"
  exit 1
fi

for cmd in rsvg-convert jq sips; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ Required tool not found: $cmd"
    exit 1
  fi
done

SVG_SOURCE="$PROJECT_DIR/$(jq -r '.svg_source' "$CONFIG_PATH")"
PNG_DIR="$PROJECT_DIR/assets/png"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Android density multipliers (baseline 1x = mdpi)
declare -A DENSITY_MULT=( [mdpi]=1 [hdpi]=1.5 [xhdpi]=2 [xxhdpi]=3 [xxxhdpi]=4 )
DENSITIES=(mdpi hdpi xhdpi xxhdpi xxxhdpi)

ANDROID_ADAPTIVE_BASE=108  # dp
ANDROID_LAUNCHER_BASE=48   # dp
ANDROID_SPLASH_BASE=288    # px at mdpi
# Android 12+ splash icon is masked to a 160dp circle inside 288dp canvas.
# Icon must fit within that circle, so we render it at 160/288 ≈ 55.6% of canvas.
ANDROID12_SPLASH_ICON_RATIO=0.556

# iOS icon pixel sizes (already multiplied)
IOS_SIZES=(20 40 29 58 87 40 80 120 57 114 120 180 1024)
IOS_FILENAMES=(
  "Icon-App-20x20@1x.png"   "Icon-App-20x20@2x.png"   "Icon-App-20x20@3x.png"
  "Icon-App-29x29@1x.png"   "Icon-App-29x29@2x.png"   "Icon-App-29x29@3x.png"
  "Icon-App-40x40@1x.png"   "Icon-App-40x40@2x.png"   "Icon-App-40x40@3x.png"
  "Icon-App-57x57@1x.png"   "Icon-App-57x57@2x.png"
  "Icon-App-60x60@2x.png"   "Icon-App-60x60@3x.png"
  "Icon-App-50x50@1x.png"   "Icon-App-50x50@2x.png"
  "Icon-App-72x72@1x.png"   "Icon-App-72x72@2x.png"
  "Icon-App-76x76@1x.png"   "Icon-App-76x76@2x.png"
  "Icon-App-83.5x83.5@2x.png"
  "Icon-App-1024x1024@1x.png"
)
IOS_PX=(
  20  40  60
  29  58  87
  40  80  120
  57  114
  120 180
  50  100
  72  144
  76  152
  167
  1024
)

IOS_DARK_FILENAMES=(
  "Icon-App-Dark-20x20@2x.png"   "Icon-App-Dark-20x20@3x.png"
  "Icon-App-Dark-29x29@2x.png"   "Icon-App-Dark-29x29@3x.png"
  "Icon-App-Dark-38x38@2x.png"   "Icon-App-Dark-38x38@3x.png"
  "Icon-App-Dark-40x40@2x.png"   "Icon-App-Dark-40x40@3x.png"
  "Icon-App-Dark-60x60@2x.png"   "Icon-App-Dark-60x60@3x.png"
  "Icon-App-Dark-64x64@2x.png"   "Icon-App-Dark-64x64@3x.png"
  "Icon-App-Dark-68x68@2x.png"
  "Icon-App-Dark-76x76@2x.png"
  "Icon-App-Dark-83.5x83.5@2x.png"
  "Icon-App-Dark-1024x1024@1x.png"
)
IOS_DARK_PX=(
  40  60
  58  87
  76  114
  80  120
  120 180
  128 192
  136
  152
  167
  1024
)

IOS_TINTED_FILENAMES=(
  "Icon-App-Tinted-20x20@2x.png"   "Icon-App-Tinted-20x20@3x.png"
  "Icon-App-Tinted-29x29@2x.png"   "Icon-App-Tinted-29x29@3x.png"
  "Icon-App-Tinted-38x38@2x.png"   "Icon-App-Tinted-38x38@3x.png"
  "Icon-App-Tinted-40x40@2x.png"   "Icon-App-Tinted-40x40@3x.png"
  "Icon-App-Tinted-60x60@2x.png"   "Icon-App-Tinted-60x60@3x.png"
  "Icon-App-Tinted-64x64@2x.png"   "Icon-App-Tinted-64x64@3x.png"
  "Icon-App-Tinted-68x68@2x.png"
  "Icon-App-Tinted-76x76@2x.png"
  "Icon-App-Tinted-83.5x83.5@2x.png"
  "Icon-App-Tinted-1024x1024@1x.png"
)
IOS_TINTED_PX=(
  40  60
  58  87
  76  114
  80  120
  120 180
  128 192
  136
  152
  167
  1024
)

# ─── Helpers ──────────────────────────────────────────────────────────────────

render_svg_variant() {
  local icon_name="$1"
  local out_png="$2"
  local out_w="$3"
  local out_h="$4"

  local icon_data
  icon_data=$(jq -r --arg name "$icon_name" '.icons[] | select(.name == $name)' "$CONFIG_PATH")

  local svg_w svg_h tx ty sc
  svg_w=$(echo "$icon_data" | jq -r '.width')
  svg_h=$(echo "$icon_data" | jq -r '.height')
  tx=$(echo "$icon_data" | jq -r '.translate_x')
  ty=$(echo "$icon_data" | jq -r '.translate_y')
  sc=$(echo "$icon_data" | jq -r '.scale')

  local sed_cmd="s|width=\"1500\" height=\"1500\"|width=\"${svg_w}\" height=\"${svg_h}\"|g"
  sed_cmd+="; s|translate(0 0)scale(1)|translate(${tx} ${ty})scale(${sc})|g"

  local color_rules
  color_rules=$(echo "$icon_data" | jq -r '.colors | to_entries[] | "s|class=\\\"" + .key + "\\\" fill=\\\"[^\\\"]*\\\"|fill=\\\"" + .value + "\\\"|g"' | tr '\n' ';')
  sed_cmd+="; $color_rules"

  local temp_svg="$TEMP_DIR/${icon_name}.svg"
  sed -e "$sed_cmd" "$SVG_SOURCE" > "$temp_svg"
  rsvg-convert -h "$out_h" -w "$out_w" "$temp_svg" -o "$out_png"
}

resize_png() {
  local src="$1" dst="$2" size="$3"
  sips -z "$size" "$size" "$src" --out "$dst" >/dev/null 2>&1
}

ensure_dir() {
  mkdir -p "$1"
}

# ─── Step 1: Generate master PNGs ────────────────────────────────────────────

echo "🎨 Generating master PNGs from SVG..."
jq -r '.icons[].name' "$CONFIG_PATH" | while read -r name; do
  local_w=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .width' "$CONFIG_PATH")
  local_h=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .height' "$CONFIG_PATH")
  display=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .display_name' "$CONFIG_PATH")
  out="$PNG_DIR/logo-${name}.png"
  echo "  • $display → $out"
  render_svg_variant "$name" "$out" "$local_w" "$local_h"
done

# ─── Step 2: Android Launcher Icons ─────────────────────────────────────────

ANDROID_RES="$PROJECT_DIR/$(jq -r '.android.res_dir' "$CONFIG_PATH")"
ADAPTIVE_INSET=$(jq -r '.android.adaptive_icon_inset' "$CONFIG_PATH")

echo ""
echo "📱 Generating Android launcher icons..."

generate_android_adaptive() {
  local variant="$1"    # light | dark
  local qualifier="$2"  # "" | "night-"
  local fg_name bg_color

  fg_name=$(jq -r ".android.launcher.${variant}.foreground" "$CONFIG_PATH")
  bg_color=$(jq -r ".android.launcher.${variant}.background_color" "$CONFIG_PATH")
  local master_png="$PNG_DIR/logo-${fg_name}.png"

  echo "  [$variant] foreground=$fg_name background=$bg_color"

  # Foreground PNGs for each density
  for density in "${DENSITIES[@]}"; do
    local mult=${DENSITY_MULT[$density]}
    local adaptive_px=$(echo "$ANDROID_ADAPTIVE_BASE * $mult" | bc | cut -d. -f1)
    local launcher_px=$(echo "$ANDROID_LAUNCHER_BASE * $mult" | bc | cut -d. -f1)

    local fg_dir="$ANDROID_RES/drawable-${qualifier}${density}"
    local mipmap_dir="$ANDROID_RES/mipmap-${qualifier}${density}"
    ensure_dir "$fg_dir"
    ensure_dir "$mipmap_dir"

    resize_png "$master_png" "$fg_dir/ic_launcher_foreground.png" "$adaptive_px"
    resize_png "$master_png" "$mipmap_dir/ic_launcher.png" "$launcher_px"
  done

  # colors.xml
  local values_dir="$ANDROID_RES/values"
  [[ -n "$qualifier" ]] && values_dir="$ANDROID_RES/values-${qualifier%%-}"
  ensure_dir "$values_dir"
  cat > "$values_dir/colors.xml" <<XMLEOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">$bg_color</color>
</resources>
XMLEOF

  # Adaptive icon XML
  local mipmap_v26="$ANDROID_RES/mipmap-${qualifier}anydpi-v26"
  ensure_dir "$mipmap_v26"
  cat > "$mipmap_v26/ic_launcher.xml" <<XMLEOF
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="$ADAPTIVE_INSET" />
  </foreground>
  <monochrome>
      <inset
          android:drawable="@drawable/ic_launcher_monochrome"
          android:inset="$ADAPTIVE_INSET" />
  </monochrome>
</adaptive-icon>
XMLEOF
}

# Light (default)
generate_android_adaptive "light" ""

# Dark (night qualifier)
generate_android_adaptive "dark" "night-"

# Monochrome
mono_name=$(jq -r '.android.launcher.monochrome' "$CONFIG_PATH")
mono_png="$PNG_DIR/logo-${mono_name}.png"
echo "  [monochrome] $mono_name"
for density in "${DENSITIES[@]}"; do
  mult=${DENSITY_MULT[$density]}
  adaptive_px=$(echo "$ANDROID_ADAPTIVE_BASE * $mult" | bc | cut -d. -f1)
  fg_dir="$ANDROID_RES/drawable-${density}"
  ensure_dir "$fg_dir"
  resize_png "$mono_png" "$fg_dir/ic_launcher_monochrome.png" "$adaptive_px"
done

# ─── Step 3: Android Splash Screens ─────────────────────────────────────────

echo ""
echo "💦 Generating Android splash screens..."

generate_android_splash() {
  local variant="$1"    # light | dark
  local qualifier="$2"  # "" | "night-"

  local img_name bg_color
  img_name=$(jq -r ".android.splash.${variant}.image" "$CONFIG_PATH")
  bg_color=$(jq -r ".android.splash.${variant}.background_color" "$CONFIG_PATH")
  local master_png="$PNG_DIR/logo-${img_name}.png"

  echo "  [$variant] image=$img_name background=$bg_color"

  for density in "${DENSITIES[@]}"; do
    local mult=${DENSITY_MULT[$density]}
    local splash_px=$(echo "$ANDROID_SPLASH_BASE * $mult" | bc | cut -d. -f1)
    local dir="$ANDROID_RES/drawable-${qualifier}${density}"
    ensure_dir "$dir"

    resize_png "$master_png" "$dir/splash.png" "$splash_px"

    # Android 12+: icon is masked to a circle, so render smaller and pad
    local icon_px=$(echo "$splash_px * $ANDROID12_SPLASH_ICON_RATIO" | bc | cut -d. -f1)
    local a12_tmp="$TEMP_DIR/a12_${variant}_${density}.png"
    resize_png "$master_png" "$a12_tmp" "$icon_px"
    local hex_color="${bg_color#\#}"
    sips --padToHeightWidth "$splash_px" "$splash_px" --padColor "$hex_color" "$a12_tmp" --out "$dir/android12splash.png" >/dev/null 2>&1
  done
}

generate_android_splash "light" ""
generate_android_splash "dark" "night-"

# ─── Step 4: iOS Icons ──────────────────────────────────────────────────────

echo ""
echo "🍎 Generating iOS icons..."

IOS_DIR="$PROJECT_DIR/$(jq -r '.ios.assets_dir' "$CONFIG_PATH")"
ensure_dir "$IOS_DIR"

ios_light_name=$(jq -r '.ios.launcher.light' "$CONFIG_PATH")
ios_dark_name=$(jq -r '.ios.launcher.dark' "$CONFIG_PATH")
ios_tinted_name=$(jq -r '.ios.launcher.tinted' "$CONFIG_PATH")

ios_light_png="$PNG_DIR/logo-${ios_light_name}.png"
ios_dark_png="$PNG_DIR/logo-${ios_dark_name}.png"
ios_tinted_png="$PNG_DIR/logo-${ios_tinted_name}.png"

# Light icons
echo "  [light] $ios_light_name"
for i in "${!IOS_FILENAMES[@]}"; do
  resize_png "$ios_light_png" "$IOS_DIR/${IOS_FILENAMES[$i]}" "${IOS_PX[$i]}"
done

# Dark icons
echo "  [dark] $ios_dark_name"
for i in "${!IOS_DARK_FILENAMES[@]}"; do
  resize_png "$ios_dark_png" "$IOS_DIR/${IOS_DARK_FILENAMES[$i]}" "${IOS_DARK_PX[$i]}"
done

# Tinted icons
echo "  [tinted] $ios_tinted_name"
for i in "${!IOS_TINTED_FILENAMES[@]}"; do
  resize_png "$ios_tinted_png" "$IOS_DIR/${IOS_TINTED_FILENAMES[$i]}" "${IOS_TINTED_PX[$i]}"
done

echo ""
echo "✅ All icons and splash screens generated successfully!"
