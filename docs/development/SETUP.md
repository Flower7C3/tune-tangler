# 🔧 Developer environment setup

> Detailed environment setup for Tune Tangler

## 📋 Table of contents

- [✅ Requirements](#requirements)
  - [💻 Operating system](#operating-system)
  - [🧰 Required tools](#required-tools)
- [🚀 Flutter installation](#flutter-installation)
  - [📖 Official instructions](#official-instructions)
  - [⚡ After installation](#after-installation)
  - [🔎 Verify Flutter](#flutter-verification)
- [🤖 Android Studio](#android-studio-installation)
  - [📖 Official instructions](#official-instructions-1)
  - [⚡ After installation](#after-installation-1)
  - [📱 Android emulator](#android-emulator)
- [🍎 Xcode (macOS)](#xcode-installation)
  - [📖 Official instructions](#official-instructions-2)
  - [⚡ After installation](#after-installation-2)
  - [📱 iOS Simulator](#ios-simulator)
- [⚙️ Configuration](#configuration)
  - [📜 Android licenses](#android-licenses)
  - [📲 Devices](#devices)
  - [🩺 Flutter doctor](#flutter-doctor)
- [🔍 Verification](#verification)
  - [☑️ Checklist](#checklist)
  - [🧪 Installation smoke test](#installation-test)
- [🚨 Troubleshooting](#troubleshooting)
  - [🐦 Flutter not found](#flutter-not-found)
  - [🤖 Android SDK not found](#android-sdk-not-found)
  - [☕ Java not found](#java-not-found)
  - [📱 Emulator not starting](#emulator-not-starting)
  - [🍎 Xcode issues](#xcode-issues)
- [📚 Additional resources](#additional-resources)

## ✅ Requirements <a name="requirements"></a>

### Operating system <a name="operating-system"></a>

- **Windows:** 10/11 (64-bit)
- **macOS:** 10.15+ (Catalina)
- **Linux:** Ubuntu 18.04+ / Debian 10+

### Required tools <a name="required-tools"></a>

- **Flutter:** 3.35.1+
- **Dart:** 3.6.1+
- **Git:** 2.30+
- **Java:** 17 (for Android)

## 🚀 Flutter installation <a name="flutter-installation"></a>

### Official instructions <a name="official-instructions"></a>

- **[Install Flutter](https://docs.flutter.dev/get-started/install)**
- **[Flutter setup](https://docs.flutter.dev/get-started/install)**

### After installation <a name="after-installation"></a>

Add Flutter to `PATH` and run `flutter doctor`.

### Verify Flutter <a name="flutter-verification"></a>

```bash
flutter --version
flutter doctor
flutter channel
flutter upgrade
```

## 🤖 Android Studio <a name="android-studio-installation"></a>

### Official instructions <a name="official-instructions-1"></a>

- **[Install Android Studio](https://developer.android.com/studio/install)**
- **[Configure the SDK](https://developer.android.com/studio/intro/studio-config)**

### After installation <a name="after-installation-1"></a>

Install the Android SDK and set `ANDROID_HOME` (or `ANDROID_SDK_ROOT`) in your environment.

### Android emulator <a name="android-emulator"></a>

#### 1. Create an AVD

In **Android Studio:**  
Tools → AVD Manager → Create Virtual Device

Suggested:

- Device: Pixel 7 (or similar)
- System image: API 34 (Android 14)
- RAM: 4GB+
- Internal storage: 8GB+

#### 2. Launch

From a **terminal**:

```bash
flutter emulators --launch <emulator_name>
```

Or from **Android Studio:** AVD Manager → Start (▶️)

## 🍎 Xcode (macOS) <a name="xcode-installation"></a>

### Official instructions <a name="official-instructions-2"></a>

- **[Xcode](https://developer.apple.com/xcode/)** — App Store
- **[Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)**

### After installation <a name="after-installation-2"></a>

Run `xcode-select --install` for the command-line tools if needed.

### iOS Simulator <a name="ios-simulator"></a>

```bash
open -a Simulator
flutter emulators --launch <simulator_name>
```

## ⚙️ Configuration <a name="configuration"></a>

### Android licenses <a name="android-licenses"></a>

```bash
flutter doctor --android-licenses
flutter doctor
```

### Devices <a name="devices"></a>

```bash
flutter devices
adb devices
```

### Flutter doctor <a name="flutter-doctor"></a>

```bash
flutter doctor -v
flutter doctor --android
flutter doctor --ios
```

## 🔍 Verification <a name="verification"></a>

### Checklist <a name="checklist"></a>

- [ ] Flutter installed and on `PATH`
- [ ] Android Studio with SDK
- [ ] Android emulator or physical device
- [ ] Xcode (macOS) with Command Line Tools
- [ ] iOS Simulator (macOS)
- [ ] All Android licenses accepted
- [ ] `flutter doctor` clean

### Installation smoke test <a name="installation-test"></a>

```bash
flutter --version
flutter doctor
flutter devices
flutter create test_app
cd test_app
flutter run
```

## 🚨 Troubleshooting <a name="troubleshooting"></a>

### Flutter not found <a name="flutter-not-found"></a>

[Update your PATH](https://docs.flutter.dev/get-started/install#update-your-path)

### Android SDK not found <a name="android-sdk-not-found"></a>

[SDK location in Android Studio](https://developer.android.com/studio/intro/studio-config#sdk-location)

### Java not found <a name="java-not-found"></a>

[Temurin / Adoptium](https://adoptium.net/) or:

- macOS: `brew install openjdk@17`
- Linux: `sudo apt install openjdk-17-jdk`

### Emulator not starting <a name="emulator-not-starting"></a>

[AVD Manager](https://developer.android.com/studio/run/managing-avds) or start from Android Studio.

### Xcode issues <a name="xcode-issues"></a>

[Xcode troubleshooting](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)

## 📚 Additional resources <a name="additional-resources"></a>

- **[Development guide](../../README.md)**
- **[Quick start](QUICKSTART.md)**
- **[Makefile](QUICKSTART.md#makefile)**
- **[Flutter docs](https://docs.flutter.dev/)**
- **[Android docs](https://developer.android.com/)**
