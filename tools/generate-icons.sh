#!/usr/bin/env bash
set -euo pipefail

# Generate launcher icons, adaptive icons (light/dark/monochrome), and splash
# screens for Android and iOS from a single SVG source + JSON configuration.
#
# Dependencies: rsvg-convert (librsvg), jq, awk, python3
# Resize/pad: sips (macOS) or ImageMagick (`magick` / `convert`)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="${1:-assets/svg/logo-rgb.svg.json}"
CONFIG_PATH="$PROJECT_DIR/$CONFIG_FILE"

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "❌ Config file not found: $CONFIG_PATH"
  exit 1
fi

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Required tool not found: $1"
    exit 1
  fi
}

need_cmd rsvg-convert
need_cmd jq
need_cmd awk
need_cmd python3

RESIZE_TOOL=""
if command -v sips >/dev/null 2>&1; then
  RESIZE_TOOL="sips"
elif command -v magick >/dev/null 2>&1; then
  RESIZE_TOOL="magick"
elif command -v convert >/dev/null 2>&1; then
  RESIZE_TOOL="convert"
else
  echo "❌ Need sips (macOS) or ImageMagick (magick/convert)"
  exit 1
fi

SVG_SOURCE="$PROJECT_DIR/$(jq -r '.svg_source' "$CONFIG_PATH")"
PNG_DIR="$PROJECT_DIR/assets/png"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

if [[ ! -f "$SVG_SOURCE" ]]; then
  echo "❌ SVG source not found: $SVG_SOURCE"
  exit 1
fi

# Android density multipliers (baseline 1x = mdpi)
declare -A DENSITY_MULT=( [mdpi]=1 [hdpi]=1.5 [xhdpi]=2 [xxhdpi]=3 [xxxhdpi]=4 )
DENSITIES=(mdpi hdpi xhdpi xxhdpi xxxhdpi)

ANDROID_ADAPTIVE_BASE=108  # dp
ANDROID_LAUNCHER_BASE=48   # dp
ANDROID_SPLASH_BASE=288    # px at mdpi
# Android 12+ splash icon is masked to a 160dp circle inside 288dp canvas.
# Icon must fit within that circle, so we render it at 160/288 ≈ 55.6% of canvas.
ANDROID12_SPLASH_ICON_RATIO=0.556

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

scale_px() {
  awk -v b="$1" -v m="$2" 'BEGIN { printf "%d", int(b * m + 0.0001) }'
}

render_svg_variant() {
  local icon_name="$1"
  local out_png="$2"
  local out_w="$3"
  local out_h="$4"

  local icon_data
  icon_data=$(jq -c --arg name "$icon_name" '.icons[] | select(.name == $name)' "$CONFIG_PATH")
  if [[ -z "$icon_data" || "$icon_data" == "null" ]]; then
    echo "❌ Icon variant not found in config: $icon_name"
    exit 1
  fi

  local temp_svg="$TEMP_DIR/${icon_name}.svg"
  python3 - "$SVG_SOURCE" "$temp_svg" "$icon_data" <<'PY'
import json, re, sys

src, dst, raw = sys.argv[1], sys.argv[2], sys.argv[3]
icon = json.loads(raw)
text = open(src, encoding="utf-8").read()
w, h = icon["width"], icon["height"]
tx, ty, sc = icon["translate_x"], icon["translate_y"], icon["scale"]
text, n = re.subn(
    r'width="[\d.]+"\s+height="[\d.]+"',
    f'width="{w}" height="{h}"',
    text,
    count=1,
)
if n != 1:
    raise SystemExit("Could not replace SVG width/height")
text, n = re.subn(
    r'(<g transform=")translate\([^"]*\)scale\([^"]*\)(">)',
    rf"\1translate({tx} {ty})scale({sc})\2",
    text,
    count=1,
)
if n != 1:
    raise SystemExit("Could not replace root SVG transform")
for cls, color in icon.get("colors", {}).items():
    text, n = re.subn(
        rf'class="{re.escape(cls)}" fill="[^"]*"',
        f'fill="{color}"',
        text,
    )
    if n == 0:
        raise SystemExit(f"No fill for class={cls}")
open(dst, "w", encoding="utf-8").write(text)
PY
  rsvg-convert -h "$out_h" -w "$out_w" "$temp_svg" -o "$out_png"
}

resize_png() {
  local src="$1" dst="$2" size="$3"
  case "$RESIZE_TOOL" in
    sips)
      sips -z "$size" "$size" "$src" --out "$dst" >/dev/null
      ;;
    magick)
      magick "$src" -resize "${size}x${size}" "$dst"
      ;;
    convert)
      convert "$src" -resize "${size}x${size}" "$dst"
      ;;
  esac
}

pad_png() {
  local src="$1" dst="$2" size="$3" hex_color="$4"
  case "$RESIZE_TOOL" in
    sips)
      sips --padToHeightWidth "$size" "$size" --padColor "$hex_color" "$src" --out "$dst" >/dev/null
      ;;
    magick)
      magick "$src" -background "#${hex_color}" -gravity center -extent "${size}x${size}" "$dst"
      ;;
    convert)
      convert "$src" -background "#${hex_color}" -gravity center -extent "${size}x${size}" "$dst"
      ;;
  esac
}

ensure_dir() {
  mkdir -p "$1"
}

write_ios_contents_json() {
  local dest="$1/Contents.json"
  python3 - "$dest" <<'PY'
import json, sys

dest = sys.argv[1]

def img(size, idiom, filename, scale, *, platform=None, appearance=None):
    entry = {
        "size": size,
        "idiom": idiom,
        "filename": filename,
        "scale": scale,
    }
    if platform:
        entry["platform"] = platform
    if appearance:
        entry["appearances"] = [{"appearance": "luminosity", "value": appearance}]
    return entry

images = [
    img("20x20", "iphone", "Icon-App-20x20@2x.png", "2x"),
    img("20x20", "iphone", "Icon-App-20x20@3x.png", "3x"),
    img("29x29", "iphone", "Icon-App-29x29@1x.png", "1x"),
    img("29x29", "iphone", "Icon-App-29x29@2x.png", "2x"),
    img("29x29", "iphone", "Icon-App-29x29@3x.png", "3x"),
    img("40x40", "iphone", "Icon-App-40x40@2x.png", "2x"),
    img("40x40", "iphone", "Icon-App-40x40@3x.png", "3x"),
    img("57x57", "iphone", "Icon-App-57x57@1x.png", "1x"),
    img("57x57", "iphone", "Icon-App-57x57@2x.png", "2x"),
    img("60x60", "iphone", "Icon-App-60x60@2x.png", "2x"),
    img("60x60", "iphone", "Icon-App-60x60@3x.png", "3x"),
    img("20x20", "ipad", "Icon-App-20x20@1x.png", "1x"),
    img("20x20", "ipad", "Icon-App-20x20@2x.png", "2x"),
    img("29x29", "ipad", "Icon-App-29x29@1x.png", "1x"),
    img("29x29", "ipad", "Icon-App-29x29@2x.png", "2x"),
    img("40x40", "ipad", "Icon-App-40x40@1x.png", "1x"),
    img("40x40", "ipad", "Icon-App-40x40@2x.png", "2x"),
    img("50x50", "ipad", "Icon-App-50x50@1x.png", "1x"),
    img("50x50", "ipad", "Icon-App-50x50@2x.png", "2x"),
    img("72x72", "ipad", "Icon-App-72x72@1x.png", "1x"),
    img("72x72", "ipad", "Icon-App-72x72@2x.png", "2x"),
    img("76x76", "ipad", "Icon-App-76x76@1x.png", "1x"),
    img("76x76", "ipad", "Icon-App-76x76@2x.png", "2x"),
    img("83.5x83.5", "ipad", "Icon-App-83.5x83.5@2x.png", "2x"),
    img("1024x1024", "ios-marketing", "Icon-App-1024x1024@1x.png", "1x"),
]

dark_tinted = [
    ("20x20", "2x"),
    ("20x20", "3x"),
    ("29x29", "2x"),
    ("29x29", "3x"),
    ("38x38", "2x"),
    ("38x38", "3x"),
    ("40x40", "2x"),
    ("40x40", "3x"),
    ("60x60", "2x"),
    ("60x60", "3x"),
    ("64x64", "2x"),
    ("64x64", "3x"),
    ("68x68", "2x"),
    ("76x76", "2x"),
    ("83.5x83.5", "2x"),
    ("1024x1024", "1x"),
]

for size, scale in dark_tinted:
    images.append(
        img(
            size,
            "universal",
            f"Icon-App-Dark-{size}@{scale}.png",
            scale,
            platform="ios",
            appearance="dark",
        )
    )
    images.append(
        img(
            size,
            "universal",
            f"Icon-App-Tinted-{size}@{scale}.png",
            scale,
            platform="ios",
            appearance="tinted",
        )
    )

with open(dest, "w", encoding="utf-8") as fh:
    json.dump({"images": images, "info": {"version": 1, "author": "xcode"}}, fh, indent=2)
    fh.write("\n")
PY
}

# ─── Step 1: Generate master PNGs ────────────────────────────────────────────

ensure_dir "$PNG_DIR"
echo "🎨 Generating master PNGs from SVG..."
while read -r name; do
  local_w=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .width' "$CONFIG_PATH")
  local_h=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .height' "$CONFIG_PATH")
  display=$(jq -r --arg n "$name" '.icons[] | select(.name == $n) | .display_name' "$CONFIG_PATH")
  out="$PNG_DIR/logo-${name}.png"
  echo "  • $display → $out"
  render_svg_variant "$name" "$out" "$local_w" "$local_h"
done < <(jq -r '.icons[].name' "$CONFIG_PATH")

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

  for density in "${DENSITIES[@]}"; do
    local mult=${DENSITY_MULT[$density]}
    local adaptive_px launcher_px
    adaptive_px=$(scale_px "$ANDROID_ADAPTIVE_BASE" "$mult")
    launcher_px=$(scale_px "$ANDROID_LAUNCHER_BASE" "$mult")

    local fg_dir="$ANDROID_RES/drawable-${qualifier}${density}"
    local mipmap_dir="$ANDROID_RES/mipmap-${qualifier}${density}"
    ensure_dir "$fg_dir"
    ensure_dir "$mipmap_dir"

    resize_png "$master_png" "$fg_dir/ic_launcher_foreground.png" "$adaptive_px"
    resize_png "$master_png" "$mipmap_dir/ic_launcher.png" "$launcher_px"
  done

  local values_dir="$ANDROID_RES/values"
  [[ -n "$qualifier" ]] && values_dir="$ANDROID_RES/values-${qualifier%%-}"
  ensure_dir "$values_dir"
  cat > "$values_dir/colors.xml" <<XMLEOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">$bg_color</color>
</resources>
XMLEOF

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

generate_android_adaptive "light" ""
generate_android_adaptive "dark" "night-"

mono_name=$(jq -r '.android.launcher.monochrome' "$CONFIG_PATH")
mono_png="$PNG_DIR/logo-${mono_name}.png"
echo "  [monochrome] $mono_name"
for density in "${DENSITIES[@]}"; do
  mult=${DENSITY_MULT[$density]}
  adaptive_px=$(scale_px "$ANDROID_ADAPTIVE_BASE" "$mult")
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
    local splash_px icon_px
    splash_px=$(scale_px "$ANDROID_SPLASH_BASE" "$mult")
    local dir="$ANDROID_RES/drawable-${qualifier}${density}"
    ensure_dir "$dir"

    resize_png "$master_png" "$dir/splash.png" "$splash_px"

    icon_px=$(scale_px "$splash_px" "$ANDROID12_SPLASH_ICON_RATIO")
    local a12_tmp="$TEMP_DIR/a12_${variant}_${density}.png"
    resize_png "$master_png" "$a12_tmp" "$icon_px"
    local hex_color="${bg_color#\#}"
    pad_png "$a12_tmp" "$dir/android12splash.png" "$splash_px" "$hex_color"
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

echo "  [light] $ios_light_name"
for i in "${!IOS_FILENAMES[@]}"; do
  resize_png "$ios_light_png" "$IOS_DIR/${IOS_FILENAMES[$i]}" "${IOS_PX[$i]}"
done

echo "  [dark] $ios_dark_name"
for i in "${!IOS_DARK_FILENAMES[@]}"; do
  resize_png "$ios_dark_png" "$IOS_DIR/${IOS_DARK_FILENAMES[$i]}" "${IOS_DARK_PX[$i]}"
done

echo "  [tinted] $ios_tinted_name"
for i in "${!IOS_TINTED_FILENAMES[@]}"; do
  resize_png "$ios_tinted_png" "$IOS_DIR/${IOS_TINTED_FILENAMES[$i]}" "${IOS_TINTED_PX[$i]}"
done

write_ios_contents_json "$IOS_DIR"

echo ""
echo "✅ All icons and splash screens generated successfully!"
