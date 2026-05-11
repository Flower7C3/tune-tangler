# Agent / assistant rules (Tune Tangler)

This file in the repository root is the canonical place for rules used by AI coding assistants (including Cursor).

## Critical

### Git

- Do **not** commit, push, tag, reset, or force-push without **explicit** user consent (e.g. “make a commit”, “push to origin”, “run git commit”). A **Conventional Commits** message suggestion, “conv commit”, or similar is **not** consent unless the user clearly authorizes the git write.
- Do **not** amend commits that have already been pushed to `origin`.
- Before non-trivial git operations, show reasonable context (for example `git status`).

### Code changes

- Prefer small, readable diffs; avoid wide refactors without consent.
- Explain what you are doing; for many files or risky changes, propose a plan first, then implement.

### Project conventions

- Commit messages: [Conventional Commits](https://www.conventionalcommits.org/).
- Localization: `lib/l10n/*.arb`, then `flutter gen-l10n`.
- Default branch: **`main`** (as in this repository).
- CI / release: see [docs/development/WORKFLOWS.md](docs/development/WORKFLOWS.md) (shared **composite actions** under `.github/actions/`; **`test.yml`** runs on **PR** to `main` (and manual dispatch); **`version-tag-main`** on **push** to `main` runs **tests then** updates `pubspec` + tag; **F-Droid** (`release-fdroid-app.yml`) pushes metadata to a **versioned branch** on your **fdroiddata** fork and prints the GitLab branch link (**`target_ref`** optional — empty means latest tag on the default branch); you open the fdroiddata **merge request** in GitLab manually; **`release-apk-aab-google-play.yml`** builds signed **APK/AAB** from an **existing tag** and publishes a **GitHub Release** — no extra commits/tags in those workflows).

## How assistants should work

- This is a **real** environment with shell and network when available: **run** commands and use tools to investigate; do not only tell the user what to run.
- Do not give up after a single failure—try alternatives, diagnose, and retry when sensible.
- When citing existing code in chat, use the project’s code-reference format (line ranges and file paths) so navigation is one click.

## Response style

- Be concise and clear; do not hide tool or build failures.

## Do not

- Assume user intent instead of clarifying when requirements are ambiguous.
- Ignore analyzer or build failures you could fix or report accurately.

## Repository layout (short)

- `.github/workflows/` — CI/CD entry workflows
- `.github/actions/` — composite actions used by workflows (e.g. `fdroid-gitlab-branch`)
- `android/`, `ios/`, … — platform projects
- `lib/` — Flutter app code
- `docs/` — documentation (`docs/development/`, `docs/release/`, `docs/features/`)
- `tools/` — scripts and config (`fdroid/`, `screenshots.sh` + `screenshots.json`, `generate-icons.sh`, …)
- `Makefile` — helpers, including `pre-commit` hook install/remove targets
- `.githooks/pre-commit` — source for the optional local hook (copied to `.git/hooks/pre-commit` when installed)

## Links

- [Git hooks](docs/development/GIT_HOOKS.md)
- [GitHub workflows](docs/development/WORKFLOWS.md)
- [F-Droid / fdroiddata](docs/release/FDROID.md)
- [Store listings & screenshots](docs/release/STORE_LISTINGS.md)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Flutter documentation](https://docs.flutter.dev/development)
