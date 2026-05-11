# Tune Tangler

> Yet another music looper app

## 📚 Documentation <a name="documentation"></a>

### 🧩 App capabilities <a name="capabilities"></a>

- **Recording**: microphone/USB (device-dependent), auto-gain/echo-cancel/noise-suppress when supported
- **Import**: pick an audio file for a track
- **Playback**: start/stop/pause/resume, loop modes (single/loop), seek, range playback (start/end), time/position
- **Live control**: volume, balance (pan), speed (0.5–2.0)
- **Track management**: rename (including emoji), shortcut keys, move/swap recordings, delete recording
- **Sharing**: raw file or “processed” (trim/vol/pan/speed)—processed export on **Android** (MediaCodec + Sonic); on other platforms the raw file is shared when processing would be required
- **Layout**: configurable grid (rows/columns), lazy loading for performance
- **Themes**: light/dark/system, accent color
- **Localization**: EN/PL (switch at runtime)
- **Permissions**: microphone, notifications (Android), file access where applicable
- **Profiles**: save/load/delete setting profiles
- **Project export/import**: save the whole project (grid, all tracks, recordings) to ZIP and load it later with full validation

### 🚀 Quick start <a name="quick-start"></a>

- **[📱 Installation](docs/release/INSTALLATION.md)** — install the app and pick the right ABI
- **[🔧 Setup](docs/development/SETUP.md)** — developer toolchain and environment
- **[⚡ Quick start](docs/development/QUICKSTART.md)** — run the project quickly

### 🛠️ Development <a name="development"></a>

- **[🔧 Setup](docs/development/SETUP.md)** — detailed environment configuration
- **[⚡ Quick start](docs/development/QUICKSTART.md)** — first run
- **[🔨 Makefile](docs/development/QUICKSTART.md#makefile)** — daily commands
- **[🎨 Icon generation](docs/development/ICON_GENERATION.md)** — PNGs from SVG via config
- **[🎣 Git hooks](docs/development/GIT_HOOKS.md)** — optional `pre-commit`: `flutter analyze`
- **[🚀 Workflows](docs/development/WORKFLOWS.md)** — GitHub Actions and CI/CD
- **[📦 F-Droid](docs/release/FDROID.md)** — Actions workflow creates a **versioned branch** on your fdroiddata fork (link in run summary); merge request to upstream is manual in GitLab + templates in `tools/fdroid/`

### 📋 Project <a name="project"></a>

- **[🗺️ Roadmap](docs/features/ROADMAP.md)** — planned work
- **[✅ Completed](docs/features/COMPLETED.md)** — shipped items with commit links
- **[🔐 Release signing](docs/release/RELEASE_SIGNING.md)** — keystore / CI signing notes
- **[🤖 Agent (AI)](AGENTS.md)** — index of Cursor rules in **[`.cursor/rules/`](.cursor/rules/)** (`*.mdc`)

## 🔍 How to find things <a name="how-to-find-information"></a>

### 🆕 New developer <a name="new-developer"></a>

1. **[📱 Installation](docs/release/INSTALLATION.md)** — basics
2. **[🔧 Setup](docs/development/SETUP.md)** — environment
3. **[⚡ Quick start](docs/development/QUICKSTART.md)** — first successful run

### 🔧 Day-to-day development <a name="daily-development"></a>

1. **[🔨 Makefile](docs/development/QUICKSTART.md#makefile)** — analyze, test, run
2. **[🎨 Icon generation](docs/development/ICON_GENERATION.md)** — regenerate assets
3. **[🎣 Git hooks](docs/development/GIT_HOOKS.md)** — optional local checks

### 🚀 Release and deployment <a name="release-and-deployment"></a>

1. **[🚀 Workflows](docs/development/WORKFLOWS.md)** — what runs on `main` and manual release
2. **[🔐 Release signing](docs/release/RELEASE_SIGNING.md)** — signing for the release workflow
3. **[📝 Store listings & screenshots](docs/release/STORE_LISTINGS.md)** — Fastlane text + `make screenshots` → `metadata/android/…/images/`

---

*📚 Need help? See [Issues](https://github.com/Flower7C3/tune-tangler/issues) or [Discussions](https://github.com/Flower7C3/tune-tangler/discussions).*

## 📄 License <a name="license"></a>

**[MIT License](LICENSE)**
