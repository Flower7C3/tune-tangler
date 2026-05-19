# Agent / assistant rules (Tune Tangler)

> Where AI assistant rules live and how to edit them for this repository.

**Canonical rules** for AI assistants (including Cursor) live under **`.cursor/rules/`** as `.mdc` files. Each file sets `alwaysApply` / `globs` in YAML frontmatter — do not duplicate long policy text here; **edit the `.mdc` files**.

| File | Role |
|------|------|
| [`.cursor/rules/git-consent.mdc`](.cursor/rules/git-consent.mdc) | Git writes require explicit consent; amend; context |
| [`.cursor/rules/tune-tangler-assistant.mdc`](.cursor/rules/tune-tangler-assistant.mdc) | Code changes, tooling, response style, boundaries |
| [`.cursor/rules/tune-tangler-project.mdc`](.cursor/rules/tune-tangler-project.mdc) | Conventions, repo layout, links |
