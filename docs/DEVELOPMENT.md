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

## Pre-commit Hook – Automatyczne Inkrementowanie Wersji

### 📋 Opis

Pre-commit hook automatycznie zwiększa **patch version** w [pubspec.yaml](../pubspec.yaml) przed każdym commitem. To zapewnia, że każdy commit ma unikalną wersję.

### 🚀 Jak to działa

1. **Przed każdym commit** – hook sprawdza czy `pubspec.yaml` jest już zmodyfikowany
2. **Jeśli NIE** – zwiększa patch version (np. 1.2.1 → 1.2.2)
3. **Jeśli TAK** – pomija (nie duplikuje zmian)
4. **Automatycznie stage** – zaktualizowany `pubspec.yaml`

### 🔧 Instalacja

Makefile automatycznie instaluje hook

```bash
make install-pre-commit-hook
```

### ⚙️ Wyłączenie hooka

- **Tymczasowo**

    ```bash
    git commit --no-verify
    ```

- **Trwale (używając Makefile)**

    ```bash
    make remove-pre-commit-hook
    ```

### 📊 Przykłady

#### Przed commitem

```text
🔄 Pre-commit hook: Checking for version increment...
📋 Current version: 1.2.1
🆕 New version: 1.2.2
✅ Version incremented to 1.2.2 and staged for commit
💡 Commit message will include: version 1.2.2
```

#### Po commicie

```bash
git log --oneline -1
# Output: abc1234 version 1.3.0
```

### 🔍 Sprawdzenie statusu

```bash
# Sprawdź czy hook jest aktywny
ls -la .git/hooks/pre-commit

# Sprawdź uprawnienia
file .git/hooks/pre-commit
```

### ⚠️ Uwagi

- **Hook działa lokalnie** – każdy developer musi go zainstalować
- **Nie commitować** – hook jest w `.gitignore`
- **Backup** – hook tworzy `.bak` plik (automatycznie usuwany)
- **Git add** – hook automatycznie stage'uje zmiany

### 🐛 Troubleshooting

#### Hook nie działa

```bash
# Sprawdź uprawnienia
chmod +x .git/hooks/pre-commit

# Sprawdź czy jest w .git/hooks/
ls -la .git/hooks/

# Lub użyj Makefile do reinstalacji
make remove-pre-commit-hook
make install-pre-commit-hook
```

#### Błąd sed

```bash
# Na macOS może wymagać gnu-sed
brew install gnu-sed
# Lub zmień sed -i.bak na sed -i '' w skrypcie
```

#### Konflikt wersji

```bash
# Ręcznie rozwiąż w pubspec.yaml
git checkout -- pubspec.yaml
git add pubspec.yaml
git commit
```

## GitHub Workflows

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

- **Test** → **Build** → **Version Control** → **Release**

### Workflowy

#### 1. Release + Auto Tag (Integrated)

**Plik:** `release.yml`
**Uruchamiany:** Tylko manualnie przez `workflow_dispatch`

**Co robi:**

- ✅ Weryfikuje kod (analyze, testy)
- ✅ Generuje pliki lokalizacji
- ✅ Pobiera wersję z `pubspec.yaml`
- ✅ Buduje APK (split-per-abi) i App Bundle (.aab) release
- ✅ Weryfikuje podpis App Bundle
- ✅ Tworzy tag wersji z build number
- ✅ Tworzy GitHub Release z APK i App Bundle
- ✅ Uploaduje wszystkie pliki jako artifacts

### Jak używać

#### 1. Manualne Release (jedyna opcja)

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Build & Release Workflow"**
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – workflow automatycznie:
   - Pobierze wersję z `pubspec.yaml`
   - Utworzy tag `v{version}-build-{run_number}`
   - Zbuduje i zweryfikuje aplikację
   - Utworzy GitHub Release

#### 2. Testowanie Build Process

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Test Build Workflow"** (jeśli istnieje)
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – szczególnie kroki debugowania

### Pominięcie Workflow

Dodaj `[skip ci]` do wiadomości commita aby pominąć automatyczne workflowy.

### Wymagania

- Flutter 3.35.1
- Java 17 (Zulu)
- Ubuntu Latest runner
- GitHub Token (automatycznie dostępny)

### Cache

Workflowy używają cache dla:

- `~/.pub-cache` (Flutter dependencies)
- `~/.gradle/caches` (Android dependencies)

### Artifacts

- **APK Release:** Split-per-ABI APKs (arm64-v8a, armeabi-v7a, x86_64)
- **App Bundle:** App Bundle (.aab) 
- **Modified pubspec.yaml:** Plik konfiguracyjny
- **Retention:** APK/AAB - 1 dzień, pubspec.yaml - domyślny

### Keystore Configuration

Workflow używa `key.properties` dla podpisywania:

1. **Tworzy keystore** z `KEYSTORE_BASE64` secret
2. **Generuje `android/key.properties`** z:
   - `storeFile=app/tune-tangler-release-key.jks`
   - `storePassword=${{ secrets.KEYSTORE_PASSWORD }}`
   - `keyPassword=${{ secrets.KEY_PASSWORD }}`
   - `keyAlias=${{ vars.KEY_ALIAS }}`

### Wymagane Secrets i Variables

#### Secrets (sensitive)

- `KEYSTORE_BASE64` - base64 encoded keystore file
- `KEYSTORE_PASSWORD` - keystore password
- `KEY_PASSWORD` - key password

#### Variables (non-sensitive)

- `KEY_ALIAS` - key alias name

### Troubleshooting

#### Błąd "Permission denied"

Upewnij się że workflow ma dostęp do `GITHUB_TOKEN` (domyślnie dostępny).

#### Błąd "Flutter not found"

Sprawdź czy używasz poprawnej wersji Flutter w workflow.

#### Błąd "Java not found"

Sprawdź czy używasz poprawnej wersji Java w workflow.

#### Problem z keystore

1. Sprawdź czy wszystkie secrets i variables są ustawione
2. Sprawdź logi z kroku "Create key.properties"
3. Sprawdź czy keystore file został utworzony
4. Sprawdź czy `key.properties` zawiera poprawne dane

#### Błąd "keystore password was incorrect"

1. Sprawdź czy `KEYSTORE_PASSWORD` i `KEY_PASSWORD` są poprawne
2. Sprawdź czy `KEY_ALIAS` jest poprawny
3. Sprawdź czy keystore file nie jest uszkodzony

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
