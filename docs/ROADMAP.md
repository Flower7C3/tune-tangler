# 🗺️ TuneTangler - Plan Rozwoju (Roadmap)

## 📋 Spis Treści

- [🎯 Punkty Rozwoju](#-punkty-rowoju)
  - [1️⃣ Optymalizacje Wydajności](#-optymalizacje-wydajności)
  - [2️⃣ Ulepszenia UI](#-ulepszenia-ui)
  - [3️⃣ Eksport i Import](#-eksport-i-import)
  - [4️⃣ Efekty Audio](#-efekty-audio)
  - [5️⃣ System Licencji](#-system-licencji)
  - [6️⃣ Funkcje Audio](#-funkcje-audio)
- [📚 Dodatkowe Zasoby](#-dodatkowe-zasoby)

## 🎯 **Punkty Rozwoju**

### **1️⃣ Optymalizacje Wydajności (Najwyższy Priorytet – UKOŃCZONE ✅)**

#### **Naprawione Problemy**

- ✅ **Zacinanie aplikacji**: Optymalizacja `ValueListenableBuilder`
- ✅ **Niska liczba ramek (FPS)**: Przepisanie mechanizmu stanu
- ✅ **Problemy z odtwarzaniem**: Przywrócenie `audioplayers` i naprawa `duration`
- ✅ **Progress bar i licznik sekund**: Poprawne działanie po imporcie plików
- ✅ **Jednoczesne odtwarzanie**: Konfiguracja `AudioContext` dla multi-track playback
- ✅ **Optymalizacje UI**: `RepaintBoundary`, throttling, lazy loading
- ✅ **Zarządzanie pamięcią**: `AudioMemoryPool`, `IconOptimizationService`
- ✅ **Aktualizacja bibliotek**: 38 zależności zaktualizowanych do najnowszych wersji

### **2️⃣ Ulepszenia UI (Średni Priorytet – UKOŃCZONE ✅)**

#### **Proste Animacje**

- ✅ **Animacje przejść**: `AnimatedContainer`, `AnimatedOpacity`
- ✅ **Responsive UI**: Płynne przejścia między stanami
- ✅ **Loading indicators**: `LinearProgressIndicator`, `CircularProgressIndicator`

#### **Interface Elements**

- ✅ **Grupowanie menu**: Menu kontekstowe dla ścieżek już zorganizowane
- ✅ **Szybkie akcje**: Globalne akcje i per-row już dostępne
- ✅ **Modalne okna**: `showModalBottomSheet` dla szczegółów ścieżki,
  `AlertDialog`/`SimpleDialog` dla ustawień
- ✅ **Tooltips**: Implementowane w szczegółach ścieżki i przyciskach

#### **Uwagi dotyczące UI:**

- ❌ **Vibrace/Haptic feedback** – mogłyby się nagrywać na ścieżkę audio
- ❌ **Dodatkowe gesty** – część już jest (swipe do poruszania ścieżek), reszta zbędna
- ❌ **Pinch-to-zoom** – niepotrzebne w kontekście aplikacji

### **3️⃣ Eksport i Import (Wysoki Priorytet – W TRAKCIE ROZWOJU)**

#### **Eksport Wszystkich Ścieżek**

- **Kompletny backup**: Wszystkie ścieżki wraz z nagraniami
- **Ustawienia**: Profile konfiguracyjne, preferencje użytkownika
- **Metadane**: Nazwy, skróty klawiszowe, pozycje na siatce
- **Formaty**: ZIP z zachowaniem struktury katalogów
- **Wersjonowanie**: Automatyczne tworzenie kopii zapasowych

#### **Import Ścieżek**

- **Przywracanie**: Pełne przywracanie z backupu
- **Merge**: Łączenie z istniejącymi ścieżkami
- **Konflikty**: Rozwiązywanie konfliktów nazw i ID
- **Walidacja**: Sprawdzanie integralności importowanych danych
- **Preview**: Podgląd przed importem

### **4️⃣ Efekty Audio (Odłożone na Później – WYMAGA NOWEJ BIBLIOTEKI)**

- **Podstawowe efekty**:
    - Reverb (pomieszczenie, hala, echo)
    - Delay/Echo (z kontrolą czasu i feedback)
    - Compression (dynamika, punch)
    - EQ (3-5 pasmowe, low/high pass)

- **Zaawansowane efekty**:
    - Distortion/Overdrive
    - Chorus/Flanger
    - Pitch shift (transpozycja w czasie rzeczywistym)
    - Time stretching (bez zmiany pitch)

### **5️⃣ System Licencji (Średni Priorytet)**

#### **Funkcje Podstawowe (Bezpłatne)**

- **Nagrywanie**: Podstawowe nagrywanie audio
- **Odtwarzanie**: Podstawowe odtwarzanie ścieżek
- **Siatka**: Podstawowa siatka 6×4
- **Ulepszenia UI**: Wszystkie optymalizacje interfejsu

#### **Funkcje Zaawansowane (Licencja)**

- **Profile**: Zaawansowane profile ustawień
- **Eksport/Import**: Pełne funkcje backupu i przywracania
- **Efekty Audio**: Wszystkie efekty audio (gdy zostaną zaimplementowane)
- **Siatka Rozszerzona**: Duże siatki (8×6, 10×8)

#### **Model Licencjonowania**

- **Jednorazowa płatność**: Wszystkie funkcje dostępne
- **Bezpłatne**: Podstawowe funkcje zawsze dostępne

### **6️⃣ Funkcje Audio (Niski Priorytet)**

#### **Przetwarzanie**

- **Noise reduction**: Zaawansowane usuwanie szumu
- **Normalization**: Automatyczne wyrównanie głośności
- **Fade in/out**: Płynne wejścia i wyjścia
- **Crossfade**: Płynne przejścia między ścieżkami

## 📚 **Dodatkowe Zasoby**

- **[📖 Development Guide](../README.md)** – Główny przewodnik
- **[Flutter Roadmap](https://github.com/flutter/flutter/wiki/Roadmap)** – Oficjalny plan rozwoju Flutter
- **[Android Roadmap](https://developer.android.com/about/versions)** – Plan rozwoju Android
