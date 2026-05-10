# F-Droid publication (fdroiddata)

> Tune Tangler — `applicationId`: `pro.kwiatek.tune_tangler`, **MIT** license (`LICENSE`).

F-Droid builds and signs binaries. This app repo holds **metadata templates** (`tools/fdroid/`) and GitHub workflows.

## Versioning on `main`

- **[`pubspec-auto-patch-main.yml`](../../.github/workflows/pubspec-auto-patch-main.yml)** — on **`push` to `main`** (same `paths-ignore` as `test.yml`): if that push **does not** change the `version:` line in `pubspec`, **PATCH** is incremented (`1.6.5` → `1.6.6`, no `+` suffix). A **minor/major** change or a release commit that edits `version:` **skips** auto-patch.
- **F-Droid release** (below) sets **`{base from pubspec before +} + GITHUB_RUN_NUMBER`** when tagging — build number equals the workflow run number.

## Recommended release (one click)

**Workflow:** [`.github/workflows/fdroid-app-release.yml`](../../.github/workflows/fdroid-app-release.yml) — **F-Droid release (test, tag, MR)**.

**Steps:** tests → set **`pubspec`** to **`base+GITHUB_RUN_NUMBER`** (artifact) → [`pubspec-commit-tag-push`](../../.github/actions/pubspec-commit-tag-push/action.yml) (commit + tag + push + changelog in **job summary**) → **MR to fdroiddata**.

**Trigger:** **`workflow_dispatch` only** (no inputs — semantic version comes from current `pubspec` on the branch).

The changelog list is **not** sent to GitLab or fdroiddata; the MR uses the tagged commit only.

## Metadata MR from a tag only (no version bump in Actions)

**Workflow:** [`.github/workflows/fdroid-tag-publish.yml`](../../.github/workflows/fdroid-tag-publish.yml) — calls composite [`.github/actions/fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml).

**When it runs**

- `push` of tags matching: `v1.2.3`, `v1.2.3+4`, `1.2.3`, `1.2.3+4`, etc. (e.g. a tag created locally).
- Optionally manually: **Actions → F-Droid metadata (GitLab MR) → Run workflow** — input **`version_override`** overrides version from the tag / `pubspec` for the MR script only (**does not** change `pubspec` or GitHub tags).

**GitHub repository secrets** (Settings → Secrets and variables → Actions)

| Secret | Purpose |
|--------|---------|
| `GITLAB_TOKEN` | GitLab personal access token with `api` scope (write to your fdroiddata fork). |
| `GITLAB_FORK_PROJECT_ID` | **Numeric** project ID of the fork (GitLab → *your fdroiddata fork* → Settings → General → Project ID). |

**Optional variable** — *Repository variables*

| Variable | Purpose |
|----------|---------|
| `FDROID_FLUTTER_VERSION` | Flutter version used in the `init` recipe (e.g. `3.29.0`). If empty, the workflow uses the **latest stable** from Flutter’s JSON (same idea as local `setup-flutter`). |

**`metadata_static.yml` vs Fastlane**

- **Fastlane** (`fastlane/metadata/android/…`) — **source of listing text and graphics for F-Droid**: `title.txt`, `short_description.txt`, `full_description.txt`, `images/…` directories (**`en-US`** with short and full description is required). F-Droid copies these from the **tagged app commit** into the repo index (see [All About Descriptions…](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/)).
- **`tools/fdroid/metadata_static.yml`** — skeleton **YAML in fdroiddata** (`License`, `Repo`, `Categories`, `Builds`, …). **Without** `Summary` / `Description` / `Name` / `AutoName`, because those keys in the fdroiddata `.yml` **override** Fastlane in the app source.
- **`publish_fdroid_mr.py`** strips those keys from existing YAML before writing the MR (if they were left from older edits) so F-Droid can take descriptions from the GitHub repo. The script also checks for `fastlane/metadata/android/en-US/{short_description,full_description}.txt`.

**Version alignment:** semantic version on `main` comes from **auto-patch + manual edits**; release appends **`+build`** from CI and a tag that matches `pubspec`.

**What the script does** (`tools/fdroid/publish_fdroid_mr.py`)

1. Verifies required Fastlane **`en-US`** files.
2. Reads `versionName` / `versionCode` from the **tag name** (preferred) or from `pubspec.yaml` (`MAJOR.MINOR.PATCH` or `...+build`).
3. Fetches `metadata/pro.kwiatek.tune_tangler.yml` from your fork on `master` (if missing — creates from `metadata_static.yml` + first Build).
4. **Appends** a new entry to `Builds` (no duplicate `versionCode`).
5. **Removes** `Name`, `AutoName`, `Summary`, `Description` from YAML (so Fastlane in source wins).
6. Creates branch `robot/tune-tangler-…`, commits YAML, **MR to `fdroid/fdroiddata`** (`target_project_id` resolved from path `fdroid/fdroiddata`).

**Keep your fork in sync** with upstream (`fdroid/fdroiddata`) or the MR may conflict. First time: add a minimal metadata file in the fork manually or let the workflow create it from `metadata_static.yml` — F-Droid **buildbot** must still accept the recipe (`build` / `init`); if rejected, fix `tools/fdroid/build_template.yml` and push the tag again (or fix the MR manually).

## Manual path (no workflow)

1. Fork [`fdroiddata`](https://gitlab.com/fdroid/fdroiddata).
2. File: `metadata/pro.kwiatek.tune_tangler.yml` — patterns in `tools/fdroid/metadata_static.yml` and `tools/fdroid/build_template.yml`.
3. Open MR to upstream fdroiddata.

## Official references

- [Contributing to F-Droid](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [Inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)

## Native dependencies (Android)

“Modified” audio export: **MediaCodec** + **Sonic** (`android/app/src/main/java/sonic/`, Apache 2.0).

## Other workflows in this repo

- [`test.yml`](../../.github/workflows/test.yml) — CI on PR and `push` to `main`.
- [`pubspec-auto-patch-main.yml`](../../.github/workflows/pubspec-auto-patch-main.yml) — auto PATCH on `main` when `version:` is unchanged in that push.
- [`fdroid-app-release.yml`](../../.github/workflows/fdroid-app-release.yml) — tests → `pubspec` `base+GITHUB_RUN_NUMBER` (artifact) → commit + tag + fdroiddata MR (recommended).
- [`release-legacy-github-play-apk-aab.yml`](../../.github/workflows/release-legacy-github-play-apk-aab.yml) — same `+build` `pubspec` policy, then signed APK/AAB + GitHub Release.

Details: [../development/WORKFLOWS.md](../development/WORKFLOWS.md).
