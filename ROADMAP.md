# TuneTangler - Plan Rozwoju (Roadmap)

## **Punkty Rozwoju**

### **1. Optymalizacje Wydajności (Najwyższy Priorytet – UKOŃCZONE ✅)**

#### **Naprawione Problemy**

- ✅ **Zacinanie aplikacji**: Optymalizacja `ValueListenableBuilder`
- ✅ **Niska liczba ramek (FPS)**: Przepisanie mechanizmu stanu
- ✅ **Problemy z odtwarzaniem**: Przywrócenie `audioplayers`
- ✅ **Optymalizacje UI**: `RepaintBoundary`, throttling, lazy loading
- ✅ **Zarządzanie pamięcią**: `AudioMemoryPool`, `IconOptimizationService`

### **2. Ulepszenia UI (Średni Priorytet – UKOŃCZONE ✅)**

#### **Proste Animacje**

- ✅ **Animacje przejść**: `AnimatedContainer`, `AnimatedOpacity`
- ✅ **Responsive UI**: Płynne przejścia między stanami
- ✅ **Loading indicators**: `LinearProgressIndicator`, `CircularProgressIndicator`

#### **Interface Elements**

- ✅ **Grupowanie menu**: Menu kontekstowe dla ścieżek już zorganizowane
- ✅ **Szybkie akcje**: Globalne akcje i per-row już dostępne
- ✅ **Modalne okna**: `showModalBottomSheet` dla szczegółów ścieżki, `AlertDialog`/`SimpleDialog` dla ustawień
- ✅ **Tooltips**: Implementowane w szczegółach ścieżki i przyciskach

#### **Uwagi dotyczące UI:**

- ❌ **Vibrace/Haptic feedback** - mogłyby się nagrywać na ścieżkę audio
- ❌ **Dodatkowe gesty** - część już jest (swipe do poruszania ścieżek), reszta zbędna
- ❌ **Pinch-to-zoom** - niepotrzebne w kontekście aplikacji

### **3. Eksport i Import (Wysoki Priorytet)**

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

### **4. Efekty Audio (Odłożone na Później)**

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

### **5. System Licencji (Średni Priorytet)**

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

### **6. Funkcje Audio (Niski Priorytet)**

#### **Przetwarzanie**

- **Noise reduction**: Zaawansowane usuwanie szumu
- **Normalization**: Automatyczne wyrównanie głośności
- **Fade in/out**: Płynne wejścia i wyjścia
- **Crossfade**: Płynne przejścia między ścieżkami

#### **Analiza**

- **BPM detection**: Automatyczne wykrywanie tempa
- **Key detection**: Wykrywanie tonacji
- **Waveform visualization**: Wizualizacja fali dźwiękowej
- **Spectral analysis**: Analiza częstotliwości

### **7. Kompatybilność Platformowa (Niski Priorytet)**

- **iOS 17+**: Pełna obsługa nowych funkcji
- **Android 14+**: Material You, dynamic colors
- **Desktop**: Rozszerzenie na Windows/macOS/Linux
- **Web**: PWA w przeglądarce

## **Uwagi i Ustalenia**

### **Zrezygnowano z:**

- ❌ **Funkcji Prywatności** (szyfrowanie, biometria) – niepotrzebne komplikacje
- ❌ **Analityk Lokalnych** (statystyki użytkowania) – narusza prywatność
- ❌ **Mechaniki efektów audio** (tymczasowo usunięta) – problemy z `just_audio`

### **Kluczowe Zasady:**

- **Aplikacja ma pozostać maksymalnie prywatna** – brak synchronizacji z chmurą
- **Brak współpracy online** – wszystkie funkcje lokalne
- **MIDI nie jest potrzebne** – skupienie na audio processing
- **Wydajność jest krytyczna** ✅ – problemy z zacinaniem zostały naprawione
- **Stabilność audio** ✅ – przywrócono `audioplayers` zamiast `just_audio`

### **Następne Kroki:**

1. **Ulepszenia UI** – dalsze poprawki interfejsu użytkownika
2. **Eksport/Import** – kluczowa funkcja dla użytkowników profesjonalnych
3. **System licencji** – umożliwia rozwój aplikacji przy zachowaniu podstawowych funkcji bezpłatnych
4. **Efekty audio** – implementacja w przyszłości z lepszą biblioteką
