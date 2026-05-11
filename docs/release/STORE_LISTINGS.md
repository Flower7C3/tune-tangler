# 🏪 Store listings & screenshots (Play, Fastlane, F-Droid)

## Text listings (source of truth)

Edit the **plain-text** files under:

`fastlane/metadata/android/<locale>/`

For each locale (e.g. **`en-US`**, **`pl-PL`**) keep:

- `title.txt` — store title (Google Play max **30** characters)
- `short_description.txt` — short blurb (Play max **80** characters)
- `full_description.txt` — long description (Play max **~4000** characters)

No Markdown in these files: Play Console treats them as plain text.

### Google Play Console

Copy from the `.txt` files above, or use **Fastlane supply** / Play Developer API pointing at the same paths.

### F-Droid (multiple languages)

F-Droid reads **Fastlane / Triple-T** files from **your app’s source tree at the release revision** (see [All About Descriptions, Graphics, and Screenshots](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/)). Texts in **`metadata/<packageId>.yml` on fdroiddata** override those files — Tune Tangler’s `publish_fdroid_gitlab_branch.py` and `metadata_static.yml` omit `Summary` / `Description` / `Name` / `AutoName` so listings stay sourced from `fastlane/metadata/android/` here.

Add another folder under `fastlane/metadata/android/` for each extra locale (same three filenames).

---

## Screenshots

Captured files live next to the text metadata, under Fastlane **images** folders (Play / F-Droid):

`fastlane/metadata/android/<locale>/images/<bucket>/`

- **`phoneScreenshots/`** — default when `DEVICE_NAME` is a phone (e.g. `phone`, `pixel9`, …)
- **`sevenInchScreenshots/`** — when `DEVICE_NAME` contains **`tablet7`**
- **`tenInchScreenshots/`** — when `DEVICE_NAME` contains **`tablet10`**

Locale folders follow BCP-47 (`en-US`, `pl-PL`, …). In **`tools/screenshots.json`**, **`locale_map`** is the only list: each **key** is sent to the app (`setLocale`), each **value** is the Fastlane directory name under `fastlane/metadata/android/`. Add a key/value pair per locale you capture.

Filenames from the script:

`{file_prefix}-{device}-{theme}-{index}-{screen}.png`  
(e.g. `tune-tangler-phone-light-1-main.png`) — **no language in the filename**; language is the parent folder.

### Batch capture: `make screenshots`

Full set: every key in **`locale_map`** (e.g. `en` → `en-US`, `pl` → `pl-PL`), themes light/dark, all screens from `tools/screenshots.json`.

| Parameter | Description |
|-----------|-------------|
| **DEVICE_ID** | ADB id (e.g. `emulator-5554`). Empty = pick from a list. |
| **DEVICE_NAME** | Label in filenames and bucket picker (e.g. `phone`, `tablet10`, `tablet7`). Empty = `DEVICE_ID`. |

```bash
make screenshots                                    # pick device from list
make screenshots DEVICE_NAME=tablet10             # writes to tenInchScreenshots/
make screenshots DEVICE_ID=emulator-5554 DEVICE_NAME=tablet7
```

For each **app locale + theme** pair the script waits for **Enter** after switching locale/theme (adjust the app if needed, then press Enter).

### Google Play requirements

| Type | Minimum resolution |
|------|---------------------|
| Phone | 320 px (shorter side) |
| 7" tablet | 1024 × 600 |
| 10" tablet | 1280 × 800 |

[Tablet optimization (Google)](https://support.google.com/googleplay/android-developer/answer/2617018)

### Emulators

**Android Studio → Device Manager → Create Device**: pick a phone (e.g. Pixel 7), 7" tablet (e.g. Nexus 7, 1920×1200), or 10" (e.g. Pixel Tablet, 2560×1600). System image e.g. API 34.

Start the AVD, install the app (`make run`), then e.g. `make screenshots DEVICE_NAME=tablet7`.  
On a physical phone: power + volume down for a screenshot.

### Single screenshot (ADB)

Pick the right `images/` folder and locale, then for example:

```bash
mkdir -p fastlane/metadata/android/en-US/images/phoneScreenshots
adb exec-out screencap -p > fastlane/metadata/android/en-US/images/phoneScreenshots/manual.png
# Multiple devices: adb -s <device_id> exec-out screencap -p > ...
```
