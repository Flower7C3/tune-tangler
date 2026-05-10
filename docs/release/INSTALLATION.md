# 📱 Installation

> Pick a package that matches your device’s Android ABI.

## 📋 Table of contents

- [How to find your Android ABI](#how-to-check-android-abi)
  - [Method 1: Play Store app](#method-1-google-play-app)
  - [Method 2: Computer + ADB](#method-2-computer-adb)
- [Additional resources](#additional-resources)

## How to find your Android ABI <a name="how-to-check-android-abi"></a>

You are looking for values such as:

- `arm64-v8a` — modern 64-bit ARM
- `armeabi-v7a` — older 32-bit ARM
- `x86` / `x86_64` — Intel (emulators / rare devices)

### Method 1: Play Store app <a name="method-1-google-play-app"></a>

1. Open **Google Play** on the phone.
2. Install an app like **AIDA64** or **Device Info HW**.
3. Open it and go to **CPU** / **Processor** (or similar).
4. Read the reported architecture / ABI.

### Method 2: Computer + ADB <a name="method-2-computer-adb"></a>

1. Install **ADB** ([official guide](https://developer.android.com/tools/adb)).
2. Enable **Developer options** on the phone: Settings → About phone → tap **Build number** several times.
3. Enable **USB debugging** (or **Wireless debugging**): Settings → System → Developer options.
4. Connect the phone (USB or `adb connect IP:PORT` for wireless debugging).
5. On the computer:

    ```sh
    adb shell getprop ro.product.cpu.abi
    ```

## Additional resources <a name="additional-resources"></a>

- **[Android ABIs](https://developer.android.com/ndk/guides/abis)**
- **[ADB](https://developer.android.com/tools/adb)**
- **[Run on a device](https://developer.android.com/studio/run/device)**
