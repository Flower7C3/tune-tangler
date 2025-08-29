# Installation

Aby zainstalować aplikację, musisz wybrać paczkę w odpowiedniej architekturze ABI.

## Jak sprawdzić ABI Androida

Poszukujesz informacji o wersji, np.:
- `arm64-v8a` – nowoczesna 64-bitowa architektura ARM
- `armeabi-v7a` – starsza architektura ARM
- `x86` – Intel

### Metoda 1: Aplikacja z Google Play

1. **Wejdź do Google Play** na swoim telefonie.
2. **Wyszukaj** jedną z aplikacji, np. `AIDA64` lub `Device Info HW`.
3. **Zainstaluj** wybraną aplikację.
4. **Uruchom** aplikację po instalacji.
5. **Przejdź do zakładki** `Procesor`, `CPU`, albo podobnej.
6. **Odczytaj informację** o architekturze lub ABI.

### Metoda 2: Komputer + ADB

1. **Zainstaluj program `ADB`** na komputerze (instrukcja na [oficjalnej stronie Android](https://developer.android.com/tools/adb?hl=pl)).
2. **Odblokuj "Opcje programisty"** na telefonie wejdź w: Ustawienia → O telefonie → Informacje o wersji → kliknij kilka razy „Numer kompilacji”.
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
