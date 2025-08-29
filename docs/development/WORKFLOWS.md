# 🚀 GitHub Workflows Guide

> Przewodnik po GitHub Actions w TuneTangler

## 📋 Spis Treści

- [🔄 Przegląd](#overview)
- [🚀 Workflowy](#workflows)
  - [1. Release + Auto Tag (Integrated)](#release-auto-tag-integrated)
- [📱 Jak używać](#how-to-use)
  - [1. Manualne Release (jedyna opcja)](#manual-release-only-option)
  - [2. Testowanie Build Process](#testing-build-process)
  - [🚫 Pominięcie Workflow](#skip-workflow)
- [⚙️ Wymagania](#requirements)
- [💾 Cache](#cache)
- [📦 Artifacts](#artifacts)
- [🔐 Keystore Configuration](#keystore-configuration)
- [🔑 Secrets i Variables](#secrets-and-variables)
  - [Secrets (sensitive)](#secrets-sensitive)
  - [Variables (non-sensitive)](#variables-non-sensitive)
- [🚨Jeśli coś nie działa](#troubleshooting)
  - [❌ Błąd "Permission denied"](#permission-denied-error)
  - [❌ Błąd "Flutter not found"](#flutter-not-found-error)
  - [❌ Błąd "Java not found"](#java-not-found-error)
  - [❌ Problem z keystore](#keystore-problem)
  - [❌ Błąd "keystore password was incorrect"](#keystore-password-incorrect-error)
- [📚 Dodatkowe Zasoby](#additional-resources)

## 🔄 Przegląd <a name="overview"></a>

Ten katalog zawiera automatyczne workflowy GitHub Actions dla projektu TuneTangler.

**Sekwencja:** **Test** → **Build** → **Version Control** → **Release**

## 🚀 Workflowy <a name="workflows"></a>

### 1. Release + Auto Tag (Integrated) <a name="release-auto-tag-integrated"></a>

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

## 📱 Jak używać <a name="how-to-use"></a>

### 1. Manualne Release (jedyna opcja) <a name="manual-release-only-option"></a>

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Build & Release Workflow"**
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – workflow automatycznie:
     - Pobierze wersję z `pubspec.yaml`
     - Utworzy tag `v{version}-build-{run_number}`
     - Zbuduje i zweryfikuje aplikację
     - Utworzy GitHub Release

### 2. Testowanie Build Process <a name="testing-build-process"></a>

1. **Idź do Actions** w repozytorium GitHub
2. **Wybierz "Test Build Workflow"** (jeśli istnieje)
3. **Kliknij "Run workflow"**
4. **Monitoruj proces budowania** – szczególnie kroki debugowania

### 🚫 Pominięcie Workflow <a name="skip-workflow"></a>

Dodaj `[skip ci]` do wiadomości commita aby pominąć automatyczne workflowy.

## ⚙️ Wymagania <a name="requirements"></a>

- Flutter 3.35.1
- Java 17 (Zulu)
- Ubuntu Latest runner
- GitHub Token (automatycznie dostępny)

## 💾 Cache <a name="cache"></a>

Workflowy używają cache dla:

- `~/.pub-cache` (Flutter dependencies)
- `~/.gradle/caches` (Android dependencies)

## 📦 Artifacts <a name="artifacts"></a>

- **APK Release:** Split-per-ABI APKs (arm64-v8a, armeabi-v7a, x86_64)
- **App Bundle:** App Bundle (.aab)
- **Modified pubspec.yaml:** Plik konfiguracyjny
- **Retention:** APK/AAB - 1 dzień, pubspec.yaml - domyślny

## 🔐 Keystore Configuration <a name="keystore-configuration"></a>

Workflow używa `key.properties` dla podpisywania:

1. **Tworzy keystore** z `KEYSTORE_BASE64` secret
2. **Generuje `android/key.properties`** z:
     - `storeFile=app/tune-tangler-release-key.jks`
     - `storePassword=${{ secrets.KEYSTORE_PASSWORD }}`
     - `keyPassword=${{ secrets.KEY_PASSWORD }}`
     - `keyAlias=${{ vars.KEY_ALIAS }}`

## 🔑 Secrets i Variables <a name="secrets-and-variables"></a>

### Secrets (sensitive) <a name="secrets-sensitive"></a>

- `KEYSTORE_BASE64` - base64 encoded keystore file
- `KEYSTORE_PASSWORD` - keystore password
- `KEY_PASSWORD` - key password

### Variables (non-sensitive) <a name="variables-non-sensitive"></a>

- `KEY_ALIAS` - key alias name

## 🚨Jeśli coś nie działa <a name="troubleshooting"></a>

### ❌ Błąd "Permission denied" <a name="permission-denied-error"></a>

Sprawdź [GitHub Actions Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)

### ❌ Błąd "Flutter not found" <a name="flutter-not-found-error"></a>

Sprawdź [GitHub Actions Flutter Setup](https://github.com/marketplace/actions/flutter-action)

### ❌ Błąd "Java not found" <a name="java-not-found-error"></a>

Sprawdź [GitHub Actions Java Setup](https://github.com/actions/setup-java)

### ❌ Problem z keystore <a name="keystore-problem"></a>

Sprawdź [Android App Signing](https://developer.android.com/studio/publish/app-signing)

### ❌ Błąd "keystore password was incorrect" <a name="keystore-password-incorrect-error"></a>

Sprawdź [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 📚 Dodatkowe Zasoby <a name="additional-resources"></a>

- **[📖 Development Guide](../../README.md)** – Główny przewodnik
- **[🔧 Setup](SETUP.md)** – Konfiguracja środowiska
- **[⚡ Quick Start](QUICKSTART.md)** – Szybkie uruchomienie
- **[🔨 Makefile](QUICKSTART.md#makefile)** – Komendy i narzędzia
- **[🎣 Git Hooks](GIT_HOOKS.md)** – Automatyzacja wersjonowania
