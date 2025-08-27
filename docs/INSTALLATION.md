# Instalacja i Konfiguracja

## Przygotowanie środowiska developerskiego

### 1. Instalacja Flutter

- **Pobierz Flutter SDK:**
  - Przejdź na stronę [Flutter Downloads](https://docs.flutter.dev/get-started/install)
    i pobierz najnowszą stabilną wersję odpowiednią dla Twojego systemu
    operacyjnego.

- **Instalacja:**
  - Rozpakuj pobrany plik do wybranej lokalizacji na swoim komputerze.
  - Dodaj ścieżkę do katalogu `bin` Fluttera do zmiennej środowiskowej `PATH`.

- **Weryfikacja instalacji:**
  - Otwórz terminal i uruchom:

      ```bash
      flutter doctor
      ```

  - To polecenie sprawdzi, czy wszystkie niezbędne komponenty są zainstalowane
    i skonfigurowane poprawnie.

### 2. Instalacja Android Studio

- **Pobierz i zainstaluj Android Studio:**
  - Pobierz najnowszą wersję z [oficjalnej strony](https://developer.android.com/studio).
  - Zainstaluj program, postępując zgodnie z instrukcjami instalatora.

- **Konfiguracja:**
  - Uruchom Android Studio i przejdź przez kreator konfiguracji,
    akceptując domyślne ustawienia.
  - Zainstaluj wymagane komponenty, takie jak Android SDK,
    Platform-Tools i Build-Tools.

### 3. Konfiguracja emulatora Androida

- **Tworzenie nowego urządzenia wirtualnego (AVD):**
  - W Android Studio przejdź do `Tools` > `AVD Manager`.
  - Kliknij `Create Virtual Device` i wybierz preferowane urządzenie.
  - Wybierz wersję systemu Android i zakończ proces tworzenia emulatora.

- **Uruchamianie emulatora:**
  - W `AVD Manager` kliknij ikonę `Start` obok utworzonego urządzenia,
    aby uruchomić emulator.

### 4. Przygotowanie projektu

- **Pobranie zależności:**

  ```bash
  flutter pub get
  ```

- **Weryfikacja konfiguracji:**

  ```bash
  flutter doctor
  flutter analyze
  ```

### 5. Uruchamianie aplikacji na emulatorze

- **Sprawdź dostępne urządzenia:**

  ```bash
  flutter devices
  ```

- **Uruchomienie aplikacji:**
  - Upewnij się, że emulator jest uruchomiony.
  - W terminalu, w katalogu głównym projektu, uruchom:

      ```bash
      flutter run
      ```

  - Aplikacja zostanie skompilowana i uruchomiona na emulatorze.

- **Hot Reload:**
  - Podczas działania aplikacji w trybie debug, możesz użyć klawisza `r` w terminalu,
    aby zastosować zmiany na żywo bez pełnego restartowania aplikacji.

## Makefile

Projekt zawiera Makefile z przydatnymi komendami do developmentu.

### 🚀 Development Setup

- `make dev-setup` - Setup development environment
- `make quick-start` - Setup environment and show devices

### 🧪 Code Quality

- `make analyze` - Run code analysis
- `make test` - Run tests
- `make format` - Format code
- `make lint` - Check code style

### 🔨 Run & Build

- `make run` - Run app in debug mode
- `make build-apk` - Build APK in debug mode
- `make install-apk` - Build and install APK on device
- `make clean` - Clean build and cache
- `make full-build` - All-in-one: clean, deps, analyze, build

### 📱 Device Management

- `make list-devices` - Show available devices
- `make list-emulators` - Show available emulators
- `make start-emulator` - Start emulator with selection
- `make run-emulator` - Run app on emulator

### ℹ Maintenance

- `make doctor` - Check Flutter environment
- `make pub-get` - Get dependencies
- `make pub-upgrade` - Upgrade dependencies
- `make sdk-upgrade` - Upgrade Flutter SDK

### ⬆ Utilities

- `make gen-l10n` - Generate localization files
- `make gen-icons` - Generate app icons
- `make gen-splash` - Generate splash screen

**Pełna lista komend:** `make help`

**Uwaga:** Do build i install w trybie release użyj GitHub Actions workflow.

## Troubleshooting

**Uwaga:** W przypadku problemów z konfiguracją lub uruchamianiem,
sprawdź oficjalną dokumentację [Flutter](https://docs.flutter.dev/) lub
[Android Studio](https://developer.android.com/studio/intro).

### Typowe problemy

1. **Flutter not found**
   - Sprawdź czy Flutter jest w `PATH`
   - Uruchom `flutter doctor` dla diagnostyki

2. **Android SDK not found**
   - Sprawdź czy Android Studio jest zainstalowane
   - Uruchom `flutter doctor --android-licenses`

3. **Emulator not starting**
   - Sprawdź czy AVD jest utworzony
   - Uruchom z Android Studio AVD Manager

4. **Dependencies issues**
   - Uruchom `flutter clean`
   - Następnie `flutter pub get`
