# 🚀 GitHub workflows guide

> GitHub Actions for Tune Tangler

## 📋 Table of contents

- [🔄 Overview](#overview)
- [🚀 Workflows](#workflows)
  - [1. Tests (PR to `main`)](#tests-pr-main)
  - [1b. Version & tag (`main` push)](#version-tag-main)
  - [2. F-Droid release (MR)](#release-fdroid-app)
  - [3. Legacy — GitHub APK/AAB + Release](#release-apk-aab-google-play)
- [📱 How to use](#how-to-use)
  - [1. CI on PR to `main`](#ci-on-main)
  - [2. F-Droid: one-click release](#fdroid-one-click)
  - [3. Legacy: APK/AAB + GitHub Release](#manual-release-only-option)
  - [4. Testing the build](#testing-build-process)
  - [🚫 Skip workflows](#skip-workflow)
- [⚙️ Requirements](#requirements)
- [💾 Cache](#cache)
- [🧩 Composite actions](#composite-actions)
- [📦 Artifacts](#artifacts)
- [🔐 Keystore (legacy workflow only)](#keystore-configuration)
- [🔑 Secrets and variables](#secrets-and-variables)
  - [Secrets (sensitive)](#secrets-sensitive)
  - [Variables (non-sensitive)](#variables-non-sensitive)
- [🚨 Troubleshooting](#troubleshooting)
  - [❌ Permission denied](#permission-denied-error)
  - [❌ Flutter not found](#flutter-not-found-error)
  - [❌ Java not found](#java-not-found-error)
  - [❌ Keystore issues](#keystore-problem)
  - [❌ Keystore password incorrect](#keystore-password-incorrect-error)
- [📚 Additional resources](#additional-resources)

## 🔄 Overview <a name="overview"></a>

**Default path:** F-Droid builds and signs binaries upstream. **CI:** [`test.yml`](../../.github/workflows/test.yml) runs analyzer + tests on **pull requests to `main`** and on **`workflow_dispatch`**. **[`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)** runs on **`push` to `main`** (when paths are not ignored): it **reuses** that same workflow via **`workflow_call`**, then **`pubspec`** + tag (see below).

**Versioning policy:** on eligible **`push` to `main`**, [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) runs **tests**, then sets **`pubspec`** to **`MAJOR.MINOR.PATCH+GITHUB_RUN_NUMBER`**: **PATCH** increments when that push **does not** edit the **`version:`** line; if **`version:`** did change, only **`base+GITHUB_RUN_NUMBER`** is applied (no extra PATCH bump). Bot commits use **`[skip ci]`** so **`version-tag-main`** **skips** both **`test`** and **`version_tag`** on the next push (no duplicate test/tag loop).

**F-Droid:** [`release-fdroid-app.yml`](../../.github/workflows/release-fdroid-app.yml) — **`workflow_dispatch`** with required **`target_ref`**: checkout that ref → **GitLab MR** only (no `pubspec` changes, commits, or tags in CI).

**Legacy** ([`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml)): **`workflow_dispatch`** with required **`tag`** (must already exist). **Build** signed APK/AAB at that tag (Flutter uses `pubspec` from the tree — no CI version step), **verify** the bundle, **GitHub Release** with artifact names derived from the **tag** (leading `v` stripped for filenames). Fails if a release for that tag **already exists**. **No** separate test job in this workflow.

**Triggers:** [`test.yml`](../../.github/workflows/test.yml) (`pull_request` YAML anchor) and [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) (`push` to `main`) use the **same `paths-ignore` list** — keep them in sync when editing.

## 🚀 Workflows <a name="workflows"></a>

### 1. Tests (PR to `main`) <a name="tests-pr-main"></a>

**File:** [`test.yml`](../../.github/workflows/test.yml)

**Triggers:** `pull_request` to `main`, `workflow_dispatch`, and **`workflow_call`** (from [`version-tag-main.yml`](#version-tag-main)).

**What it does:** **`actions/checkout`** (**`fetch-depth: 1`**) → [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) → [`flutter-test`](../../.github/actions/flutter-test/action.yml) (analyzer + unit tests). **[`version-tag-main.yml`](#version-tag-main)** invokes this file as a reusable workflow for the test stage, then runs a second job with **`fetch-depth: 0`** for history-aware **`pubspec`** + tag.

**What it does not do:** no APK/AAB build, no GitHub Release, no `pubspec` bump, no F-Droid MR.

### 1b. Version & tag (`main` push) <a name="version-tag-main"></a>

**File:** [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)

**Triggers:** `push` to **`main`**, with the same **`paths-ignore`** as [`test.yml`](../../.github/workflows/test.yml) (documented in both files — **keep in sync**).

**What it does:** **Job `test`** — calls **[`test.yml`](../../.github/workflows/test.yml)** as a reusable workflow (**`uses: ./.github/workflows/test.yml`**) so PR and **`main`** share the same steps. **Job `version_tag`** (**`needs: test`**) — **`checkout`** (**`fetch-depth: 0`**, token for push and `git diff`) → bump **`pubspec`** logic → [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) when the version changed (**`[skip ci]`**, no changelog collection) — push **`main`**, annotated tag **`v…+…`**. Both jobs honor **`[skip ci]`** on the pushed commit (the **`test`** call and **`version_tag`** are skipped).

**What it does not do:** no F-Droid MR (use [`release-fdroid-app.yml`](#release-fdroid-app)).

### 2. F-Droid release (MR) <a name="release-fdroid-app"></a>

**File:** [`release-fdroid-app.yml`](../../.github/workflows/release-fdroid-app.yml)

**Trigger:** **`workflow_dispatch`** — required **`target_ref`** (tag or branch).

**What it does:** checkout **`target_ref`** → [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml) with that commit and ref. **Does not** modify `pubspec`, **does not** commit, **does not** create GitHub tags.

Requires **`GITLAB_TOKEN`** (**job `env`** from a repository **secret**) and **`GITLAB_FORK_PROJECT_ID`** (**job `env`** from a repository **variable**). Optional **`FDROID_FLUTTER_VERSION`** and **`FDROID_METADATA_SOURCE_BRANCH`** variables (see [docs/release/FDROID.md](../release/FDROID.md)) — both must be referenced in the workflow (`vars.…`) to reach the script.

### 3. Legacy — GitHub APK/AAB + Release <a name="release-apk-aab-google-play"></a>

**File:** [`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml)

**Trigger:** **`workflow_dispatch`** — required input **`tag`** (an **existing** tag, e.g. `v1.7.0+12`).

**What it does (jobs):** **STEP 1 — Build & verify** — checkout **`tag`**, Flutter + Java + keystore, **`flutter build`**, signature check, upload artifacts. **STEP 2 — Release** — rename artifacts using the **tag** (strip leading **`v`** for filenames), optional changelog from git, duplicate-release guard, **GitHub Release** on **`tag`**.

Requires keystore **secrets** (see below).

## 📱 How to use <a name="how-to-use"></a>

### 1. CI on PR to `main` <a name="ci-on-main"></a>

[`test.yml`](../../.github/workflows/test.yml) runs on **pull requests**. Pushes to **`main`** that match the shared **`paths-ignore`** rules run **[`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)** (tests + version + tag). Pushes that match **all** ignore paths run **neither** workflow for that commit.

### 2. F-Droid: MR to fdroiddata <a name="fdroid-one-click"></a>

1. Ensure the **tag** (or branch) you want is already on GitHub (usually from **`main`** / [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)).
2. **Actions** → **F-Droid release (MR)** → **Run workflow** → set **`target_ref`** (e.g. `v1.7.0+12`).

### 3. Legacy: APK/AAB + GitHub Release <a name="manual-release-only-option"></a>

1. **Actions** → **Legacy — GitHub APK/AAB + Release** → **Run workflow** → required **`tag`** (must already exist, e.g. `v1.7.0+12`).
2. Configure keystore secrets if needed.

### 4. Testing the build <a name="testing-build-process"></a>

Use **Actions** → pick the workflow → **Run workflow** when available.

### 🚫 Skip workflows <a name="skip-workflow"></a>

Add **`[skip ci]`** to bot commit messages from **`version-tag-main`**: the **`test`** reusable call and **`version_tag`** job are skipped on the following **`push` to `main`** so you do not re-test / re-tag in a loop. **`test.yml`** does not run on **`push` to `main`** by itself (only via **`version-tag-main`** when paths match).

## ⚙️ Requirements <a name="requirements"></a>

- Flutter stable (see composite actions)
- Java 17 (Zulu) for Android builds in **legacy** workflow
- `ubuntu-latest`

## 💾 Cache <a name="cache"></a>

Workflows may cache `~/.pub-cache` and `~/.gradle/caches` (see each YAML).

## 🧩 Composite actions <a name="composite-actions"></a>

Reusable steps under [`.github/actions/`](../../.github/actions/):

| Action | Role |
|--------|------|
| [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) | Flutter SDK (`subosito/flutter-action`), `flutter pub get`, optional `flutter gen-l10n`, dependency cache. Workflows run **`actions/checkout`** before this action when the tree must be present (e.g. **`test.yml`**, legacy **build**). |
| [`flutter-test`](../../.github/actions/flutter-test/action.yml) | `flutter analyze` + `flutter test` (+ optional `integration_test`). |
| [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) | Caller must **`checkout`** the repo first (with a token if you need push). Expects **`pubspec.yaml`** already modified in the workspace → optional **`git_user_*`**, **`commit_suffix`**, **`pull_before_push`**, commit, push branch, **`collect_commits_since_last_tag`** → **`commits`**, record outputs, optional annotated tag (**`with_description`**, **`tag_push_force_with_lease`**), optional **`write_job_summary`**. Used by **`version-tag-main`**. |
| [`git-config-github-actions-bot`](../../.github/actions/git-config-github-actions-bot/action.yml) | `git config` for **`github-actions[bot]`** (optional `user_name` / `user_email`). Used at the start of **`version-tag-main.yml`** and inside **`pubspec-commit-tag-push`**. |
| [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml) | GitLab MR to fdroiddata; pass **`metadata_source_branch`** from **`vars.FDROID_METADATA_SOURCE_BRANCH`** when set (see [FDROID.md](../release/FDROID.md)). |
| [`setup-java`](../../.github/actions/setup-java/action.yml) | JDK for Android builds (**legacy** only). Run **`actions/checkout`** in the job before this step (this action does not checkout the repo). |

## 📦 Artifacts <a name="artifacts"></a>

- **`test.yml`:** no release binaries (tests only).
- **`version-tag-main.yml`:** reusable **`test`** job (same as **`test.yml`**) then job **`version_tag`** (`pubspec` + tag on `main`; no binaries).
- **`release-fdroid-app.yml`:** GitLab MR only (no binaries in Actions).
- **`release-apk-aab-google-play.yml`:** APKs, `.aab`, GitHub Release for an **existing** tag (no `pubspec` artifact in CI).

## 🔐 Keystore (legacy workflow only) <a name="keystore-configuration"></a>

The **legacy** workflow decodes `KEYSTORE_BASE64` and writes `android/key.properties` for Gradle signing. **`test.yml`** does not use a keystore.

## 🔑 Secrets and variables <a name="secrets-and-variables"></a>

### Secrets (sensitive) <a name="secrets-sensitive"></a>

**Legacy workflow:** `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.

**F-Droid MR:** `GITLAB_TOKEN` on the MR job as **job `env`** from a repository secret (see [docs/release/FDROID.md](../release/FDROID.md)).

### Variables (non-sensitive) <a name="variables-non-sensitive"></a>

**F-Droid MR:** **`GITLAB_FORK_PROJECT_ID`** (required — numeric GitLab project ID of your fdroiddata fork). Optional **`FDROID_FLUTTER_VERSION`**, **`FDROID_METADATA_SOURCE_BRANCH`** — see [FDROID.md](../release/FDROID.md); use `vars.*` in the workflow so they reach the publish step.

## 🚨 Troubleshooting <a name="troubleshooting"></a>

### ❌ Permission denied <a name="permission-denied-error"></a>

[GitHub Actions `GITHUB_TOKEN` permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)

### ❌ Flutter not found <a name="flutter-not-found-error"></a>

[Flutter action](https://github.com/marketplace/actions/flutter-action)

### ❌ Java not found <a name="java-not-found-error"></a>

[`actions/setup-java`](https://github.com/actions/setup-java)

### ❌ Keystore issues <a name="keystore-problem"></a>

[Android app signing](https://developer.android.com/studio/publish/app-signing)

### ❌ Keystore password incorrect <a name="keystore-password-incorrect-error"></a>

[Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 📚 Additional resources <a name="additional-resources"></a>

- **[📖 Development guide](../../README.md)** — main entry
- **[🔧 Setup](SETUP.md)** — environment
- **[⚡ Quick start](QUICKSTART.md)** — first run
- **[🔨 Makefile](QUICKSTART.md#makefile)** — commands
- **[🎣 Git hooks](GIT_HOOKS.md)** — optional `pre-commit`
- **[📦 F-Droid](../release/FDROID.md)** — GitLab MR workflow + `tools/fdroid/`
