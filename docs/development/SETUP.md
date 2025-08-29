# 🔧 Setup Środowiska Developerskiego

> Szczegółowy przewodnik konfiguracji środowiska dla TuneTangler

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

```bash
echo $PATH
export PATH="$PATH:$HOME/development/flutter/bin"
source ~/.zshrc
```

**Sprawdź:**

- PATH
- Dodaj Flutter do PATH
- Przeładuj shell (lub `~/.bashrc`)

### ❌ Android SDK not found

```bash
echo $ANDROID_HOME
export ANDROID_HOME="$HOME/Library/Android/sdk"
```

**Sprawdź:**

- `ANDROID_HOME`
- Ustaw ścieżkę
- W Android Studio: File → Project Structure → SDK Location

### ❌ Java not found

```bash
java -version
```

**Sprawdź:**

- Java

**Zainstaluj Java 17:**

- macOS: `brew install openjdk@17`
- Linux: `sudo apt install openjdk-17-jdk`
- Windows: Pobierz z Oracle

### ❌ Emulator not starting

```bash
flutter emulators
flutter emulators --launch <name> --verbose
```

**Sprawdź:**

- AVD
- Logi

**Uruchom z Android Studio:**
AVD Manager → Start

### ❌ Xcode issues

```bash
xcode-select --print-path
sudo xcode-select --reset
sudo xcodebuild -license
```

**Sprawdź:**

- Xcode
- Zresetuj Xcode
- Licencję

## 📚 Dodatkowe Zasoby

- **[📖 Development Guide](../../README.md)** – Główny przewodnik
- **[⚡ Quick Start](QUICKSTART.md)** – Szybkie uruchomienie
- **[🔨 Makefile](QUICKSTART.md#makefile)** – Komendy i narzędzia
- **[Flutter Docs](https://docs.flutter.dev/)** – Oficjalna dokumentacja
- **[Android Docs](https://developer.android.com/)** – Dokumentacja Android
