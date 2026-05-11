# 🚀 GitHub workflows guide

> GitHub Actions for Tune Tangler

## 📋 Table of contents

- [⚙️ Requirements](#requirements)
- [💾 Cache](#cache)
- [🔄 Overview](#overview)
  - [Workflows at a glance](#workflow-reference)
    - [Test Workflow (`test.yml`)](#tests-pr-main)
    - [Version & tag (`version-tag-main.yml`)](#version-tag-main)
    - [Release on F-Droid (`release-fdroid-app.yml`)](#release-fdroid-app)
    - [Release on GitHub APK/AAB (`release-apk-aab-google-play.yml`)](#release-apk-aab-google-play)
  - [Operator runbook](#operator-runbook)
  - [Versioning policy](#versioning-policy)
  - [Shared `paths-ignore`](#shared-paths-ignore)
  - [Skip / `push` (`[skip ci]`)](#skip-and-push-behavior)
- [🧩 Composite actions](#composite-actions)
- [🔐 Keystore (APK/AAB release workflow only)](#keystore-configuration)
- [🔑 Secrets and variables](#secrets-and-variables)
- [🚨 Troubleshooting](#troubleshooting)
  - [❌ Permission denied](#permission-denied-error)
  - [❌ Flutter not found](#flutter-not-found-error)
  - [❌ Java not found](#java-not-found-error)
  - [❌ Keystore issues](#keystore-problem)
  - [❌ Keystore password incorrect](#keystore-password-incorrect-error)
- [📚 Additional resources](#additional-resources)

## ⚙️ Requirements <a name="requirements"></a>

| Need | Where |
|------|--------|
| Flutter stable | Composite actions ([`setup-flutter`](../../.github/actions/setup-flutter/action.yml)) |
| Java 17 (Zulu) for Android | **`release-apk-aab-google-play.yml`** only |
| Runner | `ubuntu-latest` |

## 💾 Cache <a name="cache"></a>

Workflows may cache `~/.pub-cache` and `~/.gradle/caches` (see each YAML).

## 🔄 Overview <a name="overview"></a>

Exact workflow titles in GitHub come from each file’s top-level `name:`. **[Requirements](#requirements)** and **[Cache](#cache)** above are what the runners assume. Each workflow below has its **own status badge**, **trigger summary**, and **implementation notes** (no wide table). The **[operator runbook](#operator-runbook)** lists common tasks.

### Workflows at a glance <a name="workflow-reference"></a><a name="quick-reference"></a><a name="implementation-checkout-jobs"></a><a name="workflows"></a><a name="ci-status-badges"></a>

#### 🧪 Test Workflow — [`test.yml`](../../.github/workflows/test.yml) <a name="tests-pr-main"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/test.yml"><img  alt="test.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/test.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Test Workflow**
- **When:** PR to `main`, **`workflow_call`** from version-tag, or manual
- **Manual / inputs:** —
- **Output:** Analyzer + unit tests
- **Checkout / jobs:** Single job; **`actions/checkout`** **`fetch-depth: 1`**
- **Composites & wiring:** **[`setup-flutter`](../../.github/actions/setup-flutter/action.yml)** → **[`flutter-test`](../../.github/actions/flutter-test/action.yml)**. Invoked from **`version-tag-main`** via **`workflow_call`**; the parent workflow runs a **separate** job with full history for `pubspec`/tag work.

#### 📦 Version & tag (main) — [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) <a name="version-tag-main"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/version-tag-main.yml"><img  alt="version-tag-main.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/version-tag-main.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Version & tag (main)**
- **When:** `push` to `main` unless every touched path is under shared **`paths-ignore`** ([details](#shared-paths-ignore))
- **Manual / inputs:** —
- **Output:** Same tests as PRs, then `pubspec` bump + annotated tag
- **Checkout / jobs:** **`run_tests`**: `uses: ./.github/workflows/test.yml` (UI **`run_tests / 🧪 Test`**). **`version_tag`** (`needs: run_tests`): **`fetch-depth: 0`**
- **Composites & wiring:** Bump **`pubspec`** ([Versioning policy](#versioning-policy)) → **[`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml)** when the version line changes → bot commit **`[skip ci]`** ([Skip / push behavior](#skip-and-push-behavior)), push **`main`**, tag **`v…+…`**

#### 📱 Release on F-Droid (via MR) — [`release-fdroid-app.yml`](../../.github/workflows/release-fdroid-app.yml) <a name="release-fdroid-app"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-fdroid-app.yml"><img  alt="release-fdroid-app.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-fdroid-app.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Release on F-Droid (via MR)**
- **When:** Manual only
- **Manual / inputs:** **`target_ref`** (optional — tag or branch; leave empty for **latest tag** reachable from the default branch), **`gitlab_stage`** — **`push_for_ci`** (metadata commit on your fdroiddata fork only; GitLab CI), **`open_draft_mr`** (Draft MR + checklist after CI; use the same ref resolution as push), or **`push_and_open_draft_mr`** (both in one run)
- **Output:** Updates your **fdroiddata** fork branch; optionally opens a **Draft** MR to upstream (no commits/tags in this repo)
- **Checkout / jobs:** Checkout default branch → resolve ref (`target_ref` or `git describe --tags`) → checkout that tree
- **Composites & wiring:** **[`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml)**. Secrets / variables: [below](#secrets-and-variables) and [FDROID.md](../release/FDROID.md)

#### 🚀 Release on GitHub (APK/AAB files) — [`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml) <a name="release-apk-aab-google-play"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-apk-aab-google-play.yml"><img  alt="release-apk-aab-google-play.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-apk-aab-google-play.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Release on GitHub (APK/AAB files)**
- **When:** Manual only
- **Manual / inputs:** **`tag`** (must already exist, e.g. `v1.7.0+12`)
- **Output:** Signed APK + `.aab` + GitHub Release; build artifacts uploaded before the release is created
- **Checkout / jobs:** Two jobs: **build & verify** → **GitHub Release**
- **Composites & wiring:** Build: Flutter, Java, keystore, **`flutter build`**, signature check, artifact upload. Release: rename artifacts, optional changelog, duplicate guard. [Keystore](#keystore-configuration)

### Operator runbook <a name="operator-runbook"></a><a name="how-to-use"></a><a name="ci-on-main"></a><a name="fdroid-one-click"></a><a name="manual-release-only-option"></a><a name="testing-build-process"></a>

| Goal | Do this |
|------|---------|
| **CI on a PR to `main`** | Open/update the PR; [`test.yml`](../../.github/workflows/test.yml) runs ([`paths-ignore`](#shared-paths-ignore) still applies to changed files). |
| **Version bump + tag after merge** | Push/merge to `main`; [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) runs when paths are not all ignored ([workflow summaries](#workflow-reference)). |
| **F-Droid metadata MR** | **Actions** → **Release on F-Droid (via MR)** → optional **`target_ref`** (empty = latest tag on default branch). Recommended: **`gitlab_stage`** **`push_for_ci`** first, then **`open_draft_mr`** (same empty or explicit ref); or **`push_and_open_draft_mr`** for one run. |
| **GitHub Release (APK / AAB)** | **Actions** → **Release on GitHub (APK/AAB files)** → **Run workflow** → set **`tag`** → configure keystore secrets if needed ([Keystore](#keystore-configuration)). |
| **Ad-hoc / manual test run** | **Actions** → pick a workflow that exposes **Run workflow** → run (e.g. [`test.yml`](../../.github/workflows/test.yml)). |

### Versioning policy <a name="versioning-policy"></a>

Applies to **[`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)** on eligible **`push` to `main`**:

| Topic | Rule |
|-------|------|
| Target format | **`MAJOR.MINOR.PATCH+GITHUB_RUN_NUMBER`** |
| Push **does not** change the **`version:`** line in `pubspec.yaml` | **Increment PATCH**, then set **`+build`** from the run number |
| Push **does** change **`version:`** | **No** extra PATCH bump; align **`base+GITHUB_RUN_NUMBER`** to the new base only |
| After the bot pushes | Bot commit uses **`[skip ci]`** — see [Skip / `push` behavior](#skip-and-push-behavior) |

### Shared `paths-ignore` <a name="shared-paths-ignore"></a>

[`test.yml`](../../.github/workflows/test.yml) (PRs) and [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) (`push` to `main`) use the **same ignore list**. Change **both** YAML files together when you edit it.

### Skip / `push` behavior (`[skip ci]`) <a name="skip-workflow"></a><a name="skip-and-push-behavior"></a>

| Situation | What happens |
|-----------|----------------|
| Commit message contains **`[skip ci]`** | **`version-tag-main`** skips **`run_tests`** and **`version_tag`** |
| Bot **`pubspec`** commit | Carries **`[skip ci]`** so the follow-up push does not re-run the same pipeline ([Versioning policy](#versioning-policy)) |
| Tests on `main` without a PR | Only via **`version-tag-main`** when its path filters apply; **`test.yml`** has **no** `push` trigger |

## 🧩 Composite actions <a name="composite-actions"></a>

Reusable steps under [`.github/actions/`](../../.github/actions/):

| Action | Role |
|--------|------|
| [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) | Flutter SDK (`subosito/flutter-action`), `flutter pub get`, optional `flutter gen-l10n`, dependency cache. Workflows run **`actions/checkout`** before this action when the tree must be present (e.g. **`test.yml`**, APK/AAB **release** builds). |
| [`flutter-test`](../../.github/actions/flutter-test/action.yml) | `flutter analyze` + `flutter test` (+ optional `integration_test`). |
| [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) | Commit/push `pubspec` changes; optional annotated tag and changelog collection. Used by **`version-tag-main`**. |
| [`git-config-github-actions-bot`](../../.github/actions/git-config-github-actions-bot/action.yml) | `git config` for **`github-actions[bot]`** (optional `user_name` / `user_email`). Used at the start of **`version-tag-main.yml`** and inside **`pubspec-commit-tag-push`**. |
| [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml) | GitLab fork + optional Draft MR to fdroiddata; the **workflow** sets job **`env.FDROID_GITLAB_STAGE`** (`push` / `mr` / `both`) from **`gitlab_stage`** so release tags are not forced to ship a new composite. Pass **`metadata_source_branch`** from **`vars.FDROID_METADATA_SOURCE_BRANCH`** when set (see [FDROID.md](../release/FDROID.md)). |
| [`setup-java`](../../.github/actions/setup-java/action.yml) | JDK for Android APK/AAB builds (**`release-apk-aab-google-play.yml`** only). Run **`actions/checkout`** in the job before this step (this action does not checkout the repo). |

## 🔐 Keystore (APK/AAB release workflow only) <a name="keystore-configuration"></a>

The **`release-apk-aab-google-play.yml`** workflow decodes `KEYSTORE_BASE64` and writes `android/key.properties` for Gradle signing. **`test.yml`** does not use a keystore.

## 🔑 Secrets and variables <a name="secrets-and-variables"></a>

| Kind | Workflow / context | Names |
|------|-------------------|--------|
| **Secrets** | APK/AAB ([`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml)) | `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` |
| **Secrets** | F-Droid MR | `GITLAB_TOKEN` as **job `env`** from a repository secret ([FDROID.md](../release/FDROID.md) for fork / token pitfalls) |
| **Variables** | F-Droid MR | **`GITLAB_FORK_PROJECT_ID`** (required). Optional **`FDROID_FLUTTER_VERSION`**, **`FDROID_METADATA_SOURCE_BRANCH`** — use `vars.*` in the workflow |

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
