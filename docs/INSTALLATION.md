# 📱 Instalacja

> Aby zainstalować aplikację, musisz wybrać paczkę w odpowiedniej architekturze ABI.

## 📋 Spis Treści

- [🔍 Jak sprawdzić ABI Androida](#how-to-check-android-abi)
  - [📱 Metoda 1: Aplikacja z Google Play](#method-1-google-play-app)
  - [💻 Metoda 2: Komputer + ADB](#method-2-computer-adb)
- [📚 Dodatkowe Zasoby](#additional-resources)

## 🔍 Jak sprawdzić ABI Androida <a name="how-to-check-android-abi"></a>

Poszukujesz informacji o wersji, np.:

- `arm64-v8a` – nowoczesna 64-bitowa architektura ARM
- `armeabi-v7a` – starsza architektura ARM
- `x86` – Intel

### 📱 Metoda 1: Aplikacja z Google Play <a name="method-1-google-play-app"></a>

1. **Wejdź do Google Play** na swoim telefonie.
2. **Wyszukaj** jedną z aplikacji, np. `AIDA64` lub `Device Info HW`.
3. **Zainstaluj** wybraną aplikację.
4. **Uruchom** aplikację po instalacji.
5. **Przejdź do zakładki** `Procesor`, `CPU`, albo podobnej.
6. **Odczytaj informację** o architekturze lub ABI.

### 💻 Metoda 2: Komputer + ADB <a name="method-2-computer-adb"></a>

1. **Zainstaluj program `ADB`** na komputerze (instrukcja
   na [oficjalnej stronie Android](https://developer.android.com/tools/adb?hl=pl)).
2. **Odblokuj "Opcje programisty"** na telefonie wejdź w: Ustawienia → O telefonie → Informacje o wersji → kliknij kilka
   razy „Numer kompilacji”.
3. **Aktywuj "Debugowanie USB"** na telefonie wejdź w: Ustawienia → System → Opcje programisty → Debugowanie USB.
4. **Podłącz telefon**

    - Kablem USB.
    - Przez wifi
        - w "Opcjach programisty" znajdź "Debugowanie bezprzewodowe" i go włącz
        - wejdź w ustawienia zaawansowane, gdzie znajdziesz adres IP i port urządzenia.
        - na komputerze w terminalu wpisz polecenie: `adb connect IP:PORT`
5. **Otwórz Terminal** na komputerze i wpisz:

    ```sh
    adb shell getprop ro.product.cpu.abi
    ```

## 📚 **Dodatkowe Zasoby** <a name="additional-resources"></a>

- **[Android ABI Guide](https://developer.android.com/ndk/guides/abis)** – Oficjalna dokumentacja ABI
- **[ADB Installation](https://developer.android.com/tools/adb)** – Instalacja ADB
- **[Device Setup](https://developer.android.com/studio/run/device)** – Konfiguracja urządzenia
