# 🚀 GitHub workflows guide

> GitHub Actions for Tune Tangler

## 📋 Table of contents

- [⚙️ Requirements](#requirements)
- [💾 Cache](#cache)
- [🔄 Overview](#overview)
  - [Workflows at a glance](#workflow-reference)
    - [Test Workflow (`test.yml`)](#tests-pr-main)
    - [Version & tag (`version-tag-main.yml`)](#version-tag-main)
    - [F-Droid fork branch (`release-fdroid-app.yml`)](#release-fdroid-app)
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
- **Checkout / jobs:** Single job; **[`flutter-test`](../../.github/actions/flutter-test/action.yml)** (**`actions/checkout`** + **`setup-flutter`** + analyze/tests inside the composite).
- **Composites & wiring:** **`flutter-test`** (inputs: **`flutter_channel`**, localization flags from the workflow). Invoked from **`version-tag-main`** via **`workflow_call`**; the parent workflow runs a **separate** job with full history for `pubspec`/tag work.

#### 📦 Version & tag (main) — [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) <a name="version-tag-main"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/version-tag-main.yml"><img  alt="version-tag-main.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/version-tag-main.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Version & tag (main)**
- **When:** `push` to `main` unless every touched path is under shared **`paths-ignore`** ([details](#shared-paths-ignore))
- **Manual / inputs:** —
- **Output:** Same tests as PRs, then `pubspec` bump + annotated tag
- **Checkout / jobs:** **`run_tests`**: `uses: ./.github/workflows/test.yml` (UI **`run_tests / 🧪 Test`**). **`version_tag`** (`needs: run_tests`): **`fetch-depth: 0`**
- **Composites & wiring:** **[`flutter-test`](../../.github/actions/flutter-test/action.yml)** (checkout + **`setup-flutter`** + analyze + tests). Bump **`pubspec`** ([Versioning policy](#versioning-policy)) via **[`pubspec-bump-tag-push`](../../.github/actions/pubspec-bump-tag-push/action.yml)** → commit **`[skip ci]`**, push **`main`**, annotated tag **`v…+…`**.

#### 🦊 F-Droid fork branch (fdroiddata) — [`release-fdroid-app.yml`](../../.github/workflows/release-fdroid-app.yml) <a name="release-fdroid-app"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-fdroid-app.yml"><img  alt="release-fdroid-app.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-fdroid-app.yml/badge.svg"></a></p>

- **In Actions (approx.):** **F-Droid fork branch (fdroiddata)**
- **When:** Manual only
- **Manual / inputs:** **`target_ref`** (optional — tag or branch; leave empty for **latest tag** on the default branch)
- **Output:** Pushes fdroiddata metadata YAML (path from composite / repo variables, default **`metadata/pro.kwiatek.tune_tangler.yml`**) to a **fixed-name fork branch** (default **`robot/tune-tangler`**). Job outputs **`gitlab_tree_url`** (pipelines for **`FDROID_GITLAB_BRANCH`**), **`gitlab_branch`**, **`gitlab_compare_url`**; step summary also lists the branch tree link. The workflow does not open a merge request — you open one in GitLab after CI is green.
- **Checkout / jobs:** **[`publish-fdroid-gitlab-metadata`](../../.github/actions/publish-fdroid-gitlab-metadata/action.yml)** composite: default branch → resolve **`target_ref`** + SHA → checkout release tree → overlay **`publish_fdroid_gitlab_branch.py`** from default branch → Python + **`publish_fdroid_gitlab_branch.py`**. Secrets / variables: [below](#secrets-and-variables) and [FDROID.md](../release/FDROID.md)

#### 🚀 Release on GitHub (APK/AAB files) — [`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml) <a name="release-apk-aab-google-play"></a>

<p><a href="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-apk-aab-google-play.yml"><img  alt="release-apk-aab-google-play.yml CI" src="https://github.com/Flower7C3/tune-tangler/actions/workflows/release-apk-aab-google-play.yml/badge.svg"></a></p>

- **In Actions (approx.):** **Release on GitHub (APK/AAB files)**
- **When:** Manual only
- **Manual / inputs:** **`tag`** (must already exist, e.g. `v1.7.0+12`); optional **`release_artifact_basename`** (APK/AAB filename prefix; empty → variable **`RELEASE_ARTIFACT_BASENAME`**, else **`github.event.repository.name`** — e.g. `tune-tangler`)
- **Output:** Signed APK + `.aab` + GitHub Release (single job; no intermediate artifact upload).
- **Checkout / jobs:** One job runs **[`android-github-apk-aab-release`](../../.github/actions/android-github-apk-aab-release/action.yml)** end-to-end. The workflow passes **`with:`** for tag, artifact basename resolution, Flutter/Java channels, release template path, and title prefix ([Keystore](#keystore-configuration)).

### Operator runbook <a name="operator-runbook"></a><a name="how-to-use"></a><a name="ci-on-main"></a><a name="fdroid-one-click"></a><a name="manual-release-only-option"></a><a name="testing-build-process"></a>

| Goal | Do this |
|------|---------|
| **CI on a PR to `main`** | Open/update the PR; [`test.yml`](../../.github/workflows/test.yml) runs ([`paths-ignore`](#shared-paths-ignore) still applies to changed files). |
| **Version bump + tag after merge** | Push/merge to `main`; [`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml) runs when paths are not all ignored ([workflow summaries](#workflow-reference)). |
| **F-Droid fork branch** | **Actions** → **F-Droid fork branch (fdroiddata)** → optional **`target_ref`** (empty = latest tag). Use the **pipelines** (watch CI on **`FDROID_GITLAB_BRANCH`**) and **compare** links in the summary (baseline ref from **`FDROID_GITLAB_COMPARE_BASE_REF`** / **`FDROID_GITLAB_FORK_PARENT_REF`**); open a merge request to upstream manually when CI is green. |
| **GitHub Release (APK / AAB)** | **Actions** → **Release on GitHub (APK/AAB files)** → **Run workflow** → set **`tag`**; optional **`release_artifact_basename`** or repo variable **`RELEASE_ARTIFACT_BASENAME`** for artifact filenames (default: GitHub **repository name**). Configure keystore secrets ([Keystore](#keystore-configuration)). |
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
| [`setup-flutter`](../../.github/actions/setup-flutter/action.yml) | Flutter SDK (`subosito/flutter-action`), `flutter pub get`, optional `flutter gen-l10n`, dependency cache. Used from **`flutter-test`** and **`android-github-apk-aab-release`**. |
| [`flutter-test`](../../.github/actions/flutter-test/action.yml) | **`actions/checkout`** → **`setup-flutter`** → **`flutter analyze`** + **`flutter test`** (+ optional **`integration_test`**). Used by **[`test.yml`](../../.github/workflows/test.yml)** (`flutter_channel`, localization, **`checkout_fetch_depth`** from workflow **`with:`**). |
| [`git-config-github-actions-bot`](../../.github/actions/git-config-github-actions-bot/action.yml) | `git config` for **`github-actions[bot]`** (optional `user_name` / `user_email`). Invoked from **`pubspec-bump-tag-push`**. |
| [`setup-java`](../../.github/actions/setup-java/action.yml) | JDK for Android APK/AAB builds. Used from **`android-github-apk-aab-release`**. |
| [`android-github-apk-aab-release`](../../.github/actions/android-github-apk-aab-release/action.yml) | Checkout tag → Flutter + Java → keystore → **`flutter build`** APK + app bundle → verify → rename → release notes from template → duplicate guard → **`softprops/action-gh-release`**. Project-specific values come from workflow **`with:`** inputs. |
| [`pubspec-bump-tag-push`](../../.github/actions/pubspec-bump-tag-push/action.yml) | Used by **[`version-tag-main.yml`](../../.github/workflows/version-tag-main.yml)** after tests: checkout, git bot config, **`pubspec`** bump (+`GITHUB_RUN_NUMBER`), commit suffix, push branch, annotated tag. Pass **`before_sha`**, **`checkout_token`**, and commit/tag message **`inputs`**. |
## 🔐 Keystore (APK/AAB release workflow only) <a name="keystore-configuration"></a>

The **`release-apk-aab-google-play.yml`** workflow decodes `KEYSTORE_BASE64` and writes `android/key.properties` for Gradle signing. The decoded keystore is written to a temp file named **`{RELEASE_ARTIFACT_BASENAME}-release-key.jks`** (see [Secrets and variables](#secrets-and-variables) for how that basename is chosen). **`test.yml`** does not use a keystore.

## 🔑 Secrets and variables <a name="secrets-and-variables"></a>

| Kind | Workflow / context | Names |
|------|-------------------|--------|
| **Secrets** | APK/AAB ([`release-apk-aab-google-play.yml`](../../.github/workflows/release-apk-aab-google-play.yml)) | `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` |
| **Variables** | APK/AAB release | Optional **`RELEASE_ARTIFACT_BASENAME`** — prefix for release APK/AAB filenames and the temp decoded keystore file (default: **`github.event.repository.name`**; overridable per run with workflow input **`release_artifact_basename`**) |
| **Secrets** | F-Droid fork branch | `GITLAB_TOKEN` as **job `env`** from a repository secret ([FDROID.md](../release/FDROID.md) for fork / token pitfalls) |
| **Variables** | F-Droid fork branch | **`GITLAB_FORK_PROJECT_ID`** (required). Optional: **`FDROID_METADATA_PATH`**, **`FDROID_GITLAB_BRANCH`**, **`FDROID_GIT_COMMIT_SUBJECT_PREFIX`**, **`FDROID_GITLAB_FORK_PARENT_REF`**, **`FDROID_GITLAB_COMPARE_BASE_REF`** — forwarded to **[`publish-fdroid-gitlab-metadata`](../../.github/actions/publish-fdroid-gitlab-metadata/action.yml)**; empty values fall back to that action’s defaults ([FDROID.md](../release/FDROID.md)). Flutter SDK version comes from **`.metadata`** on the release ref; **`tools/fdroid/`** is overlaid from the default branch in CI. |

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
- **[📦 F-Droid](../release/FDROID.md)** — fork branch workflow + `tools/fdroid/`
