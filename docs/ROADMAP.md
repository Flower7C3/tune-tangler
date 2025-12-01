# 🗺️ TuneTangler - Plan Rozwoju (Roadmap)

## 📋 Spis Treści

- [🎯 Planowane prace](#planowane-prace)
  - [3️⃣ Eksport i Import](#3-eksport-i-import-wysoki-priorytet)
  - [4️⃣ Efekty Audio](#4-efekty-audio-odłożone--wymaga-dsp)
  - [5️⃣ System Licencji](#5-system-licencji-średni-priorytet)
  - [6️⃣ Funkcje Audio](#6-funkcje-audio-niski-priorytet)
  - [7️⃣ Odtwarzanie: audioplayers vs just_audio](#7-odtwarzanie-audio-audioplayers-vs-just_audio-analiza--plan)
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

## 📚 Dodatkowe Zasoby
- Zdolności aplikacji: zob. [README.md](../README.md#capabilities)
- Zrealizowane elementy (commity): zob. [docs/COMPLETED.md](./COMPLETED.md)
- Flutter Roadmap: https://github.com/flutter/flutter/wiki/Roadmap
- Android Roadmap: https://developer.android.com/about/versions
