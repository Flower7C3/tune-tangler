# 🔧 Setup Środowiska Developerskiego

> Szczegółowy przewodnik konfiguracji środowiska dla TuneTangler

## 📋 Spis Treści

- [📋 Wymagania](#requirements)
  - [💻 System Operacyjny](#operating-system)
  - [🛠️ Wymagane Narzędzia](#required-tools)
- [🚀 Instalacja Flutter](#flutter-installation)
  - [📥 Oficjalne Instrukcje](#official-instructions)
  - [⚙️ Po Instalacji](#after-installation)
  - [🔍 Weryfikacja Flutter](#flutter-verification)
- [🤖 Instalacja Android Studio](#android-studio-installation)
  - [📥 Oficjalne Instrukcje](#official-instructions-1)
  - [⚙️ Po Instalacji](#after-installation-1)
  - [📱 Emulator Android](#android-emulator)
- [🍎 Instalacja Xcode (macOS)](#xcode-installation)
  - [📥 Oficjalne Instrukcje](#official-instructions-2)
  - [⚙️ Po Instalacji](#after-installation-2)
  - [📱 Simulator iOS](#ios-simulator)
- [⚙️ Konfiguracja](#configuration)
  - [🔑 Licencje Android](#android-licenses)
  - [📱 Urządzenia](#devices)
  - [🎯 Flutter Doctor](#flutter-doctor)
- [🔍 Weryfikacja](#verification)
  - [✅ Checklist](#checklist)
  - [🧪 Test Instalacji](#installation-test)
- [🚨Jeśli coś nie działa](#troubleshooting)
  - [❌ Flutter not found](#flutter-not-found)
  - [❌ Android SDK not found](#android-sdk-not-found)
  - [❌ Java not found](#java-not-found)
  - [❌ Emulator not starting](#emulator-not-starting)
  - [❌ Xcode issues](#xcode-issues)
- [📚 Dodatkowe Zasoby](#additional-resources)

## 📋 Wymagania <a name="requirements"></a>

### 💻 System Operacyjny <a name="operating-system"></a>

- **Windows:** 10/11 (64-bit)
- **macOS:** 10.15+ (Catalina)
- **Linux:** Ubuntu 18.04+ / Debian 10+

### 🛠️ Wymagane Narzędzia <a name="required-tools"></a>

- **Flutter:** 3.35.1+
- **Dart:** 3.6.1+
- **Git:** 2.30+
- **Java:** 17 (dla Android)

## 🚀 Instalacja Flutter <a name="flutter-installation"></a>

### 📥 Oficjalne Instrukcje <a name="official-instructions"></a>

- **[Flutter Installation](https://docs.flutter.dev/get-started/install)** – Oficjalny przewodnik instalacji
- **[Flutter Setup](https://docs.flutter.dev/get-started/install)** – Konfiguracja środowiska

### ⚙️ Po Instalacji <a name="after-installation"></a>

Dodaj Flutter do PATH i uruchom `flutter doctor` aby sprawdzić konfigurację.

### 🔍 Weryfikacja Flutter <a name="flutter-verification"></a>

```bash
flutter --version
flutter doctor
flutter channel
flutter upgrade
```

**Sprawdź:**

- Instalację
- Środowisko
- Kanał

## 🤖 Instalacja Android Studio <a name="android-studio-installation"></a>

### 📥 Oficjalne Instrukcje <a name="official-instructions-1"></a>

- **[Android Studio Installation](https://developer.android.com/studio/install)** – Oficjalny przewodnik instalacji
- **[Android SDK Setup](https://developer.android.com/studio/intro/studio-config)** – Konfiguracja SDK

### ⚙️ Po Instalacji <a name="after-installation-1"></a>

Zainstaluj Android SDK i ustaw zmienną `ANDROID_HOME` w zmiennych środowiskowych.

### 📱 Emulator Android <a name="android-emulator"></a>

#### 1. Tworzenie AVD

**W Android Studio:**
Tools → AVD Manager → Create Virtual Device

**Wybierz:**

- Device: Pixel 7 (lub inny)
- System Image: API 34 (Android 14.0)
- RAM: 4GB+
- Internal Storage: 8GB+

#### 2. Uruchomienie

Z **terminala**:

```bash
flutter emulators --launch <emulator_name>
```

Lub z **Android Studio:**
AVD Manager → Start (▶️)

## 🍎 Instalacja Xcode (macOS) <a name="xcode-installation"></a>

### 📥 Oficjalne Instrukcje <a name="official-instructions-2"></a>

- **[Xcode Installation](https://developer.apple.com/xcode/)** – Pobierz z App Store
- **[Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)** – Instalacja
  narzędzi wiersza poleceń

### ⚙️ Po Instalacji <a name="after-installation-2"></a>

Uruchom `xcode-select --install` aby zainstalować Command Line Tools.

### 📱 Simulator iOS <a name="ios-simulator"></a>

```bash
open -a Simulator
flutter emulators --launch <simulator_name>
```

## ⚙️ Konfiguracja <a name="configuration"></a>

### 🔑 Licencje Android <a name="android-licenses"></a>

```bash
flutter doctor --android-licenses
flutter doctor
```

**Sprawdź:**

- Akceptuj licencje
- Status

### 📱 Urządzenia <a name="devices"></a>

```bash
flutter devices
adb devices
```

**Sprawdź:**

- Dostępne urządzenia
- Połączenie USB

### 🎯 Flutter Doctor <a name="flutter-doctor"></a>

```bash
flutter doctor -v
flutter doctor --android
flutter doctor --ios
```

**Sprawdź:**

- Pełna diagnostyka
- Konkretne platformy

## 🔍 Weryfikacja <a name="verification"></a>

### ✅ Checklist <a name="checklist"></a>

- [ ] Flutter zainstalowany i w PATH
- [ ] Android Studio z SDK
- [ ] Emulator Android lub urządzenie
- [ ] Xcode (macOS) z Command Line Tools
- [ ] Simulator iOS (macOS)
- [ ] Wszystkie licencje zaakceptowane
- [ ] `flutter doctor` bez błędów

### 🧪 Test Instalacji <a name="installation-test"></a>

```bash
flutter --version
flutter doctor
flutter devices
flutter create test_app
cd test_app
flutter run
```

**Sprawdź:**

1. Flutter
2. Środowisko
3. Urządzenia
4. Test build

## 🚨Jeśli coś nie działa <a name="troubleshooting"></a>

### ❌ Flutter not found <a name="flutter-not-found"></a>

Sprawdź [Flutter Installation Guide](https://docs.flutter.dev/get-started/install#update-your-path)

### ❌ Android SDK not found <a name="android-sdk-not-found"></a>

Sprawdź [Android Studio Setup](https://developer.android.com/studio/intro/studio-config#sdk-location)

### ❌ Java not found <a name="java-not-found"></a>

Sprawdź [Java Installation](https://adoptium.net/) lub użyj:

- macOS: `brew install openjdk@17`
- Linux: `sudo apt install openjdk-17-jdk`

### ❌ Emulator not starting <a name="emulator-not-starting"></a>

Sprawdź [AVD Manager](https://developer.android.com/studio/run/managing-avds) lub uruchom z Android Studio

### ❌ Xcode issues <a name="xcode-issues"></a>

Sprawdź [Xcode Troubleshooting](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)

## 📚 Dodatkowe Zasoby <a name="additional-resources"></a>

- **[📖 Development Guide](../../README.md)** – Główny przewodnik
- **[⚡ Quick Start](QUICKSTART.md)** – Szybkie uruchomienie
- **[🔨 Makefile](QUICKSTART.md#makefile)** – Komendy i narzędzia
- **[Flutter Docs](https://docs.flutter.dev/)** – Oficjalna dokumentacja
- **[Android Docs](https://developer.android.com/)** – Dokumentacja Android
