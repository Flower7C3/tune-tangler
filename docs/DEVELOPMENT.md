# Instalacja i Konfiguracja

### Wymagania

- Flutter 3.35.1+
- Android Studio / Xcode
- Java 17 (dla Android)

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
Pełna lista komend dostępna po uruchomieniu:

```bash
make help
```

### Główne komendy

```bash
# Setup środowiska
make dev-setup          # Pełna konfiguracja środowiska
make quick-start        # Szybki start z listą urządzeń

# Code quality
make analyze            # Analiza kodu
make test               # Uruchomienie testów
make format             # Formatowanie kodu

# Build & Run
make run                # Uruchomienie aplikacji
make build-apk          # Budowanie APK
make install-apk        # Budowanie i instalacja APK

# Git hooks
make install-pre-commit-hook    # Instalacja pre-commit hooka
make remove-pre-commit-hook     # Usunięcie pre-commit hooka
```

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
