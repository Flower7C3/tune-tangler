# 🗺️ TuneTangler - Plan Rozwoju (Roadmap)

## 📋 Spis Treści

- [🎯 Planowane prace](#planowane-prace)
  - [3️⃣ Eksport i Import](#3-eksport-i-import-wysoki-priorytet)
  - [4️⃣ Efekty Audio](#4-efekty-audio-odłożone--wymaga-dsp)
  - [5️⃣ System Licencji](#5-system-licencji-średni-priorytet)
  - [6️⃣ Funkcje Audio](#6-funkcje-audio-niski-priorytet)
  - [7️⃣ Odtwarzanie: audioplayers vs just_audio](#7-odtwarzanie-audio-audioplayers-vs-just_audio-analiza--plan)
  - [8️⃣ Jakość wydania: Android 15, zależności, QA, a11y](#8-jakość-wydania-android-15-zależności-qa-a11y)
- [📚 Dodatkowe Zasoby](#dodatkowe-zasoby)

## 🎯 Planowane prace

### 3) Eksport i Import (Wysoki Priorytet)

#### Eksport wszystkich ścieżek
- Kompletny backup: wszystkie ścieżki wraz z nagraniami
- Ustawienia: profile konfiguracyjne, preferencje użytkownika
- Metadane: nazwy, skróty klawiszowe, pozycje na siatce
- Format: ZIP z zachowaniem struktury katalogów
- Wersjonowanie: automatyczne tworzenie kopii zapasowych

#### Import ścieżek
- Przywracanie: pełne przywracanie z backupu
- Merge: łączenie z istniejącymi ścieżkami
- Konflikty: rozwiązywanie konfliktów nazw i ID
- Walidacja: sprawdzanie integralności importowanych danych
- Preview: podgląd przed importem

### 4) Efekty Audio (Odłożone – Wymaga DSP)
- Podstawowe efekt: Reverb, Delay/Echo, Compression, EQ (LP/HP)
- Zaawansowane: Distortion, Chorus/Flanger, Pitch shift, Time stretching
- Wymaga integracji natywnego DSP lub dedykowanych wtyczek (Android/iOS)

### 5) System Licencji (Średni Priorytet)
#### Funkcje podstawowe (bezpłatne)
- Nagrywanie, odtwarzanie, siatka 6×4, optymalizacje UI
#### Funkcje zaawansowane (licencja)
- Profile, pełny backup/restore, efekty audio (po wdrożeniu), większe siatki
#### Model licencjonowania
- Jednorazowa płatność za pełen pakiet (TBD)

### 6) Funkcje Audio (Niski Priorytet)
- Noise reduction, Normalization, Fade in/out, Crossfade

### 7) Odtwarzanie audio: audioplayers vs just_audio (Analiza + Plan)
#### Stan obecny (audioplayers)
- Głośność, balans, prędkość, pętla, seek, zdarzenia, kontekst audio
#### just_audio – pokrycie
- Głośność, prędkość, pętla/seek/zdarzenia, ClippingAudioSource, playlisty/gapless
- Pan: wymaga pluginu; EQ: możliwy (Android) przez wtyczki
#### Plan
- Krótkoterminowo: pozostajemy przy audioplayers (render FFmpeg dla „zmodyfikowanych”)
- Średni termin: prototyp ClippingAudioSource; rozpoznać pan plugin
- Długi termin: EQ (Android) + AVAudioEngine (iOS) za flagą; rozważyć wspólną warstwę DSP

### 8) Jakość wydania: Android 15, zależności, QA, a11y

Sekcja zbiera ustalenia z przeglądu repozytorium (m.in. `git log`, `flutter pub outdated`) — część punktów jest **już zaimplementowana w kodzie**, reszta to **kontynuacja poza samym commitem** (testy ręczne, monitoring upstream).

#### Co jest już zrobione (kod / produkt)
- **Android 15 — tryb edge-to-edge:** konfiguracja natywna (`WindowCompat.setDecorFitsSystemWindows(false)` przed cyklem `FlutterActivity`), motywy bez `windowOptOutEdgeToEdgeEnforcement`, `SystemUiMode.edgeToEdge` po stronie Dart; spójne z wcześniejszą rezerwą miejsca pod pasem nawigacji na siatce ścieżek (zob. commity w okolicy `fix(android): enable edge-to-edge for Android 15` oraz wcześniejsze poprawki insetów).
- **Eksport udostępniania nagrania:** brak opcji „zmodyfikowane”, gdy parametry odtwarzania i trim są domyślne (uniknięcie zbędnego wyboru).
- **Pomoc (l10n):** doprecyzowania legend ikon (balans, przycięcie, tryb odtwarzania), opis siatki (tryb klawiatury w szufladzie, klawisz modyfikujący Control / często Cmd na Macu), porządki w EN (m.in. zdania sukcesu), spójność „stuknij” / „tap” w stanach ścieżki.

#### Co nadal wymaga działania
- **Zależności:** `flutter pub outdated` nadal wskazuje m.in. podbicia **minor** (`file_picker` 11.0.1→11.0.2, `path_provider_android` 2.2.23→2.3.1) oraz ewentualne **major** (`share_plus` 12→13, `package_info_plus` 9→10) — każda zmiana major wymaga przeglądu changelogu i smoke testów (nagrywanie, import pliku, udostępnianie, eksport projektu).
- **Google Play / Android 15 — ostrzeżenia o wycofanych API okien** (`setStatusBarColor`, ślad w `PlatformPlugin`, czasem Material Date Picker): mogą **pozostać mimo** edge-to-edge w aplikacji, dopóki silnik Fluttera / zależności nie przestaną wołać tych ścieżek. Warto **co wydanie stable** sprawdzać release notes Fluttera i ponawiać **Pre-launch report** po podniesieniu wersji SDK narzędzia.
- **QA ręczne na API 35+:** potwierdzenie wizualne po edge-to-edge (szuflada, dialogi, bottom sheet, obrót ekranu jeśli włączony, jasny/ciemny motyw, nawigacja gestami vs trzy przyciski). Nie zastępuje tego analiza statyczna samego repozytorium.
- **Dostępność (a11y):** w kodzie pomocy (`Drawer` → Pomoc) **nie ma** jeszcze dedykowanych działań pod **wysoki `textScaler`** ani rozszerzonej semantyki (TalkBack) dla długich legend ikon — do zaplanowania osobno (kontrast `ExpansionTile`, minimalna czytelna typografia, ewentualnie `Semantics`).

#### Checklista QA (skrót, Android 15+)
1. Siatka ścieżek: AppBar, szuflada, footer, brak nachodzenia na status bar / obszar gestów.  
2. Szczegóły ścieżki, dialogi, dolny sheet przy klawiaturze (`windowSoftInputMode`).  
3. Obrót poziomy (jeśli włączony w manifeście / ustawieniach urządzenia).

## 📚 Dodatkowe Zasoby
- Zdolności aplikacji: zob. [README.md](../README.md#capabilities)
- Zrealizowane elementy (commity): zob. [docs/COMPLETED.md](./COMPLETED.md)
- Flutter Roadmap: https://github.com/flutter/flutter/wiki/Roadmap
- Android Roadmap: https://developer.android.com/about/versions
