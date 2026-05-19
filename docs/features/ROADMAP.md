# 🗺️ Tune Tangler — roadmap

> Planned and deferred work — what’s next for Tune Tangler.

## 📋 Table of contents

- [🎯 Planned work](#planned-work)
  - [📦 3) Project export/import (shipped)](#export-import-shipped)
  - [🎛️ 4) Audio effects (deferred)](#audio-effects-deferred)
  - [🔑 5) Licensing system](#licensing-system)
  - [🔊 6) Audio features (low priority)](#audio-features-low-priority)
  - [▶️ 7) Playback stack](#playback-stack)
  - [🚀 8) Release quality](#release-quality)
- [📚 Additional resources](#additional-resources)

---

## 🎯 Planned work <a name="planned-work"></a>

### 📦 3) Project export/import (shipped) <a name="export-import-shipped"></a>

**Saving and loading the full project** (ZIP with grid, tracks, recordings, metadata, validation, import preview) is **implemented**. Closed items and technical notes: [COMPLETED.md](./COMPLETED.md); format: [PROJECT_EXPORT_IMPORT.md](./PROJECT_EXPORT_IMPORT.md).

### 🎛️ 4) Audio effects (deferred — needs DSP) <a name="audio-effects-deferred"></a>

- Basics: reverb, delay/echo, compression, EQ (LP/HP)
- Advanced: distortion, chorus/flanger, pitch shift, time stretch
- Likely needs native DSP integration or dedicated plugins (Android/iOS)

### 🔑 5) Licensing system (medium priority) <a name="licensing-system"></a>

#### 🆓 Free tier

- Recording, playback, 6×4 grid, UI optimizations

#### ⭐ Licensed tier

- Profiles, full backup/restore, audio effects (once shipped), larger grids

#### 💳 Model

- One-time purchase for the full pack (TBD)

### 🔊 6) Audio features (low priority) <a name="audio-features-low-priority"></a>

- Noise reduction, normalization, fade in/out, crossfade

### ▶️ 7) Playback: audioplayers vs just_audio (analysis + plan) <a name="playback-stack"></a>

#### 📌 Current (audioplayers)

- Volume, balance, speed, loop, seek, events, audio context

#### 🎧 just_audio coverage

- Volume, speed, loop/seek/events, `ClippingAudioSource`, playlists/gapless
- Pan: needs a plugin; EQ: possible on Android via plugins

#### 🗺️ Plan

- Short term: stay on audioplayers (“processed” export remains Android-only native pipeline; playback unchanged)
- Medium term: prototype `ClippingAudioSource`; evaluate pan plugins
- Long term: EQ (Android) + `AVAudioEngine` (iOS) behind flags; consider a shared DSP layer

### 🚀 8) Release quality: Android 15, dependencies, QA, accessibility <a name="release-quality"></a>

This section summarizes repo review notes (`git log`, `flutter pub outdated`). Some items are **already in code**; others need **ongoing work** outside a single commit (manual tests, upstream monitoring).

#### ✅ Already addressed (code / product)

- **Android 15 edge-to-edge:** native setup (`WindowCompat.setDecorFitsSystemWindows(false)` before the `FlutterActivity` lifecycle), themes without `windowOptOutEdgeToEdgeEnforcement`, `SystemUiMode.edgeToEdge` on the Dart side; consistent with earlier grid padding for the navigation bar (see commits around `fix(android): enable edge-to-edge for Android 15` and related inset fixes).
- **Share export:** hide “processed” when playback and trim are default (fewer unnecessary choices).
- **Help (l10n):** icon legend tweaks (balance, trim, loop mode), grid/keyboard docs (drawer mode, modifier Control / often Cmd on Mac), EN copy cleanups, consistent tap wording in track states.

#### ⚠️ Still needs attention

- **Dependencies:** `flutter pub outdated` still shows minor bumps (`file_picker` 11.0.1→11.0.2, `path_provider_android` 2.2.23→2.3.1) and possible majors (`share_plus` 12→13, `package_info_plus` 9→10)—each major needs changelog review and smoke tests (record, file import, share, project export).
- **Google Play / Android 15 — deprecated window APIs** (`setStatusBarColor`, traces in `PlatformPlugin`, sometimes Material date picker): may **persist** until Flutter/engine dependencies stop calling those paths. Re-check Flutter stable release notes each release and re-run **Pre-launch report** after bumping compile/target SDK tooling.
- **Manual QA on API 35+:** visual pass after edge-to-edge (drawer, dialogs, bottom sheet, rotation if enabled, light/dark, gesture nav vs three-button). Static analysis alone is not enough.
- **Accessibility:** Help (`Drawer` → Help) still lacks dedicated handling for **high `textScaler`** and richer **TalkBack** semantics for long icon legends—plan separately (`ExpansionTile` contrast, minimum readable typography, optional `Semantics`).

#### ☑️ Short QA checklist (Android 15+)

1. Track grid: AppBar, drawer, footer; no overlap with status bar / gesture inset.  
2. Track details, dialogs, bottom sheet with keyboard (`windowSoftInputMode`).  
3. Landscape (if enabled in manifest / device settings).

## 📚 Additional resources <a name="additional-resources"></a>

- App capabilities: [README.md](../../README.md#capabilities)
- Shipped items (commits): [COMPLETED.md](./COMPLETED.md)
- Flutter roadmap: https://github.com/flutter/flutter/wiki/Roadmap
- Android roadmap: https://developer.android.com/about/versions
