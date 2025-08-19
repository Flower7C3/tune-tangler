# GitHub Workflows

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

## Workflowy

### 1. Release + Auto Tag (Integrated)
**Plik:** `release.yml`
**Uruchamiany:** Przy push na branch `master` lub tagów wersji

**Co robi:**
- ✅ Weryfikuje kod (analyze, testy)
- ✅ Generuje pliki lokalizacji
- ✅ Automatycznie zwiększa patch version i build number (przy push na master)
- ✅ Buduje APK release
- ✅ Automatycznie tworzy tag wersji (przy push na master)
- ✅ Tworzy GitHub Release z APK
- ✅ Uploaduje APK release jako artifact

## Jak używać

### Automatyczne Release
1. Zmergeuj zmiany do `master` branch
2. Workflow automatycznie utworzy tag (np. `v1.1.4`)
3. Workflow automatycznie utworzy release z APK

### Manualne Release
1. Utwórz tag lokalnie: `git tag v1.1.4`
2. Pushuj tag: `git push origin v1.1.4`
3. Workflow automatycznie się uruchomi

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

- **CI:** APK debug (retention: 7 dni)
- **Release:** APK release (retention: bez limitu)

## Troubleshooting

### Błąd "Permission denied"
Upewnij się że workflow ma dostęp do `GITHUB_TOKEN` (domyślnie dostępny).

### Błąd "Flutter not found"
Sprawdź czy używasz poprawnej wersji Flutter w workflow.

### Błąd "Java not found"
Sprawdź czy używasz poprawnej wersji Java w workflow.
