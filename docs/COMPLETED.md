# ✅ Zrealizowane elementy (z commitami)

- Optymalizacje wydajności (throttling, lazy‑loading, multi‑ValueListenable): 
  [de16e9e](https://github.com/Flower7C3/tune-tangler/commit/de16e9e), 
  [d71fd92](https://github.com/Flower7C3/tune-tangler/commit/d71fd92), 
  [6591437](https://github.com/Flower7C3/tune-tangler/commit/6591437)
- Ulepszenia UI (menu, ikony, szczegóły, toasty): 
  [d71fd92](https://github.com/Flower7C3/tune-tangler/commit/d71fd92), 
  [de16e9e](https://github.com/Flower7C3/tune-tangler/commit/de16e9e)
- Bezpieczna zamiana ścieżek (walidacja, rename/copy fallback, migracja preferencji): 
  [67f548f](https://github.com/Flower7C3/tune-tangler/commit/67f548f) (+ follow‑ups)
- Udostępnianie nagrań: surowe i „zmodyfikowane” (FFmpeg pipeline): 
  [92ee486](https://github.com/Flower7C3/tune-tangler/commit/92ee486)
- i18n (odświeżenie ARB + generaty, lokalizowane błędy): 
  [129a95e](https://github.com/Flower7C3/tune-tangler/commit/129a95e)
- Workflow wydawniczy: automatyczny bump wersji, tag `v<version>-build-<run_number>`: 
  [3d8139d](https://github.com/Flower7C3/tune-tangler/commit/3d8139d)
- Ekran pomocy: rozwinięte sekcje z ikonami i opisami (Drawer → Pomoc) 
  (zob. też zmiany w commitach UI powyżej)
- **Eksport i import projektu**: 
  - Eksport projektu do pliku ZIP zawierający:
    - Ustawienia siatki (liczba wierszy i kolumn)
    - Wszystkie ustawienia ścieżek (nazwa, parametry odtwarzania, trimming, skróty klawiszowe, metadane nagrywania)
    - Wszystkie nagrania audio z sumami kontrolnymi (SHA256)
    - Metadane projektu (wersja, data eksportu, statystyki)
  - Import projektu z pełną walidacją przed modyfikacją danych:
    - Walidacja struktury ZIP, plików JSON, sum kontrolnych nagrań
    - Podgląd projektu przed importem
    - Ostrzeżenie o nadpisaniu bieżącej sesji
    - Automatyczne czyszczenie cache i odświeżenie UI po imporcie
  - Format nazwy pliku: `tune_tangler_project_[nazwa]_YYYYMMDD_HHMMSS.zip`
  - UI w menu głównym (AppBar → "Zapisz projekt" / "Wczytaj projekt")
  - Poprawne zachowanie trimming (playbackStartAtPosition, playbackEndAtPosition) podczas importu
  - Non-breaking spaces (nbsp) w tłumaczeniach dla lepszego formatowania tekstu
  - Szczegółowa dokumentacja: [docs/PROJECT_EXPORT_IMPORT.md](./PROJECT_EXPORT_IMPORT.md)

Powiązane dokumenty:
- Planowane prace: [docs/ROADMAP.md](./ROADMAP.md)
- Zdolności aplikacji: [README.md#capabilities](../README.md#capabilities)
- Analiza eksportu/importu: [docs/PROJECT_EXPORT_IMPORT_ANALYSIS.md](./PROJECT_EXPORT_IMPORT_ANALYSIS.md)
