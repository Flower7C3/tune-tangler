# F-Droid publication (fdroiddata)

> Tune Tangler — `applicationId`: `pro.kwiatek.tune_tangler`, **MIT** license (`LICENSE`).

F-Droid builds and signs binaries. This app repo holds **metadata templates** (`tools/fdroid/`) and GitHub workflows.

**GitHub Actions:** when the MR workflow runs, what it needs from the repo (**`GITLAB_TOKEN`**, **`GITLAB_FORK_PROJECT_ID`**, optional **`FDROID_*`** variables), and how to invoke it are documented in **[`docs/development/WORKFLOWS.md`](../development/WORKFLOWS.md)** — see the **F-Droid** rows in [Workflow reference](../development/WORKFLOWS.md#workflow-reference), [Implementation](../development/WORKFLOWS.md#implementation-checkout-jobs), [Operator runbook](../development/WORKFLOWS.md#operator-runbook), and [Secrets and variables](../development/WORKFLOWS.md#secrets-and-variables). Versioning on **`main`** and **`[skip ci]`** behavior live there too.

The sections below cover **fdroiddata** metadata shape, **`publish_fdroid_mr.py`**, GitLab MR CI quirks, and the **manual MR path**.

### Token or fork ID missing in CI

1. Open the failed run and check the **repository** in the header — secrets and variables exist **per repo**. If you use a **fork**, configure them **on that fork**, not only on the upstream repository.
2. **`GITLAB_TOKEN`:** create as an **Actions** repository **secret** (not only Dependabot). Name exactly `GITLAB_TOKEN`.
3. **`GITLAB_FORK_PROJECT_ID`:** create as an **Actions** repository **variable** (same settings page → **Variables** tab). Name exactly `GITLAB_FORK_PROJECT_ID` (digits only, no spaces).
4. **Organization secrets / variables:** an org owner must grant **Repository access** to this repository for each item.
5. Re-run the workflow after saving (no code change required beyond this repo’s workflow expecting a variable for the fork ID).

**fdroiddata CI (schema / lint):** Merge requests are validated against [`schemas/metadata.json`](https://gitlab.com/fdroid/fdroiddata/-/blob/master/schemas/metadata.json) (`fdroid lint`, `fdroid rewritemeta`, etc.). The **`git redirect`** job (artifact `codequality.json`) runs `tools/rewrite-git-redirects.py` then `git diff --exit-code`: if **`Repo:`** is a Git URL that Git’s HTTP client treats as a redirect (common on **GitHub** without the **`.git`** suffix from GitLab runners), the job fails — use `https://github.com/OWNER/REPO.git` in metadata. This repo’s MR script normalizes GitHub **`Repo`** to the `.git` form. Field meanings follow the [F-Droid build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/). `publish_fdroid_mr.py` normalizes YAML to that schema (integer `ArchivePolicy`, **Categories** enum — this repo uses **`Multimedia`**), `CurrentVersion` / `CurrentVersionCode`, quoted modes where needed, **no `subdir` key** for repo root (`path` forbids `.` and values matching `^\./`). **`UpdateCheckMode: 'None'`** avoids the GitLab `checkupdates` job failing on Flutter (F-Droid cannot infer versions from tags the way it does for plain AndroidManifest apps); new versions are still proposed via this repo’s metadata MRs. After changing templates or the script, push again from CI or amend the branch on your fdroiddata fork.

**`metadata_static.yml` vs Fastlane**

- **Fastlane** (`fastlane/metadata/android/…`) — **source of listing text and graphics for F-Droid**: `title.txt`, `short_description.txt`, `full_description.txt`, `images/…` directories (**`en-US`** with short and full description is required). F-Droid copies these from the **tagged app commit** into the repo index (see [All About Descriptions…](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/)).
- **`tools/fdroid/metadata_static.yml`** — skeleton **YAML in fdroiddata** (`License`, `Repo`, `Categories`, `Builds`, …). **Without** `Summary` / `Description` / `Name` / `AutoName`, because those keys in the fdroiddata `.yml` **override** Fastlane in the app source.
- **`publish_fdroid_mr.py`** strips those keys from existing YAML before writing the MR (if they were left from older edits) so F-Droid can take descriptions from the GitHub repo. The script also checks for `fastlane/metadata/android/en-US/{short_description,full_description}.txt`.

**What the script does** (`tools/fdroid/publish_fdroid_mr.py`)

1. Verifies required Fastlane **`en-US`** files.
2. Reads `versionName` / `versionCode` from the **tag name** (preferred) or from `pubspec.yaml` (`MAJOR.MINOR.PATCH` or `...+build`).
3. Fetches `metadata/pro.kwiatek.tune_tangler.yml` from your fork on `master` (if missing — creates from `metadata_static.yml` + first Build).
4. Merges the new **Build** into `Builds` (replaces same `versionCode` if present; dedupes by `versionCode`; skips if fork `master` already has that `versionCode` **and** `commit`).
5. **Removes** `Name`, `AutoName`, `Summary`, `Description` from YAML (so Fastlane in source wins).
6. Commits the full YAML to a **stable** branch on the fork (default **`robot/tune-tangler`**). If that branch does not exist yet, it is created from `master`. If an **open** MR from that branch to **`fdroid/fdroiddata`** `master` already exists, the script **does not** open another MR — it only pushes a new commit so the existing MR updates.

Optional env **`FDROID_METADATA_SOURCE_BRANCH`** overrides the default `robot/tune-tangler` branch name on the fork; mirror the GitHub **variable** of the same name ([WORKFLOWS](../development/WORKFLOWS.md#secrets-and-variables), [`fdroid-metadata-mr`](../../.github/actions/fdroid-metadata-mr/action.yml)).

**Cleaning up older spam on your fork:** close redundant open MRs to upstream and delete obsolete `robot/tune-tangler-*` branches if you no longer need them; keep one MR on `robot/tune-tangler` going forward.

**Keep your fork in sync** with upstream (`fdroid/fdroiddata`) or the MR may conflict. First time: add a minimal metadata file in the fork manually or let the workflow create it from `metadata_static.yml` — F-Droid **buildbot** must still accept the recipe (`build` / `init`); if rejected, fix `tools/fdroid/build_template.yml` and re-run the workflow or fix the MR manually.

## Manual path (no workflow)

1. Fork [`fdroiddata`](https://gitlab.com/fdroid/fdroiddata).
2. File: **`metadata/pro.kwiatek.tune_tangler.yml`** (path is `metadata/<applicationId>.yml`; see [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)) — patterns in `tools/fdroid/metadata_static.yml` and `tools/fdroid/build_template.yml`.
3. Open an MR **to upstream** [`fdroid/fdroiddata`](https://gitlab.com/fdroid/fdroiddata): target branch **`master`**, source branch on **your fork** (CI defaults to `robot/tune-tangler` unless you set **`FDROID_METADATA_SOURCE_BRANCH`** as in [WORKFLOWS](../development/WORKFLOWS.md#secrets-and-variables)).

## Official references

- [Contributing to F-Droid](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [Inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)

## Native dependencies (Android)

“Modified” audio export: **MediaCodec** + **Sonic** (`android/app/src/main/java/sonic/`, Apache 2.0).
