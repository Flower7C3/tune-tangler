# 🔐 Konfiguracja podpisywania Release

> Ten dokument wyjaśnia, jak skonfigurować podpisywanie release dla TuneTangler, aby
> zapewnić spójne podpisy aplikacji w różnych buildach.

## 📋 Spis Treści

- [🚨 Problem](#-problem)
- [✅ Rozwiązanie](#-rozwiązanie)
- [🔧 Jednorazowe kroki konfiguracji](#-jednorazowe-kroki-konfiguracji)
  - [1️⃣ Przygotuj konfigurację](#-przygotuj-konfigurację)
  - [2️⃣ Generuj Keystore](#-generuj-keystore)
  - [3️⃣ Przygotuj GitHub Secrets](#-przygotuj-github-secrets)
  - [4️⃣ Zweryfikuj konfigurację](#-zweryfikuj-konfigurację)
  - [5️⃣ Build i test](#-build-i-test)
- [🚨Jeśli coś nie działa](#jeśli-coś-nie-działa)
  - [❌ Błąd "Keystore not found"](#-błąd-keystore-not-found)
  - [❌ Błąd "Signature verification failed"](#-błąd-signature-verification-failed)
  - [❌ Build nie powodzi się z błędami podpisywania](#-build-nie-powodzi-się-z-błędami-podpisywania)
  - [🔁 Regenerowanie Keystore](#-regenerowanie-keystore)
- [🔒 Uwagi bezpieczeństwa](#-uwagi-bezpieczeństwa)
- [🎯 Korzyści](#-korzyści)

## 🚨 Problem

Bez odpowiedniej konfiguracji podpisywania, każda maszyna build generuje własny
debug keystore, co powoduje:

- **Błędy niezgodności podpisu** podczas aktualizacji aplikacji
- **Utratę danych** gdy użytkownicy próbują zaktualizować aplikację
- **Błędy instalacji** niezgodnych pakietów

## ✅ Rozwiązanie

Użyj spójnego keystore przechowywanego jako GitHub secrets dla wszystkich buildów CI/CD.
**Teraz używamy app bundle (.aab) zamiast APK dla lepszego wsparcia podpisywania.**

## 🔧 Jednorazowe kroki konfiguracji

### 1️⃣ Przygotuj konfigurację

Utwórz plik [android/key.properties](../android/key.properties) z wartościami:

```properties
storeFile=tune-tangler-release-key.jks
storePassword=xxx
keyAlias=xxx
keyPassword=xxx
dName=CN=xx, O=xx, C=PL
```

> **⚠️ Ważne**: Użyj silnych, unikalnych haseł.

### 2️⃣ Generuj Keystore

Keystore został już wygenerowany. Jeśli musisz go wygenerować ponownie:

```bash
keytool \
  -genkeypair \
  -keystore '`grep storeFile android/key.properties | cut -d '=' -f2`' \
  -storepass '`grep storePassword android/key.properties | cut -d '=' -f2`' \
  -alias '`grep keyAlias android/key.properties | cut -d '=' -f2`' \
  -keypass '`grep keyPassword android/key.properties | cut -d '=' -f2`' \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname '`grep dName android/key.properties | cut -d '=' -f2-9`'
```

### 3️⃣ Przygotuj GitHub Secrets

Dodaj te secrets do swojego repozytorium GitHub:
**Settings → Secrets and variables → Actions**

| Secret              | Wartość                                                                               |
|---------------------|---------------------------------------------------------------------------------------|
| `KEYSTORE_BASE64`   | `base64 -i android/app/tune-tangler-release-key.jks \| pbcopy`                        |
| `KEYSTORE_PASSWORD` | `grep storePassword android/key.properties \| cut -d '=' -f2 \| tr -d '\n' \| pbcopy` |
| `KEY_ALIAS`         | `grep keyAlias android/key.properties \| cut -d '=' -f2 \| tr -d '\n' \| pbcopy`      |
| `KEY_PASSWORD`      | `grep keyPassword android/key.properties \| cut -d '=' -f2 \| tr -d '\n' \| pbcopy`   |

**ℹ️ Uwaga**: Workflow generuje `key.properties` z tymi danymi
podczas buildu, więc nie są przechowywane w repozytorium.

### 4️⃣ Zweryfikuj konfigurację

Po ustawieniu secrets, zweryfikuj że:

1. **Keystore istnieje**: `android/app/tune-tangler-release-key.jks`
2. **GitHub secrets są ustawione**: Wszystkie 4 secrets są skonfigurowane
3. **Workflow ma dostęp do secrets**: Brak błędów uprawnień

### 5️⃣ Build i test

Przetestuj konfigurację uruchamiając release workflow:

1. **Idź do Actions** w swoim repozytorium GitHub
2. **Wybierz "Build & Release Workflow"**
3. **Kliknij "Run workflow"**
4. **Monitoruj proces buildu**

Workflow powinien:

- ✅ Pobrać keystore z secrets
- ✅ Wygenerować `gradle.properties` z danymi logowania
- ✅ Zbudować podpisany app bundle
- ✅ Zweryfikować podpis z `jarsigner`

## 🚨Jeśli coś nie działa

### ❌ Błąd "Keystore not found"

Sprawdź [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

### ❌ Błąd "Signature verification failed"

Sprawdź [Android App Signing](https://developer.android.com/studio/publish/app-signing)

### ❌ Build nie powodzi się z błędami podpisywania

Sprawdź [Android Build Troubleshooting](https://developer.android.com/studio/build/troubleshoot)

### 🔁 Regenerowanie Keystore

Sprawdź [Android Keystore Management](https://developer.android.com/studio/publish/app-signing#generate-key)

## 🔒 Uwagi bezpieczeństwa

- **Nigdy nie commituj plików keystore** do kontroli wersji
- **Użyj silnych, unikalnych haseł** dla produkcji
- **Rotuj keystore okresowo** dla bezpieczeństwa
- **Ogranicz dostęp** do GitHub secrets do zaufanych członków zespołu

## 🎯 Korzyści

Z tą konfiguracją:

- ✅ **Spójne podpisy** we wszystkich buildach
- ✅ **Brak konfliktów aktualizacji** dla użytkowników
- ✅ **Bezpieczne przechowywanie danych logowania** w GitHub
- ✅ **Automatyczne podpisywanie** w pipeline CI/CD
- ✅ **Profesjonalna dystrybucja aplikacji** gotowa
