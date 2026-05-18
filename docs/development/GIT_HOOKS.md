# 🎣 Git hooks in Tune Tangler

## 📋 Table of contents

- [🔧 One-time configuration](#one-time-configuration)
- [🪝 `pre-commit`](#pre-commit)
- [🔨 Makefile](#makefile)
- [⏭️ Skip the hook once](#skip-the-hook-once)

---

## 🔧 One-time configuration <a name="one-time-configuration"></a>

Install the optional hook **once per clone** (or after `git clone` on a new machine):

```bash
make install-pre-commit-hook
```

Removes with `make remove-pre-commit-hook`. See [Makefile](#makefile).

## 🪝 `pre-commit`

| | |
|--|--|
| **File in the repo** | [`.githooks/pre-commit`](../../.githooks/pre-commit) |
| **After install** | `.git/hooks/pre-commit` (copy of the file above) |
| **Behavior** | Before a commit, runs `flutter analyze` at the project root. If analysis fails, the commit is blocked. If `flutter` is not on `PATH`, the hook exits successfully and skips analysis. |

## 🔨 Makefile <a name="makefile"></a>

| Goal | Command |
|------|---------|
| Install hook | `make install-pre-commit-hook` |
| Remove hook | `make remove-pre-commit-hook` |

## ⏭️ Skip the hook once <a name="skip-the-hook-once"></a>

```bash
git commit --no-verify -m "message"
```
