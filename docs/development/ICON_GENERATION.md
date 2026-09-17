# Icon generation

Generate app icons and splash images from `assets/svg/logo-rgb.svg` plus JSON config.

## Files

- **Source SVG**: `assets/svg/logo-rgb.svg` (also listed as `svg_source` in the config)
- **Config**: `assets/svg/logo-rgb.svg.json`
- **Script**: `tools/generate-icons.sh`
- **Master PNGs**: `assets/png/logo-*.png` (generated)
- **Android**: `android/app/src/main/res/`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (including dark/tinted + `Contents.json`)

## Config

Each icon variant sets canvas size, root-group transform, and CSS class fills:

```json
{
  "svg_source": "assets/svg/logo-rgb.svg",
  "icons": [
    {
      "name": "dark-mode-launcher",
      "display_name": "Dark Mode Launcher",
      "width": 1024,
      "height": 1024,
      "translate_x": 122.4,
      "translate_y": 122.4,
      "scale": 0.7,
      "colors": {
        "shape": "#eee",
        "wave": "#111",
        "mic": "#111",
        "sliders": "#111",
        "text": "#111"
      }
    }
  ]
}
```

`android` / `ios` blocks map those variants to launcher, monochrome, splash, and iOS light/dark/tinted.

## Usage

```bash
make gen-assets
```

Optional config path:

```bash
bash tools/generate-icons.sh assets/svg/logo-rgb.svg.json
```

## Dependencies

- **rsvg-convert** (`librsvg`)
- **jq**
- **python3**
- **awk**
- **sips** (macOS) or ImageMagick (`magick` / `convert`)

## How it works

1. Read `assets/svg/logo-rgb.svg.json`.
2. For each icon, rewrite the first SVG `width`/`height` and the first root `<g transform="translate(...)scale(...)">`, then class fills.
3. Rasterize with `rsvg-convert`.
4. Resize into Android densities and iOS icon slots.
5. Write iOS `Contents.json` with light + dark + tinted appearances.

## Adding a variant

1. Add an entry to `icons` in `assets/svg/logo-rgb.svg.json`.
2. Point `android` / `ios` at it if it should ship as a launcher or splash.
3. Run `make gen-assets`.
