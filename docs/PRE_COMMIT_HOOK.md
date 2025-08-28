# Pre-commit Hook - Automatyczne Inkrementowanie Wersji

## 📋 Opis

Pre-commit hook automatycznie zwiększa **patch version** w `pubspec.yaml` przed każdym commitem. To zapewnia, że każdy commit ma unikalną wersję.

## 🔧 Instalacja

### Automatyczna (zalecana)

```bash
# Skrypt automatycznie instaluje hook
./scripts/install_pre_commit_hook.sh
```

### Ręczna

```bash
# Skopiuj hook do .git/hooks/
cp .git/hooks/pre-commit .git/hooks/pre-commit

# Nadaj uprawnienia wykonywania
chmod +x .git/hooks/pre-commit
```

## 🚀 Jak to działa

1. **Przed każdym commit** - hook sprawdza czy `pubspec.yaml` jest już zmodyfikowany
2. **Jeśli NIE** - zwiększa patch version (np. 1.2.1 → 1.2.2)
3. **Jeśli TAK** - pomija (nie duplikuje zmian)
4. **Automatycznie stage** - zaktualizowany `pubspec.yaml`

## 📊 Przykłady

### Przed commitem:

```
🔄 Pre-commit hook: Checking for version increment...
📋 Current version: 1.2.1
🆕 New version: 1.2.2
✅ Version incremented to 1.2.2 and staged for commit
💡 Commit message will include: version 1.2.2
```

### Po commicie:

```bash
git log --oneline -1
# Output: abc1234 version 1.3.0
```

## ⚙️ Konfiguracja

### Wyłączenie hooka

```bash
# Tymczasowo
git commit --no-verify

# Trwale
rm .git/hooks/pre-commit
```

### Modyfikacja logiki

Edytuj `.git/hooks/pre-commit`:

- **Patch increment** (domyślnie): `NEW_PATCH=$((CURRENT_PATCH + 1))`
- **Minor increment**: `NEW_MINOR=$((CURRENT_MINOR + 1))`
- **Major increment**: `NEW_MAJOR=$((CURRENT_MAJOR + 1))`

## 🔍 Sprawdzenie statusu

```bash
# Sprawdź czy hook jest aktywny
ls -la .git/hooks/pre-commit

# Sprawdź uprawnienia
file .git/hooks/pre-commit
```

## ⚠️ Uwagi

- **Hook działa lokalnie** - każdy developer musi go zainstalować
- **Nie commitować** - hook jest w `.gitignore`
- **Backup** - hook tworzy `.bak` plik (automatycznie usuwany)
- **Git add** - hook automatycznie stage'uje zmiany

## 🐛 Troubleshooting

### Hook nie działa

```bash
# Sprawdź uprawnienia
chmod +x .git/hooks/pre-commit

# Sprawdź czy jest w .git/hooks/
ls -la .git/hooks/
```

### Błąd sed

```bash
# Na macOS może wymagać gnu-sed
brew install gnu-sed
# Lub zmień sed -i.bak na sed -i '' w skrypcie
```

### Konflikt wersji

```bash
# Ręcznie rozwiąż w pubspec.yaml
git checkout -- pubspec.yaml
git add pubspec.yaml
git commit
```
