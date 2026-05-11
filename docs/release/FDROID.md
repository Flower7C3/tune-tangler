# F-Droid publication (fdroiddata)

> Tune Tangler — `applicationId`: `pro.kwiatek.tune_tangler`, **MIT** license (`LICENSE`).

F-Droid builds and signs binaries. This app repo holds **metadata templates** (`tools/fdroid/`) and GitHub workflows.

**GitHub Actions:** the **F-Droid fork branch** workflow needs **`GITLAB_TOKEN`**, **`GITLAB_FORK_PROJECT_ID`**, optional **`FDROID_FLUTTER_VERSION`**, **`FDROID_ROBOT_BRANCH_PREFIX`**, **`FDROID_GITLAB_BRANCH`**. Details are in **[`docs/development/WORKFLOWS.md`](../development/WORKFLOWS.md)** — see the **F-Droid** rows and [Operator runbook](../development/WORKFLOWS.md#operator-runbook). Versioning on **`main`** and **`[skip ci]`** behavior live there too.

The sections below cover **fdroiddata** metadata shape, **`publish_fdroid_gitlab_branch.py`**, GitLab CI on your fork branch, and **manually opening a merge request to upstream** after the fork pipeline is green.

### Token or fork ID missing in CI

1. Open the failed run and check the **repository** in the header — secrets and variables exist **per repo**. If you use a **fork**, configure them **on that fork**, not only on the upstream repository.
2. **`GITLAB_TOKEN`:** create as an **Actions** repository **secret** (not only Dependabot). Name exactly `GITLAB_TOKEN`.
3. **`GITLAB_FORK_PROJECT_ID`:** create as an **Actions** repository **variable** (same settings page → **Variables** tab). Name exactly `GITLAB_FORK_PROJECT_ID` (digits only, no spaces).
4. **Organization secrets / variables:** an org owner must grant **Repository access** to this repository for each item.
5. Re-run the workflow after saving (no code change required beyond this repo’s workflow expecting a variable for the fork ID).

**fdroiddata CI (schema / lint):** Merge requests are validated against [`schemas/metadata.json`](https://gitlab.com/fdroid/fdroiddata/-/blob/master/schemas/metadata.json) (`fdroid lint`, `fdroid rewritemeta`, etc.). The **`git redirect`** job (artifact `codequality.json`) runs `tools/rewrite-git-redirects.py` then `git diff --exit-code`: if **`Repo:`** is a Git URL that Git’s HTTP client treats as a redirect (common on **GitHub** without the **`.git`** suffix from GitLab runners), the job fails — use `https://github.com/OWNER/REPO.git` in metadata. This repo’s publish script normalizes GitHub **`Repo`** to the `.git` form. Field meanings follow the [F-Droid build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/). `publish_fdroid_gitlab_branch.py` normalizes YAML to that schema (integer `ArchivePolicy`, **Categories** enum — this repo uses **`Multimedia`**), `CurrentVersion` / `CurrentVersionCode`, quoted modes where needed, **no `subdir` key** for repo root (`path` forbids `.` and values matching `^\./`). **`UpdateCheckMode: 'None'`** avoids the GitLab `checkupdates` job failing on Flutter (F-Droid cannot infer versions from tags the way it does for plain AndroidManifest apps); new versions are proposed via **merge requests from your fdroiddata fork branches** into `fdroid/fdroiddata`. After changing templates or the script, re-run the GitHub workflow or amend the branch on your fork.

**`metadata_static.yml` vs Fastlane**

- **Fastlane** (`fastlane/metadata/android/…`) — **source of listing text and graphics for F-Droid**: `title.txt`, `short_description.txt`, `full_description.txt`, `images/…` directories (**`en-US`** with short and full description is required). F-Droid copies these from the **tagged app commit** into the repo index (see [All About Descriptions…](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/)).
- **`tools/fdroid/metadata_static.yml`** — skeleton **YAML in fdroiddata** (`License`, `Repo`, `Categories`, `Builds`, …). **Without** `Summary` / `Description` / `Name` / `AutoName`, because those keys in the fdroiddata `.yml` **override** Fastlane in the app source.
- **`publish_fdroid_gitlab_branch.py`** strips those keys from existing YAML before pushing to your fork branch (if they were left from older edits) so F-Droid can take descriptions from the GitHub repo. The script also checks for `fastlane/metadata/android/en-US/{short_description,full_description}.txt`.

**What the script does** (`tools/fdroid/publish_fdroid_gitlab_branch.py`)

1. Verifies required Fastlane **`en-US`** files.
2. Reads `versionName` / `versionCode` from the **tag name** (preferred) or from `pubspec.yaml` (`MAJOR.MINOR.PATCH` or `...+build`).
3. Fetches `metadata/pro.kwiatek.tune_tangler.yml` from your fork on **`master`** (if missing — bootstraps from `metadata_static.yml` + first Build).
4. Merges the new **Build** into `Builds` (replaces same `versionCode` if present; dedupes by `versionCode`; if fork `master` already lists the same `versionCode` **and** `commit`, reuses that YAML as the base).
5. **Removes** `Name`, `AutoName`, `Summary`, `Description` from YAML (so Fastlane in source wins).
6. Pushes the full YAML to a **per-release branch** on your fork: **`{prefix}-{versionName}`** (default prefix `robot/tune-tangler` — a separate namespace for CI-created branches; not required by F-Droid). Override with **`FDROID_GITLAB_BRANCH`** (full name) or **`FDROID_ROBOT_BRANCH_PREFIX`**. Branch is created from **`master`** when it does not exist yet.
7. Prints the **GitLab tree URL** for that branch (CI / pipelines). It does **not** create an upstream merge request to `fdroid/fdroiddata` — you do that in GitLab when ready.

Optional GitHub **variables** **`FDROID_ROBOT_BRANCH_PREFIX`**, **`FDROID_GITLAB_BRANCH`** — see [WORKFLOWS](../development/WORKFLOWS.md#secrets-and-variables) and [`fdroid-gitlab-branch`](../../.github/actions/fdroid-gitlab-branch/action.yml). The composite checks out **`target_ref`** for app sources but replaces only **`tools/fdroid/publish_fdroid_gitlab_branch.py`** from the repo **default branch** so old tags still run the current script; **`metadata_static.yml`** / **`build_template.yml`** stay from the tag. **`target_ref`** may be left empty to use the **latest tag** on the default branch.

**Cleaning up on your fork:** delete obsolete `robot/tune-tangler-*` branches when you no longer need them.

**Keep your fork in sync** with upstream (`fdroid/fdroiddata`) or a later merge request may conflict. First time: add a minimal metadata file in the fork manually or let the workflow create it from `metadata_static.yml` — F-Droid **buildbot** must still accept the recipe (`build` / `init`); if rejected, fix `tools/fdroid/build_template.yml` and re-run the workflow or fix the branch manually.

## Manual path (no workflow)

1. Fork [`fdroiddata`](https://gitlab.com/fdroid/fdroiddata).
2. File: **`metadata/pro.kwiatek.tune_tangler.yml`** (path is `metadata/<applicationId>.yml`; see [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)) — patterns in `tools/fdroid/metadata_static.yml` and `tools/fdroid/build_template.yml`.
3. Open a **merge request to upstream** [`fdroid/fdroiddata`](https://gitlab.com/fdroid/fdroiddata): target branch **`master`**, source branch on **your fork** (the branch created by Actions, e.g. `robot/tune-tangler-1.7.1`).

### After Actions: upstream merge request (manual in GitLab)

Upstream expects a **public** fork and a **source branch that is not [protected](https://docs.gitlab.com/user/project/repository/branches/protected/)** (they rebase with fast-forward merges).

1. Run **Actions → F-Droid fork branch (fdroiddata)** with **`target_ref`** (tag/branch) or leave it empty for the latest tag. The run ends with a **link to your fork branch** in the job summary.
2. Wait for **fdroiddata** CI on that branch in GitLab. When it is green, open a **merge request from that branch** to **`fdroid/fdroiddata`** `master` using GitLab’s **App update** merge request template (remove the “Please remove above lines!” block, fill the checklist).

## Official references

- [Contributing to F-Droid](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md)
- [Build metadata reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [Inclusion policy](https://f-droid.org/en/docs/Inclusion_Policy/)

## Native dependencies (Android)

“Modified” audio export: **MediaCodec** + **Sonic** (`android/app/src/main/java/sonic/`, Apache 2.0).
