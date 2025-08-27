# Release Signing Configuration

This document explains how to configure release signing for TuneTangler to ensure consistent app signatures across builds.

## Problem

Without proper signing configuration, each build machine generates its own debug keystore, causing:

- **Signature mismatch errors** during app updates
- **Data loss** when users try to update the app
- **Incompatible package** installation failures

## Solution

Use a consistent keystore stored as GitHub secrets for all CI/CD builds. **We now use app bundle (.aab) instead of APK for better signing support.**

## Setup Steps

### 1. Generate Keystore (One-time setup)

The keystore has already been generated. If you need to regenerate it:

```bash
keytool -genkey -v \
  -keystore android/app/tune-tangler-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias tune-tangler-key \
  -storepass TuneTangler2024!Release \
  -keypass TuneTangler2024!Key \
  -dname "CN=Bartłomiej Kwiatek, OU=Kwiatek.pro, O=Kwiatek.pro, L=, ST=, C="
```

**Important**: Use strong, unique passwords:

- **Store password**: `TuneTangler2024!Release` (for keystore access)
- **Key password**: `TuneTangler2024!Key` (for private key access)

### 2. Prepare GitHub Secrets (One-time setup)

To get the base64 encoded keystore, run this command:

```bash
base64 -i android/app/tune-tangler-release-key.jks
```

Add these secrets to your GitHub repository:
**Settings → Secrets and variables → Actions**

| Secret | Wartość |
|--------|---------|
| `KEYSTORE_BASE64` | Base64 encoded keystore file (from command above) |
| `KEYSTORE_PASSWORD` | `TuneTangler2024!Release` |
| `KEY_ALIAS` | `tune-tangler-key` |
| `KEY_PASSWORD` | `TuneTangler2024!Key` |

**Note**: The workflow generates `gradle.properties` with these credentials during build, so they're not stored in the repository.

### 3. Verify Configuration

After setting up the secrets, verify that:

1. **Keystore exists**: `android/app/tune-tangler-release-key.jks`
2. **GitHub secrets are set**: All 4 secrets are configured
3. **Workflow can access secrets**: No permission errors

### 4. Build and Test

Test the configuration by running the release workflow:

1. **Go to Actions** in your GitHub repository
2. **Select "Build & Release Workflow"**
3. **Click "Run workflow"**
4. **Monitor the build process**

The workflow should:

- ✅ Download keystore from secrets
- ✅ Generate `gradle.properties` with credentials
- ✅ Build signed app bundle
- ✅ Verify signature with `jarsigner`

## Troubleshooting

### Common Issues

**"Keystore not found" error:**

- Ensure `KEYSTORE_BASE64` secret is properly set
- Check that the base64 encoding is complete

**"Signature verification failed" error:**

- Verify all 4 secrets are correctly configured
- Check that keystore passwords match

**Build fails with signing errors:**

- Ensure keystore file is valid
- Check that alias and passwords are correct

### Regenerating Keystore

If you need to regenerate the keystore:

1. **Delete old keystore**: `rm android/app/tune-tangler-release-key.jks`
2. **Generate new one**: Use the keytool command from step 1
3. **Update GitHub secrets**: Get new base64 and update `KEYSTORE_BASE64`
4. **Test workflow**: Run the release workflow again

## Security Notes

- **Never commit keystore files** to version control
- **Use strong, unique passwords** for production
- **Rotate keystores periodically** for security
- **Limit access** to GitHub secrets to trusted team members

## Benefits

With this configuration:

- ✅ **Consistent signatures** across all builds
- ✅ **No more update conflicts** for users
- ✅ **Secure credential storage** in GitHub
- ✅ **Automated signing** in CI/CD pipeline
- ✅ **Professional app distribution** ready
