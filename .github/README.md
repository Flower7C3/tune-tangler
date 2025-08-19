# GitHub Workflows

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

## Workflowy

### 1. CI (Continuous Integration)
**Plik:** `ci.yml`
**Uruchamiany:** Przy każdym push i pull request na branchy `main`, `develop`, `new-features`

**Co robi:**
- ✅ Weryfikuje kod (analyze, testy)
- ✅ Generuje pliki lokalizacji
- ✅ Buduje APK debug
- ✅ Uploaduje APK debug jako artifact

### 2. Release
**Plik:** `release.yml`
**Uruchamiany:** Przy push tagów wersji (np. `v1.1.4`) lub manualnie

**Co robi:**
- ✅ Weryfikuje kod (analyze, testy)
- ✅ Generuje pliki lokalizacji
- ✅ Buduje APK release
- ✅ Tworzy GitHub Release z APK
- ✅ Uploaduje APK release jako artifact

### 3. Auto Tag
**Plik:** `auto-tag.yml`
**Uruchamiany:** Przy push na branch `main`

**Co robi:**
- ✅ Automatycznie tworzy tag wersji na podstawie `pubspec.yaml`
- ✅ Pushuje tag na GitHub
- ✅ Uruchamia workflow Release

## Jak używać

### Automatyczne Release
1. Zmergeuj zmiany do `main` branch
2. Workflow Auto Tag automatycznie utworzy tag (np. `v1.1.4`)
3. Workflow Release automatycznie utworzy release z APK

### Manualne Release
1. Utwórz tag lokalnie: `git tag v1.1.4`
2. Pushuj tag: `git push origin v1.1.4`
3. Workflow Release automatycznie się uruchomi

### Pominięcie CI
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

- **CI:** APK debug (retention: 7 dni)
- **Release:** APK release (retention: bez limitu)

## Troubleshooting

### Błąd "Permission denied"
Upewnij się że workflow ma dostęp do `GITHUB_TOKEN` (domyślnie dostępny).

### Błąd "Flutter not found"
Sprawdź czy używasz poprawnej wersji Flutter w workflow.

### Błąd "Java not found"
Sprawdź czy używasz poprawnej wersji Java w workflow.
