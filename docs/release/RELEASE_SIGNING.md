# 🔐 Release signing setup

> Configure consistent release signing for Tune Tangler so upgrades keep the same signing key.

## 📋 Table of contents

- [❓ Problem](#problem)
- [✅ Solution](#solution)
- [🔧 One-time configuration](#one-time-configuration)
  - [1️⃣ Prepare configuration](#prepare-configuration)
  - [2️⃣ Generate keystore](#generate-keystore)
  - [3️⃣ Configure GitHub secrets](#prepare-github-secrets)
  - [4️⃣ Verify configuration](#verify-configuration)
  - [5️⃣ Build and test](#build-and-test)
- [🚨 Troubleshooting](#troubleshooting)
  - [❌ Keystore not found](#keystore-not-found-error)
  - [❌ Signature verification failed](#signature-verification-failed-error)
  - [❌ Signing errors during build](#build-fails-with-signing-errors)
  - [🔄 Regenerating a keystore](#regenerating-keystore)
- [🔒 Security notes](#security-notes)
- [✨ Benefits](#benefits)

---

## ❓ Problem <a name="problem"></a>

Without a shared release keystore, each build machine may use a different debug key, causing:

- **Signature mismatch** on app updates
- **Data loss** when users cannot upgrade in place
- **Install failures** for incompatible packages

## ✅ Solution <a name="solution"></a>

Use one keystore stored as GitHub Actions secrets for CI/CD builds.  
The **APK/AAB release** workflow ([`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml)) produces an **App Bundle (`.aab`)** as well as APKs.

## 🔧 One-time configuration <a name="one-time-configuration"></a><a name="one-time-configuration-steps"></a>

### 1️⃣ Prepare configuration <a name="prepare-configuration"></a>

Create [`android/key.properties`](../../android/key.properties) with:

```properties
storeFile=tune-tangler-release-key.jks
storePassword=xxx
keyAlias=xxx
keyPassword=xxx
dName=CN=xx, O=xx, C=PL
```

> **Important:** use strong, unique passwords. Do **not** commit real secrets to git.

### 2️⃣ Generate keystore <a name="generate-keystore"></a>

If you need to (re)generate the keystore:

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

### 3️⃣ Configure GitHub secrets <a name="prepare-github-secrets"></a>

Add these **Actions** secrets: **Settings → Secrets and variables → Actions**

| Secret | Typical value source |
|--------|----------------------|
| `KEYSTORE_BASE64` | `base64 -i android/app/tune-tangler-release-key.jks \| pbcopy` (or OS equivalent) |
| `KEYSTORE_PASSWORD` | from `storePassword` in `key.properties` |
| `KEY_ALIAS` | from `keyAlias` |
| `KEY_PASSWORD` | from `keyPassword` |

That workflow generates `key.properties` during the job; do not commit production passwords to the repo.

### 4️⃣ Verify configuration <a name="verify-configuration"></a>

1. Keystore file exists locally where Gradle expects it (e.g. `android/app/tune-tangler-release-key.jks`).
2. All four secrets exist in GitHub.
3. Workflow logs show no permission errors when reading secrets.

### 5️⃣ Build and test <a name="build-and-test"></a>

1. **Actions** → **Release on GitHub (APK/AAB files)** (`release-apk-aab-google-play.yml`)  
2. **Run workflow**  
3. Confirm signed artifacts and `jarsigner` verification in the log

## 🚨 Troubleshooting <a name="troubleshooting"></a>

### ❌ Keystore not found <a name="keystore-not-found-error"></a>

[Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

### ❌ Signature verification failed <a name="signature-verification-failed-error"></a>

[App signing](https://developer.android.com/studio/publish/app-signing)

### ❌ Signing errors during build <a name="build-fails-with-signing-errors"></a>

[Build troubleshooting](https://developer.android.com/studio/build/troubleshoot)

### 🔄 Regenerating a keystore <a name="regenerating-keystore"></a>

[Generate a key](https://developer.android.com/studio/publish/app-signing#generate-key) — note that changing keys breaks updates for existing users unless you use Play App Signing key migration.

## 🔒 Security notes <a name="security-notes"></a>

- Never commit keystores or passwords to version control.
- Use strong, unique passwords for production keys.
- Rotate keys only with a documented migration plan.
- Limit who can read repository secrets.

## ✨ Benefits <a name="benefits"></a>

- Consistent signatures across CI builds
- Fewer user-facing upgrade conflicts
- Credentials live in GitHub secrets, not in the tree
- Automated signing in the APK/AAB release workflow

## 📚 Additional resources <a name="additional-resources"></a>

- [GitHub workflows — One-time configuration](../development/WORKFLOWS.md#one-time-configuration)
- [F-Droid — One-time configuration](FDROID.md#one-time-configuration)
- [Setup](../development/SETUP.md#one-time-configuration) — local Android/Java toolchain
