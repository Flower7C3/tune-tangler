### 🔧 Build Info

- **Flutter Version:** {{ FLUTTER_VERSION }}
- **Java Version:** {{ JAVA_VERSION }}/{{ JAVA_DISTRIBUTION }}
- **Workflow run:** [{{ GITHUB_RUN_NUMBER }}](https://github.com/{{ GITHUB_REPOSITORY }}/actions/runs/{{ GITHUB_RUN_ID }})

### 📱App versions

- [arm64-v8a](https://github.com/{{ GITHUB_REPOSITORY }}/releases/download/{{ REPOSITORY_TAG_NAME }}/tune-tangler-{{ APP_BUILD_VERSION }}-arm64-v8a.apk) – modern 64-bit ARM (this is usually the one you want)
- [armeabi-v7a](https://github.com/{{ GITHUB_REPOSITORY }}/releases/download/{{ REPOSITORY_TAG_NAME }}/tune-tangler-{{ APP_BUILD_VERSION }}-armeabi-v7a.apk) – older ARM architecture
- [x86_64](https://github.com/{{ GITHUB_REPOSITORY }}/releases/download/{{ REPOSITORY_TAG_NAME }}/tune-tangler-{{ APP_BUILD_VERSION }}-x86_64.apk) – old Intel architecture

> Not sure which APK to pick? See the [installation guide](https://github.com/{{ GITHUB_REPOSITORY }}/blob/main/docs/release/INSTALLATION.md).

### 📝 Changes since last release

{{ REPOSITORY_COMMITS }}
