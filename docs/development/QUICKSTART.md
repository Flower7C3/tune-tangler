# ⚡ Quick start

> Run Tune Tangler locally in a few minutes

## 📋 Table of contents

- [🚀 Five steps](#5-steps)
  - [1️⃣ Clone the project](#clone-project)
  - [2️⃣ One-time configuration](#one-time-configuration)
  - [3️⃣ Check devices](#check-devices)
  - [4️⃣ Run the app](#run-app)
  - [5️⃣ Done 🎉](#ready)
- [🚨 Troubleshooting](#troubleshooting)
  - [❌ Flutter not found](#flutter-not-found)
  - [❌ No devices found](#no-devices-found)
  - [❌ Dependency issues](#dependencies-issues)
- [📱 Hot reload](#hot-reload)
- [🔄 Daily workflow](#daily-workflow)
- [🔨 Makefile](#makefile)
- [📚 What’s next](#what-next)
- [🆘 Quick help](#quick-help)

---

## 🚀 Five steps <a name="5-steps"></a>

### 1️⃣ Clone the project <a name="clone-project"></a>

```bash
git clone https://github.com/Flower7C3/tune-tangler.git
cd tune-tangler
git branch
```

You should see: `* main`

### 2️⃣ One-time configuration <a name="one-time-configuration"></a><a name="setup-environment"></a>

```bash
make dev-setup
```

**This will:**
- Check Flutter (`flutter doctor`)
- Fetch dependencies (`flutter pub get`)
- Install the optional `pre-commit` hook

### 3️⃣ Check devices <a name="check-devices"></a>

```bash
make list-devices
```

Emulators:

```bash
make list-emulators
```

### 4️⃣ Run the app <a name="run-app"></a>

```bash
make run
```

### 5️⃣ Done 🎉 <a name="ready"></a>

The app should launch on the selected device or emulator.

## 🚨 Troubleshooting <a name="troubleshooting"></a>

### ❌ Flutter not found <a name="flutter-not-found"></a>

See the [Flutter install guide](https://docs.flutter.dev/get-started/install).

### ❌ No devices found <a name="no-devices-found"></a>

See [Flutter device setup](https://docs.flutter.dev/get-started/flutter-for/install-and-setup#device-setup).

### ❌ Dependency issues <a name="dependencies-issues"></a>

**Clean:**

```bash
flutter clean
```

**Fetch again:**

```bash
flutter pub get
```

**Check Flutter:**

```bash
flutter doctor
```

## 📱 Hot reload <a name="hot-reload"></a>

While the app is running:

```bash
r - Hot reload (keeps state)
R - Hot restart (resets state)
q - Quit
h - Help
```

## 🔄 Daily workflow <a name="daily-workflow"></a>

Use the [Makefile](QUICKSTART.md#makefile) for routine tasks:

```bash
make dev-setup    # Environment setup
make analyze      # Static analysis
make test         # Tests
make run          # Run the app
```

## 🔨 Makefile <a name="makefile"></a>

Common commands:

```bash
# Environment
make dev-setup          # Full setup
make quick-start        # Quick start with device list

# Code quality
make analyze            # Analyzer
make test               # Tests
make format             # Format

# Build & run
make run                # Run the app
make build-apk          # Build APK
make install-apk        # Build and install APK

# Git hooks
make install-pre-commit-hook
make remove-pre-commit-hook
```

**All targets:** `make help`

## 📚 What’s next <a name="what-next"></a>

- **[🔧 Setup](SETUP.md#one-time-configuration)** — full one-time environment (Android/iOS details)
- **[Workflows — One-time configuration](WORKFLOWS.md#one-time-configuration)** — CI secrets index
- **[🎣 Git hooks](GIT_HOOKS.md)** — optional `pre-commit`: `flutter analyze`
- **[🚀 Workflows](WORKFLOWS.md)** — CI/CD

## 🆘 Quick help <a name="quick-help"></a>

```bash
make help
```

Diagnostics:

```bash
flutter doctor -v
```

Logs:

```bash
flutter logs
```

Reset:

```bash
flutter clean && flutter pub get
```
