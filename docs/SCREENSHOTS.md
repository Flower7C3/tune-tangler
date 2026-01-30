# Zrzuty ekranu do Google Play

Zrzuty robisz na urządzeniu lub emulatorze; zapis trafia do `assets/screenshots/`.

## Seryjne zrzuty: `make screenshots`

Pełny zestaw (języki en/pl, tryby light/dark, ekrany: main, recording, details, drawer).

| Parametr        | Opis |
|-----------------|------|
| **DEVICE_ID**   | ID w ADB (np. `emulator-5554`). Puste = wybór z listy. |
| **DEVICE_NAME** | Nazwa w plikach (np. `pixel9`, `tablet7`, `tablet10`). Puste = DEVICE_ID. |

```bash
make screenshots                                    # wybór urządzenia z listy
make screenshots DEVICE_NAME=tablet10               # nazwa plików: tablet10
make screenshots DEVICE_ID=emulator-5554 DEVICE_NAME=tablet10
```

Nazwy plików: `tune-tangler-<DEVICE_NAME>-<lang>-<mode>-<screen>.png`.  
Dla każdej pary język+tryb skrypt czeka na Enter (przełącz w aplikacji, naciśnij Enter).

## Wymagania Google Play

| Typ       | Min. rozdzielczość |
|----------|---------------------|
| Telefon  | 320 px (krótszy bok) |
| Tablet 7"  | 1024 × 600 |
| Tablet 10" | 1280 × 800 |

[Tablet optimization](https://support.google.com/googleplay/android-developer/answer/2617018)

## Emulatory

**Android Studio → Device Manager → Create Device**: wybierz telefon (np. Pixel 7), tablet 7" (np. Nexus 7, 1920×1200) lub 10" (np. Pixel Tablet, 2560×1600). System Image np. API 34.

Uruchom AVD, zainstaluj aplikację (`make run`), potem np. `make screenshots DEVICE_NAME=tablet7`.  
Na prawdziwym telefonie zrzut: zasilanie + zmniejszenie głośności; pliki w galerii.

## Pojedynczy zrzut (ADB)

```bash
adb exec-out screencap -p > assets/screenshots/screenshot.png
# Wiele urządzeń: adb -s <device_id> exec-out screencap -p > ...
```
