# Eksport i Import Projektu

## 📋 Przegląd

Funkcjonalność eksportu i importu projektu umożliwia zapisanie całego stanu aplikacji (ustawienia siatki, wszystkie ścieżki z nagraniami) do pliku ZIP oraz późniejsze wczytanie go z pełną walidacją i podglądem.

## ✨ Funkcjonalności

### Eksport Projektu

- **Lokalizacja**: Menu główne (AppBar) → "Zapisz projekt"
- **Format pliku**: `tune_tangler_project_[nazwa]_YYYYMMDD_HHMMSS.zip`
- **Zawartość ZIP**:
  - `metadata.json` - metadane projektu (wersja, data eksportu, statystyki, lista ścieżek)
  - `settings/grid_settings.json` - ustawienia siatki (liczba wierszy i kolumn)
  - `tracks/[TrackId].json` - ustawienia każdej ścieżki (wszystkie pola z `Track.toMap()`)
  - `recordings/[TrackId].[ext]` - pliki nagrań audio
  - `recordings/checksums.json` - sumy kontrolne SHA256 dla wszystkich nagrań

### Import Projektu

- **Lokalizacja**: Menu główne (AppBar) → "Wczytaj projekt"
- **Proces**:
  1. Wybór pliku ZIP przez `file_picker`
  2. **Walidacja** (bez modyfikacji danych):
     - Sprawdzenie struktury ZIP
     - Walidacja plików JSON (metadata, settings, tracks)
     - Weryfikacja sum kontrolnych nagrań
     - Sprawdzenie zgodności długości plików z metadanymi
  3. **Podgląd projektu**:
     - Nazwa projektu
     - Data eksportu
     - Rozmiar siatki (z obliczoną liczbą ścieżek)
     - Statystyki (ścieżki z nagraniami, całkowity rozmiar nagrań)
  4. **Ostrzeżenie**: Informacja o nadpisaniu bieżącej sesji
  5. **Import** (po potwierdzeniu):
     - Usunięcie wszystkich istniejących nagrań
     - Reset wszystkich ustawień ścieżek do wartości domyślnych
     - Import ustawień siatki
     - Import ustawień wszystkich ścieżek
     - Import nagrań z weryfikacją sum kontrolnych
     - Automatyczne odświeżenie UI

## 🔧 Szczegóły Techniczne

### Eksport

- **Pliki**: `lib/service/project_export_service.dart`
- **Manager UI**: `lib/manager/project_export_import_manager.dart`
- **Konwersja danych**:
  - `TrackId` → `[row, col]` (lista)
  - `Duration` → milisekundy (int)
  - Czyszczenie znaków kontrolnych z nazw ścieżek
  - UTF-8 encoding wszystkich plików JSON

### Import

- **Pliki**: `lib/service/project_import_service.dart`
- **Walidacja**: Pełna walidacja przed jakąkolwiek modyfikacją danych
- **Obsługa błędów**:
  - Szczegółowe komunikaty błędów dla użytkownika
  - Ostrzeżenia dla problemów, które nie blokują importu
  - Weryfikacja sum kontrolnych i długości plików
- **Trimming**: Poprawne zachowanie `playbackStartAtPosition` i `playbackEndAtPosition`:
  - Zapis wartości przed `setPath()`
  - Przywrócenie po zakończeniu ładowania pliku
  - Walidacja, że `playbackEndAtPosition` nie przekracza `duration` z pliku

### Odświeżenie UI

- **Cache**: Czyszczenie `LazyLoadingManager` cache po imporcie
- **State management**: 
  - `HiveSettingsProvider.reload()` - inkrementacja wersji i `notifyListeners()`
  - `context.watch<HiveSettingsProvider>()` w `MainScreenApp` dla automatycznego rebuild
  - Widget keys z wersją dla wymuszenia rebuild `ListView.builder`

## 🎨 UI/UX

### Podgląd Projektu

- **Ikony**:
  - Data eksportu: kalendarz (`Icons.calendar_today_rounded`)
  - Rozmiar nagrań: storage (`Icons.storage_rounded`)
  - Rozmiar siatki: siatka (`Icons.grid_4x4_rounded`)
- **Uproszczenie**: Rozmiar siatki pokazuje również obliczoną liczbę ścieżek (np. "6 x 4 (24 ścieżek)")
- **Formatowanie**: Non-breaking spaces (nbsp) w tłumaczeniach dla lepszego formatowania

### Dialogi

- **Progress**: Wskaźniki postępu podczas walidacji i importu
- **Błędy**: Szczegółowa lista błędów i ostrzeżeń po imporcie
- **Ostrzeżenia**: Komunikat o nadpisaniu bieżącej sesji przed importem

## 📝 Tłumaczenia

- Dodano klucze dla wszystkich komunikatów eksportu/importu
- Non-breaking spaces (`\u00A0`) przed jednostkami (MB, min, Hz, kbps) i w polskich frazach
- Zaktualizowane ostrzeżenia o nadpisaniu ustawień ścieżek

## 🐛 Naprawione Problemy

1. **Trimming nie był importowany**: Naprawiono przez zapis wartości przed `setPath()` i przywrócenie po zakończeniu
2. **UI nie odświeżało się po imporcie**: Naprawiono przez czyszczenie cache i użycie `context.watch()`
3. **CircularProgressIndicator zapętlał się**: Dodano timeout (5 sekund) i poprawioną logikę oczekiwania
4. **FormatException z znakami kontrolnymi**: Dodano czyszczenie znaków kontrolnych podczas eksportu i importu
5. **Brakujące nagrania podczas importu**: Poprawiono logikę dopasowywania plików do ścieżek (metadata mapping → filename → trackId)

## 📚 Powiązane Pliki

- `lib/service/project_export_service.dart` - logika eksportu
- `lib/service/project_import_service.dart` - logika importu i walidacji
- `lib/manager/project_export_import_manager.dart` - UI i koordynacja
- `lib/config/app_icon.dart` - ikony dla eksportu/importu
- `lib/l10n/app_*.arb` - tłumaczenia

## 🔗 Zobacz też

- [Analiza eksportu/importu](./PROJECT_EXPORT_IMPORT_ANALYSIS.md) - szczegółowa analiza przed implementacją
- [Zrealizowane elementy](./COMPLETED.md) - lista ukończonych funkcji
