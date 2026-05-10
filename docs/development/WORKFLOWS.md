# 🚀 GitHub workflows guide

> GitHub Actions for Tune Tangler

## 📋 Table of contents

- [🔄 Overview](#overview)
- [🚀 Workflows](#workflows)
  - [1. Tests (PR + main)](#tests-pr-main)
  - [1b. Pubspec auto patch (`main`)](#pubspec-auto-patch-main)
  - [2. F-Droid release (test, tag, MR)](#fdroid-app-release)
  - [3. Legacy — GitHub APK/AAB + Release](#legacy-github-release)
  - [4. F-Droid metadata MR only (tag / manual)](#fdroid-tag-mr)
- [📱 How to use](#how-to-use)
  - [1. CI on PR and push to `main`](#ci-on-main)
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

**Default path:** F-Droid builds and signs binaries. **CI** runs analyzer + tests on **pull requests to `main`**, on **`push` to `main`**, and on **`workflow_dispatch`** — see [`test.yml`](../../.github/workflows/test.yml).

**Versioning policy:** merges to **`main`** run [`pubspec-auto-patch-main.yml`](../../.github/workflows/pubspec-auto-patch-main.yml) to **increment PATCH** in `pubspec` when that push **does not** edit the `version:` line (manual **minor/major** or release commits skip). **Release workflows** (F-Droid and legacy) only set **`{current base}+GITHUB_RUN_NUMBER`** in `pubspec` (no semver bump in CI); then they **commit** (if needed) and **tag** `v…+…`.

**Recommended F-Droid release:** **`workflow_dispatch`** in [`fdroid-app-release.yml`](../../.github/workflows/fdroid-app-release.yml): **tests → same job: set `pubspec` to `base+GITHUB_RUN_NUMBER` (working tree, no artifact) → commit + tag + push → GitLab MR** (same run; no extra PAT).

**Legacy** uses the same **build-suffix** idea as F-Droid (no PATCH bump in the release workflow): **tests → `pubspec` `base+GITHUB_RUN_NUMBER` artifact → build signed APK/AAB → commit + push + changelog + tag → GitHub Release** — see [`release-legacy-github-play-apk-aab.yml`](../../.github/workflows/release-legacy-github-play-apk-aab.yml).

**Tag-only MR:** pushing a semver tag from your machine (or any non-Actions push) still runs [`fdroid-tag-publish.yml`](../../.github/workflows/fdroid-tag-publish.yml), which invokes the shared composite action [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml). See [docs/release/FDROID.md](../release/FDROID.md).

**Triggers:** `pull_request` and `push` to `main` share the same `paths-ignore` in [`test.yml`](../../.github/workflows/test.yml) (including `docs/**`, `fastlane/metadata/**`, `.github/**`). [`pubspec-auto-patch-main.yml`](../../.github/workflows/pubspec-auto-patch-main.yml) uses the **same ignore list** — keep them in sync when editing.

## 🚀 Workflows <a name="workflows"></a>

### 1. Tests (PR + main) <a name="tests-pr-main"></a>

**File:** [`test.yml`](../../.github/workflows/test.yml)

**Triggers:** `pull_request` to `main`, `push` to `main`, `workflow_dispatch`.

**What it does:** analyzer + tests via composite [`checkout-flutter-test`](../../.github/actions/checkout-flutter-test/action.yml): the workflow runs **`actions/checkout`** first (required for local composites), then the composite with **`skip_checkout: 'true'`** so checkout is not repeated; shallow **`fetch-depth: 1`** on `test.yml`, full history (`0`) on F-Droid test job.

**What it does not do:** no APK/AAB build, no GitHub Release, no `pubspec` bump, no F-Droid MR.

### 1b. Pubspec auto patch (`main`) <a name="pubspec-auto-patch-main"></a>

**File:** [`pubspec-auto-patch-main.yml`](../../.github/workflows/pubspec-auto-patch-main.yml)

**Triggers:** `push` to **`main`**, with the same **`paths-ignore`** as [`test.yml`](../../.github/workflows/test.yml) (documented in both files — **keep in sync**).

**What it does:** if `pubspec.yaml`’s **`version:`** line was **not** part of that push’s diff, **increment PATCH** on the current **MAJOR.MINOR.PATCH** (strip any `+…` suffix first), commit `chore(auto): bump patch to …`, push to `main`.

**What it does not do:** no tests in this workflow; no tags; no F-Droid MR.

### 2. F-Droid release (test, tag, MR) <a name="fdroid-app-release"></a>

**File:** [`fdroid-app-release.yml`](../../.github/workflows/fdroid-app-release.yml)

**Trigger:** **`workflow_dispatch` only** (no inputs). Semver **base** comes from `pubspec` on the branch (before `+`); the workflow only applies **`+GITHUB_RUN_NUMBER`**, then commits/tags if needed.

**Steps (jobs):**

1. **STEP 1 — Test** — `actions/checkout` (**`fetch-depth: 0`**) then [`checkout-flutter-test`](../../.github/actions/checkout-flutter-test/action.yml) with **`skip_checkout: 'true'`**.
2. **STEP 2 — Version, commit & tag** — same job: [`pubspec-set-build-suffix`](../../.github/actions/pubspec-set-build-suffix/action.yml) with **`with_artifacts: false`** (edit `pubspec` in the workspace only), then [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) with **`with_artifacts: false`**, **`with_description: false`**: commit if needed, push branch, **commits since last tag** (output `commits` + optional **job summary**), annotated tag `v…+…`, push tag. **STEP 3** needs **`commit_sha`** and **`tag_name`** from this job (see [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml)); the commit list is for humans in the Actions UI, not the GitLab MR.
3. **STEP 3 — F-Droid MR** — [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml) with that commit SHA and tag ref. With a tag like `v1.2.3+42`, F-Droid **`versionCode`** is the integer after **`+`** (here: `GITHUB_RUN_NUMBER`).

Requires on the MR job **`GITLAB_TOKEN`** (**job `env`** from a repository **secret**) and **`GITLAB_FORK_PROJECT_ID`** (**job `env`** from a repository **variable**). Optional **`FDROID_FLUTTER_VERSION`** variable (see [docs/release/FDROID.md](../release/FDROID.md)).

### 3. Legacy — GitHub APK/AAB + Release <a name="legacy-github-release"></a>

**File:** [`release-legacy-github-play-apk-aab.yml`](../../.github/workflows/release-legacy-github-play-apk-aab.yml)

**Trigger:** **`workflow_dispatch` only.**

**What it does (jobs):** **STEP 1** — tests (`checkout-flutter-test` with **`skip_checkout`** after checkout). **STEP 2** — set `pubspec` to **`base+GITHUB_RUN_NUMBER`** only (same as F-Droid; no PATCH bump); upload `modified-pubspec` artifact. **STEP 3** — download `pubspec`, Flutter + Java + keystore, APKs + AAB, verify, upload binaries. **STEP 4** — [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) with artifact (**default `with_artifacts`**) and **`with_description: 'true'`**, **`commit_suffix: ' [skip ci]'`**, **`pull_before_push`**, **`tag_push_force_with_lease`** on tag push. **STEP 5** — GitHub Release with renamed artifacts and template body.

Requires keystore **secrets** (see below).

### 4. F-Droid metadata MR only (tag / manual) <a name="fdroid-tag-mr"></a>

**Files:** [`fdroid-tag-publish.yml`](../../.github/workflows/fdroid-tag-publish.yml) (triggers) → [`fdroid-metadata-mr` action](../../.github/actions/fdroid-metadata-mr/action.yml).

**Triggers:** `push` of semver tags (`v1.2.3`, `1.2.3`, optional `+build`) and **`workflow_dispatch`** (optional `version_override` input — MR only, no `pubspec`/tag changes).

**What it does:** same GitLab MR logic as **STEP 3** in [F-Droid release (`fdroid-app-release.yml`)](#fdroid-app-release), using `github.sha` / `github.ref_name` from that event.

## 📱 How to use <a name="how-to-use"></a>

### 1. CI on PR and push to `main` <a name="ci-on-main"></a>

Runs automatically when paths are not fully ignored.

### 2. F-Droid: one-click release <a name="fdroid-one-click"></a>

1. **Actions** → **F-Droid release (test, tag, MR)** → **Run workflow** (no inputs).
2. Wait for STEP 1–3; use the MR link in the STEP 3 log if needed.

### 3. Legacy: APK/AAB + GitHub Release <a name="manual-release-only-option"></a>

1. **Actions** → **Legacy — GitHub APK/AAB + Release**
2. **Run workflow**
3. Configure keystore secrets if needed

### 4. Testing the build <a name="testing-build-process"></a>

Use **Actions** → pick the workflow → **Run workflow** when available.

### 🚫 Skip workflows <a name="skip-workflow"></a>

Add `[skip ci]` to the commit message where applicable.

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
| [`checkout-flutter-test`](../../.github/actions/checkout-flutter-test/action.yml) | Optional `actions/checkout` (unless **`skip_checkout: 'true'`** — then the workflow must checkout first) → [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) with `skip_checkout` → [`flutter-test`](../../.github/actions/flutter-test/action.yml). Used by **`test.yml`**, **F-Droid** and **legacy** test jobs. |
| [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) | Flutter SDK, `pub get`, optional `gen-l10n`, cache. Set **`skip_checkout: 'true'`** when the job already ran `actions/checkout` (e.g. legacy **build** job). **`fetch_depth`** applies only when checkout runs inside this action. |
| [`flutter-test`](../../.github/actions/flutter-test/action.yml) | `flutter analyze` + `flutter test` (+ optional `integration_test`). |
| [`pubspec-set-build-suffix`](../../.github/actions/pubspec-set-build-suffix/action.yml) | Checkout, set `pubspec` to **`base+run_number`**; optional upload **`modified-pubspec`** (**`with_artifacts`**). Optional **`github_token`** when skipping artifacts in the same job as a push. Outputs `base`, `computed_version`, `tag_name`. |
| [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) | With **`with_artifacts: true`**: checkout with token, download **`modified-pubspec`**. With **`false`**: reuse workspace from **`pubspec-set-build-suffix`**. Then optional **`git_user_*`**, **`commit_suffix`**, **`pull_before_push`**, commit if changed, push branch, **`collect_commits_since_last_tag`** → **`commits`**, record outputs, optional annotated tag (**`with_description`**, **`tag_push_force_with_lease`** for legacy), optional **`write_job_summary`**. |
| [`git-config-github-actions-bot`](../../.github/actions/git-config-github-actions-bot/action.yml) | `git config` for **`github-actions[bot]`** (optional `user_name` / `user_email`). Used by **F-Droid tag** composite, **`pubspec-auto-patch-main.yml`**, and anywhere else commits run in CI. |
| [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml) | GitLab MR to fdroiddata (see [FDROID.md](../release/FDROID.md)). |
| [`setup-java`](../../.github/actions/setup-java/action.yml) | JDK for Android builds (**legacy** only). Set **`skip_checkout: 'true'`** when the job already ran `actions/checkout` (otherwise this action checks out the repo by default). |

## 📦 Artifacts <a name="artifacts"></a>

- **`test.yml`:** no release binaries (tests only).
- **`pubspec-auto-patch-main.yml`:** PATCH bump commit on `main` only (no binaries).
- **`fdroid-app-release.yml`:** no binaries; `pubspec` + tag + GitLab MR only (no `pubspec` artifact in Actions — same-job workspace between composites).
- **Legacy workflow:** APKs, `.aab`, updated `pubspec` (retention per YAML).
- **`fdroid-tag-publish.yml` + `fdroid-metadata-mr` action:** no app binaries in Actions (metadata MR only). GitLab secrets must be set as **job `env`** on the MR job (see [FDROID.md](../release/FDROID.md)).

## 🔐 Keystore (legacy workflow only) <a name="keystore-configuration"></a>

The **legacy** workflow decodes `KEYSTORE_BASE64` and writes `android/key.properties` for Gradle signing. **`test.yml`** does not use a keystore.

## 🔑 Secrets and variables <a name="secrets-and-variables"></a>

### Secrets (sensitive) <a name="secrets-sensitive"></a>

**Legacy workflow:** `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.

**F-Droid MR (reusable + tag workflow):** `GITLAB_TOKEN` on the MR job as **job `env`** from a repository secret (see [docs/release/FDROID.md](../release/FDROID.md)).

### Variables (non-sensitive) <a name="variables-non-sensitive"></a>

**F-Droid MR:** **`GITLAB_FORK_PROJECT_ID`** (required — numeric GitLab project ID of your fdroiddata fork). Optional **`FDROID_FLUTTER_VERSION`** — see [FDROID.md](../release/FDROID.md).

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
