# GitHub Workflows

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

- **Test** → **Build** → **Version Control** → **Release**

## Workflowy

### 1. Release + Auto Tag (Integrated)

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

## Jak używać

### 1. Manualne Release (jedyna opcja)

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Build & Release Workflow"**
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – workflow automatycznie:
   - Pobierze wersję z `pubspec.yaml`
   - Utworzy tag `v{version}-build-{run_number}`
   - Zbuduje i zweryfikuje aplikację
   - Utworzy GitHub Release

### 2. Testowanie Build Process

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Test Build Workflow"** (jeśli istnieje)
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – szczególnie kroki debugowania

### Pominięcie Workflow

Dodaj `[skip ci]` do wiadomości commita aby pominąć automatyczne workflowy.

## Wymagania

- Flutter 3.35.1
- Java 17 (Zulu)
- Ubuntu Latest runner
- GitHub Token (automatycznie dostępny)

## Cache

Workflowy używają cache dla:

- `~/.pub-cache` (Flutter dependencies)
- `~/.gradle/caches` (Android dependencies)

## Artifacts

- **APK Release:** Split-per-ABI APKs (arm64-v8a, armeabi-v7a, x86_64)
- **App Bundle:** App Bundle (.aab) 
- **Modified pubspec.yaml:** Plik konfiguracyjny
- **Retention:** APK/AAB - 1 dzień, pubspec.yaml - domyślny

## Keystore Configuration

Workflow używa `key.properties` dla podpisywania:

1. **Tworzy keystore** z `KEYSTORE_BASE64` secret
2. **Generuje `android/key.properties`** z:
   - `storeFile=app/tune-tangler-release-key.jks`
   - `storePassword=${{ secrets.KEYSTORE_PASSWORD }}`
   - `keyPassword=${{ secrets.KEY_PASSWORD }}`
   - `keyAlias=${{ vars.KEY_ALIAS }}`

## Wymagane Secrets i Variables

### Secrets (sensitive)

- `KEYSTORE_BASE64` - base64 encoded keystore file
- `KEYSTORE_PASSWORD` - keystore password
- `KEY_PASSWORD` - key password

### Variables (non-sensitive)

- `KEY_ALIAS` - key alias name

## Troubleshooting

### Błąd "Permission denied"

Upewnij się że workflow ma dostęp do `GITHUB_TOKEN` (domyślnie dostępny).

### Błąd "Flutter not found"

Sprawdź czy używasz poprawnej wersji Flutter w workflow.

### Błąd "Java not found"

Sprawdź czy używasz poprawnej wersji Java w workflow.

### Problem z keystore

1. Sprawdź czy wszystkie secrets i variables są ustawione
2. Sprawdź logi z kroku "Create key.properties"
3. Sprawdź czy keystore file został utworzony
4. Sprawdź czy `key.properties` zawiera poprawne dane

### Błąd "keystore password was incorrect"

1. Sprawdź czy `KEYSTORE_PASSWORD` i `KEY_PASSWORD` są poprawne
2. Sprawdź czy `KEY_ALIAS` jest poprawny
3. Sprawdź czy keystore file nie jest uszkodzony
