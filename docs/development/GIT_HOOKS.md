# 🎣 Git hooks in Tune Tangler

## `pre-commit`

| | |
|--|--|
| **File in the repo** | [`.githooks/pre-commit`](../../.githooks/pre-commit) |
| **After install** | `.git/hooks/pre-commit` (copy of the file above) |
| **Behavior** | Before a commit, runs `flutter analyze` at the project root. If analysis fails, the commit is blocked. If `flutter` is not on `PATH`, the hook exits successfully and skips analysis. |

## Makefile

| Goal | Command |
|------|---------|
| Install hook | `make install-pre-commit-hook` |
| Remove hook | `make remove-pre-commit-hook` |

## Skip the hook once

```bash
git commit --no-verify -m "message"
```
