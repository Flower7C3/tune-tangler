# Icon Generation System

This document describes the automated icon generation system for TuneTangler.

## Overview

The system generates multiple PNG variants from a single SVG source file (`logo-rgb.svg`) using configuration-driven approach with JSON files. The source SVG contains clipPath masks and uses fill attributes for Flutter compatibility.

## Files

- **Source**: Defined in `assets/icon-config.json` (`svg_source` field) - Master SVG file with clipPath masks and fill attributes
- **Configuration**: `assets/icon-config.json` - JSON configuration defining source SVG and all icon variants
- **Output**: `assets/png/logo-*.png` - Generated PNG files (ignored by git)

## Configuration Format

The `assets/icon-config.json` file contains source SVG path and an array of icon configurations:

```json
{
  "svg_source": "assets/svg/logo-rgb.svg",
  "icons": [
    {
      "name": "dark-mode-launcher",
      "display_name": "Dark Mode Launcher",
      "width": 1152,
      "height": 1152,
      "viewbox": "0 0 1152 1152",
      "translate_x": 168,
      "translate_y": 168,
      "scale": 1.0,
      "shape_color": "#eee",
      "wave_color": "#111",
      "mic_color": "#111",
      "sliders_color": "#111",
      "text_color": "#111"
    }
  ]
}
```

### Configuration Parameters

- **svg_source**: Path to the source SVG file
- **name**: Output filename (without extension)
- **display_name**: Human-readable name for logging
- **width/height**: PNG output dimensions
- **translate_x/translate_y**: Logo container translation (centers logo in target dimensions)
- **scale**: Logo scaling factor
- **shape_color**: Background shape color (#00ff00 in source)
- **text_color**: Detail elements color (#0000ff in source, used for wave, mic, sliders, text)

## Usage

### Generate All Icons
```bash
make gen-png-logos
```

### Generate All Images (including app icons and splash)
```bash
make gen-images
```

## Dependencies

- **rsvg-convert**: SVG to PNG conversion
  - Ubuntu/Debian: `sudo apt-get install librsvg2-bin`
  - macOS: `brew install librsvg`
  - Windows: Download from [GitHub](https://github.com/miyako/console-rsvg-convert)

- **jq**: JSON processing
  - Ubuntu/Debian: `sudo apt-get install jq`
  - macOS: `brew install jq`
  - Windows: Download from [jqlang.github.io](https://jqlang.github.io/jq/download/)

## How It Works

1. **Configuration Parsing**: Reads `assets/icon-config.json` and processes each icon definition
2. **Temporary Directory**: Creates a unique temporary directory using `mktemp -d -t tunetangler-icons-XXXXXX`
3. **SVG Generation**: For each icon, creates a temporary SVG file by:
   - Replacing dimensions and viewBox
   - Updating main container transform with translate and scale values
   - Replacing fill color attributes
4. **PNG Conversion**: Converts temporary SVG files to PNG using `rsvg-convert`
5. **Cleanup**: Automatically removes the entire temporary directory and all files

## Adding New Icon Variants

To add a new icon variant:

1. Add a new entry to the `icons` array in `assets/icon-config.json`
2. Run `make gen-png-logos`
3. The new PNG file will be generated as `assets/png/logo-{name}.png`

## Benefits

- **Configuration-driven**: Easy to add/modify icon variants
- **Consistent**: All variants use the same source SVG
- **Maintainable**: Single source of truth for logo design
- **Automated**: No manual image editing required
- **Version controlled**: Configuration can be tracked in git
- **Safe**: Uses system temporary directories with automatic cleanup
- **Efficient**: No temporary files left in the project directory
- **Robust**: Uses `mktemp` for unique temporary directory creation

## Security and Best Practices

- **Temporary Files**: Uses system temporary directory (`/tmp/`) with unique names
- **Automatic Cleanup**: No temporary files are left behind after execution
- **No Hardcoded Paths**: All paths are configurable through JSON
- **Error Handling**: Proper error messages for missing dependencies
- **Atomic Operations**: Each icon is generated and converted in one operation
