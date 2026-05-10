# ✅ Shipped items (with commits)

- Performance work (throttling, lazy loading, multi–`ValueListenable`):  
  [de16e9e](https://github.com/Flower7C3/tune-tangler/commit/de16e9e),  
  [d71fd92](https://github.com/Flower7C3/tune-tangler/commit/d71fd92),  
  [6591437](https://github.com/Flower7C3/tune-tangler/commit/6591437)
- UI polish (menus, icons, details, toasts):  
  [d71fd92](https://github.com/Flower7C3/tune-tangler/commit/d71fd92),  
  [de16e9e](https://github.com/Flower7C3/tune-tangler/commit/de16e9e)
- Safe track swap (validation, rename/copy fallback, preference migration):  
  [67f548f](https://github.com/Flower7C3/tune-tangler/commit/67f548f) (+ follow-ups)
- Sharing recordings: raw and “processed” (originally FFmpeg; **Android** processed export now MediaCodec + Sonic):  
  [92ee486](https://github.com/Flower7C3/tune-tangler/commit/92ee486)
- i18n (ARB refresh + generated code, localized errors):  
  [129a95e](https://github.com/Flower7C3/tune-tangler/commit/129a95e)
- CI on `main`: tests + F-Droid checklist (APK/AAB disabled in default workflow; legacy: `release-legacy-github-play-apk-aab.yml`); historical auto bump + tag:  
  [3d8139d](https://github.com/Flower7C3/tune-tangler/commit/3d8139d)
- Help screen: expandable sections with icons and descriptions (`Drawer` → Help)  
  (see UI commits above)
- **Project export/import**:
  - Export to ZIP containing:
    - Grid settings (row/column count)
    - All per-track settings (name, playback params, trimming, keyboard shortcuts, recording metadata)
    - All audio recordings with SHA256 checksums
    - Project metadata (version, export time, stats)
  - Import with full validation before mutating data:
    - ZIP structure, JSON files, recording checksums
    - Import preview
    - Warning about overwriting the current session
    - Cache clear + UI refresh after import
  - Filename pattern: `tune_tangler_project_[name]_YYYYMMDD_HHMMSS.zip`
  - UI in the main menu (AppBar → “Save project” / “Load project”)
  - Correct trim (`playbackStartAtPosition`, `playbackEndAtPosition`) behavior on import
  - Non-breaking spaces in translations for nicer typography
  - Detailed format doc: [PROJECT_EXPORT_IMPORT.md](./PROJECT_EXPORT_IMPORT.md)

Related docs:

- Roadmap: [ROADMAP.md](./ROADMAP.md)
- App capabilities: [README.md#capabilities](../../README.md#capabilities)
- Pre-implementation analysis (if present in tree): [PROJECT_EXPORT_IMPORT_ANALYSIS.md](../PROJECT_EXPORT_IMPORT_ANALYSIS.md)
