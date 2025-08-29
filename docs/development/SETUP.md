# 🔧 Setup Środowiska Developerskiego

> Szczegółowy przewodnik konfiguracji środowiska dla TuneTangler

## 📋 Spis Treści

- [📋 Wymagania](#-wymagania)
  - [💻 System Operacyjny](#️-system-operacyjny)
  - [🛠️ Wymagane Narzędzia](#️-wymagane-narzędzia)
- [🚀 Instalacja Flutter](#-instalacja-flutter)
  - [📥 Oficjalne Instrukcje](#️-oficjalne-instrukcje)
  - [⚙️ Po Instalacji](#️-po-instalacji)
  - [🔍 Weryfikacja Flutter](#️-weryfikacja-flutter)
- [🤖 Instalacja Android Studio](#️-instalacja-android-studio)
  - [📥 Oficjalne Instrukcje](#️-oficjalne-instrukcje-1)
  - [⚙️ Po Instalacji](#️-po-instalacji-1)
  - [📱 Emulator Android](#️-emulator-android)
- [🍎 Instalacja Xcode (macOS)](#️-instalacja-xcode-macos)
  - [📥 Oficjalne Instrukcje](#️-oficjalne-instrukcje-2)
  - [⚙️ Po Instalacji](#️-po-instalacji-2)
  - [📱 Simulator iOS](#️-simulator-ios)
- [⚙️ Konfiguracja](#️-konfiguracja)
  - [🔑 Licencje Android](#️-licencje-android)
  - [📱 Urządzenia](#️-urządzenia)
  - [🎯 Flutter Doctor](#️-flutter-doctor)
- [🔍 Weryfikacja](#️-weryfikacja)
  - [✅ Checklist](#️-checklist)
  - [🧪 Test Instalacji](#️-test-instalacji)
- [🚨Jeśli coś nie działa](#️jeśli-coś-nie-działa)
  - [❌ Flutter not found](#️-flutter-not-found)
  - [❌ Android SDK not found](#️-android-sdk-not-found)
  - [❌ Java not found](#️-java-not-found)
  - [❌ Emulator not starting](#️-emulator-not-starting)
  - [❌ Xcode issues](#️-xcode-issues)
- [📚 Dodatkowe Zasoby](#️-dodatkowe-zasoby)

## 📋 Wymagania

### 💻 System Operacyjny

- **Windows:** 10/11 (64-bit)
- **macOS:** 10.15+ (Catalina)
- **Linux:** Ubuntu 18.04+ / Debian 10+

### 🛠️ Wymagane Narzędzia

- **Flutter:** 3.35.1+
- **Dart:** 3.6.1+
- **Git:** 2.30+
- **Java:** 17 (dla Android)

## 🚀 Instalacja Flutter

### 📥 Oficjalne Instrukcje

- **[Flutter Installation](https://docs.flutter.dev/get-started/install)** – Oficjalny przewodnik instalacji
- **[Flutter Setup](https://docs.flutter.dev/get-started/install)** – Konfiguracja środowiska

### ⚙️ Po Instalacji

Dodaj Flutter do PATH i uruchom `flutter doctor` aby sprawdzić konfigurację.

### 🔍 Weryfikacja Flutter

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

## 🤖 Instalacja Android Studio

### 📥 Oficjalne Instrukcje

- **[Android Studio Installation](https://developer.android.com/studio/install)** – Oficjalny przewodnik instalacji
- **[Android SDK Setup](https://developer.android.com/studio/intro/studio-config)** – Konfiguracja SDK

### ⚙️ Po Instalacji

Zainstaluj Android SDK i ustaw zmienną `ANDROID_HOME` w zmiennych środowiskowych.

### 📱 Emulator Android

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

## 🍎 Instalacja Xcode (macOS)

### 📥 Oficjalne Instrukcje

- **[Xcode Installation](https://developer.apple.com/xcode/)** – Pobierz z App Store
- **[Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)** – Instalacja
  narzędzi wiersza poleceń

### ⚙️ Po Instalacji

Uruchom `xcode-select --install` aby zainstalować Command Line Tools.

### 📱 Simulator iOS

```bash
open -a Simulator
flutter emulators --launch <simulator_name>
```

## ⚙️ Konfiguracja

### 🔑 Licencje Android

```bash
flutter doctor --android-licenses
flutter doctor
```

**Sprawdź:**

- Akceptuj licencje
- Status

### 📱 Urządzenia

```bash
flutter devices
adb devices
```

**Sprawdź:**

- Dostępne urządzenia
- Połączenie USB

### 🎯 Flutter Doctor

```bash
flutter doctor -v
flutter doctor --android
flutter doctor --ios
```

**Sprawdź:**

- Pełna diagnostyka
- Konkretne platformy

## 🔍 Weryfikacja

### ✅ Checklist

- [ ] Flutter zainstalowany i w PATH
- [ ] Android Studio z SDK
- [ ] Emulator Android lub urządzenie
- [ ] Xcode (macOS) z Command Line Tools
- [ ] Simulator iOS (macOS)
- [ ] Wszystkie licencje zaakceptowane
- [ ] `flutter doctor` bez błędów

### 🧪 Test Instalacji

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

## 🚨Jeśli coś nie działa

### ❌ Flutter not found

Sprawdź [Flutter Installation Guide](https://docs.flutter.dev/get-started/install#update-your-path)

### ❌ Android SDK not found

Sprawdź [Android Studio Setup](https://developer.android.com/studio/intro/studio-config#sdk-location)

### ❌ Java not found

Sprawdź [Java Installation](https://adoptium.net/) lub użyj:

- macOS: `brew install openjdk@17`
- Linux: `sudo apt install openjdk-17-jdk`

### ❌ Emulator not starting

Sprawdź [AVD Manager](https://developer.android.com/studio/run/managing-avds) lub uruchom z Android Studio

### ❌ Xcode issues

Sprawdź [Xcode Troubleshooting](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)

## 📚 Dodatkowe Zasoby

- **[📖 Development Guide](../../README.md)** – Główny przewodnik
- **[⚡ Quick Start](QUICKSTART.md)** – Szybkie uruchomienie
- **[🔨 Makefile](QUICKSTART.md#makefile)** – Komendy i narzędzia
- **[Flutter Docs](https://docs.flutter.dev/)** – Oficjalna dokumentacja
- **[Android Docs](https://developer.android.com/)** – Dokumentacja Android
