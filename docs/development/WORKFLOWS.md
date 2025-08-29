# 🚀 GitHub Workflows Guide

> Przewodnik po GitHub Actions w TuneTangler

## 📋 Spis Treści

- [🔄 Przegląd](#️-przegląd)
- [🚀 Workflowy](#️-workflowy)
  - [1. Release + Auto Tag (Integrated)](#️-1-release--auto-tag-integrated)
- [📱 Jak używać](#️-jak-używać)
  - [1. Manualne Release (jedyna opcja)](#️-1-manualne-release-jedyna-opcja)
  - [2. Testowanie Build Process](#️-2-testowanie-build-process)
  - [🚫 Pominięcie Workflow](#️-pominięcie-workflow)
- [⚙️ Wymagania](#️-wymagania)
- [💾 Cache](#️-cache)
- [📦 Artifacts](#️-artifacts)
- [🔐 Keystore Configuration](#️-keystore-configuration)
- [🔑 Secrets i Variables](#️-secrets-i-variables)
  - [Secrets (sensitive)](#️-secrets-sensitive)
  - [Variables (non-sensitive)](#️-variables-non-sensitive)
- [🚨Jeśli coś nie działa](#️jeśli-coś-nie-działa)
  - [❌ Błąd "Permission denied"](#️-błąd-permission-denied)
  - [❌ Błąd "Flutter not found"](#️-błąd-flutter-not-found)
  - [❌ Błąd "Java not found"](#️-błąd-java-not-found)
  - [❌ Problem z keystore](#️-problem-z-keystore)
  - [❌ Błąd "keystore password was incorrect"](#️-błąd-keystore-password-was-incorrect)
- [📚 Dodatkowe Zasoby](#️-dodatkowe-zasoby)

## 🔄 Przegląd

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

**Sekwencja:** **Test** → **Build** → **Version Control** → **Release**

## 🚀 Workflowy

### 1. Release + Auto Tag (Integrated)

**Plik:** `release.yml`
**Uruchamiany:** Tylko manualnie przez `workflow_dispatch`

**Co robi:**

- ✅ Weryfikuje kod (analyze, testy)
- ✅ Generuje pliki lokalizacji
- ✅ Pobiera wersję z `pubspec.yaml`
- ✅ Buduje APK (split-per-abi) i App Bundle (.aab) release
- ✅ Weryfikuje podpis App Bundle
- ✅ Tworzy tag wersji z build number
- ✅ Tworzy GitHub Release z APK i App Bundle
- ✅ Uploaduje wszystkie pliki jako artifacts

## 📱 Jak używać

### 1. Manualne Release (jedyna opcja)

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Build & Release Workflow"**
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – workflow automatycznie:
     - Pobierze wersję z `pubspec.yaml`
     - Utworzy tag `v{version}-build-{run_number}`
     - Zbuduje i zweryfikuje aplikację
     - Utworzy GitHub Release

### 2. Testowanie Build Process

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Test Build Workflow"** (jeśli istnieje)
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – szczególnie kroki debugowania

### 🚫 Pominięcie Workflow

Dodaj `[skip ci]` do wiadomości commita aby pominąć automatyczne workflowy.

## ⚙️ Wymagania

- Flutter 3.35.1
- Java 17 (Zulu)
- Ubuntu Latest runner
- GitHub Token (automatycznie dostępny)

## 💾 Cache

Workflowy używają cache dla:

- `~/.pub-cache` (Flutter dependencies)
- `~/.gradle/caches` (Android dependencies)

## 📦 Artifacts

- **APK Release:** Split-per-ABI APKs (arm64-v8a, armeabi-v7a, x86_64)
- **App Bundle:** App Bundle (.aab)
- **Modified pubspec.yaml:** Plik konfiguracyjny
- **Retention:** APK/AAB - 1 dzień, pubspec.yaml - domyślny

## 🔐 Keystore Configuration

Workflow używa `key.properties` dla podpisywania:

1. **Tworzy keystore** z `KEYSTORE_BASE64` secret
2. **Generuje `android/key.properties`** z:
     - `storeFile=app/tune-tangler-release-key.jks`
     - `storePassword=${{ secrets.KEYSTORE_PASSWORD }}`
     - `keyPassword=${{ secrets.KEY_PASSWORD }}`
     - `keyAlias=${{ vars.KEY_ALIAS }}`

## 🔑 Secrets i Variables

### Secrets (sensitive)

- `KEYSTORE_BASE64` - base64 encoded keystore file
- `KEYSTORE_PASSWORD` - keystore password
- `KEY_PASSWORD` - key password

### Variables (non-sensitive)

- `KEY_ALIAS` - key alias name

## 🚨Jeśli coś nie działa

### ❌ Błąd "Permission denied"

Sprawdź [GitHub Actions Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)

### ❌ Błąd "Flutter not found"

Sprawdź [GitHub Actions Flutter Setup](https://github.com/marketplace/actions/flutter-action)

### ❌ Błąd "Java not found"

Sprawdź [GitHub Actions Java Setup](https://github.com/actions/setup-java)

### ❌ Problem z keystore

Sprawdź [Android App Signing](https://developer.android.com/studio/publish/app-signing)

### ❌ Błąd "keystore password was incorrect"

Sprawdź [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 📚 Dodatkowe Zasoby

- **[📖 Development Guide](../../README.md)** – Główny przewodnik
- **[🔧 Setup](SETUP.md)** – Konfiguracja środowiska
- **[⚡ Quick Start](QUICKSTART.md)** – Szybkie uruchomienie
- **[🔨 Makefile](QUICKSTART.md#makefile)** – Komendy i narzędzia
- **[🎣 Git Hooks](GIT_HOOKS.md)** – Automatyzacja wersjonowania
