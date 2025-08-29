# 🤖 Assistant Rules for TuneTangler Project

## 📋 Spis Treści

- [🚨 CRITICAL RULES – NEVER BREAK](#-critical-rules--never-break)
  - [1️⃣ Git Operations – NEVER DO WITHOUT EXPLICIT PERMISSION](#-git-operations--never-do-without-explicit-permission)
  - [2️⃣ Code Changes – GRADUAL AND SAFE](#-code-changes--gradual-and-safe)
  - [3️⃣ Project-Specific Rules](#-project-specific-rules)
- [🔧 WORKFLOW RULES](#-workflow-rules)
  - [4️⃣ When User Asks for Changes](#-when-user-asks-for-changes)
  - [5️⃣ When User Asks for Git Operations](#-when-user-asks-for-git-operations)
  - [6️⃣ When User Asks for Code Review](#-when-user-asks-for-code-review)
- [📝 COMMUNICATION RULES](#-communication-rules)
  - [7️⃣ Response Style](#-response-style)
  - [8️⃣ Error Handling](#-error-handling)
- [🎯 PROJECT KNOWLEDGE](#-project-knowledge)
  - [9️⃣ Remember These Key Points](#-remember-these-key-points)
  - [🔟 File Structure Awareness](#-file-structure-awareness)
- [🚫 WHAT I WILL NEVER DO](#-what-i-will-never-do)
- [📚 Dodatkowe Zasoby](#-dodatkowe-zasoby)

## 🚨 **CRITICAL RULES – NEVER BREAK**

### 1️⃣ **Git Operations – NEVER DO WITHOUT EXPLICIT PERMISSION**

- ❌ **NEVER** commit changes without explicit user permission
- ❌ **NEVER** push to remote without explicit user permission
- ❌ **NEVER** create tags without explicit user permission
- ❌ **NEVER** force push or reset without explicit user permission
- ❌ **NEVER** amend commits that have been pushed to origin
- ✅ **ALWAYS** ask before making any git operations
- ✅ **ALWAYS** show git status before suggesting changes

### 2️⃣ **Code Changes – GRADUAL AND SAFE**

- ✅ **ALWAYS** make small, incremental changes
- ✅ **ALWAYS** ask before making multiple file changes
- ✅ **ALWAYS** explain what each change does
- ✅ **ALWAYS** test changes before suggesting commit
- ❌ **NEVER** make large refactoring without explicit permission
- ❌ **NEVER** change multiple files simultaneously without approval

### 3️⃣ **Project-Specific Rules**

- ✅ **ALWAYS** use `console_utils.py` to format output (if available)
- ✅ **ALWAYS** follow Conventional Commits format
- ✅ **ALWAYS** respect the CI workflow sequence: test → build →
  version-control → release
- ✅ **ALWAYS** avoid hardcoding static Flutter version numbers
- ✅ **NEVER** send or release versions before building
- ✅ **ALWAYS** place translation files in `l10n` directory
- ✅ **ALWAYS** use 'master' branch (not 'main')

## 🔧 **WORKFLOW RULES**

### 4️⃣ **When User Asks for Changes**

1. **Analyze** the current state
2. **Propose** specific, small changes
3. **Wait** for user approval
4. **Implement** only approved changes
5. **Verify** changes work correctly
6. **Ask** before committing

### 5️⃣ **When User Asks for Git Operations**

1. **Show** current git status first
2. **Explain** what will happen
3. **Wait** for explicit permission
4. **Execute** only after approval
5. **Confirm** operation completed

### 6️⃣ **When User Asks for Code Review**

1. **Read** the relevant files
2. **Identify** potential issues
3. **Suggest** specific improvements
4. **Wait** for user decision
5. **Implement** only if approved

## 📝 **COMMUNICATION RULES**

### 7️⃣ **Response Style**

- ✅ **Keep responses concise** (user prefers shorter, less verbose responses)
- ✅ **Use clear, actionable language**
- ✅ **Explain technical concepts simply**
- ✅ **Provide step-by-step instructions when needed**
- ✅ **Use emojis and formatting for clarity**

### 8️⃣ **Error Handling**

- ✅ **Always explain what went wrong**
- ✅ **Provide specific solutions**
- ✅ **Suggest alternatives when possible**
- ✅ **Never hide or ignore errors**

## 🎯 **PROJECT KNOWLEDGE**

### 9️⃣ **Remember These Key Points**

- **Flutter project** with Android/iOS support
- **Uses keystore** for app signing
- **GitHub Actions workflow** for CI/CD
- **Makefile** for development commands
- **Documentation** in `docs/` directory
- **Version management** through workflow

### 🔟 **File Structure Awareness**

- **`.github/workflows/`** – CI/CD workflows
- **`android/`** – Android-specific configuration
- **`docs/`** – Project documentation
- **`scripts/`** – Utility scripts
- **`Makefile`** – Development commands

## 🚫 **WHAT I WILL NEVER DO**

- ❌ **NEVER** make assumptions about user intentions
- ❌ **NEVER** execute commands without explicit permission
- ❌ **NEVER** ignore project-specific rules
- ❌ **NEVER** make changes that could break the build
- ❌ **NEVER** suggest unsafe git operations
- ❌ **NEVER** ignore error messages or warnings

## 📚 **Dodatkowe Zasoby**

- **[Conventional Commits](https://www.conventionalcommits.org/)** – Format commitów
- **[Git Best Practices](https://git-scm.com/book/en/v2)** – Oficjalna dokumentacja Git
- **[Flutter Development](https://docs.flutter.dev/development)** – Oficjalna dokumentacja Flutter
