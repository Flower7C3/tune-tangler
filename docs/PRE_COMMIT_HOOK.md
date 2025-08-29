# Pre-commit Hook - Automatyczne Inkrementowanie Wersji

## 📋 Opis

Pre-commit hook automatycznie zwiększa **patch version** w [pubspec.yaml](../pubspec.yaml) przed każdym commitem. To zapewnia, że każdy commit ma unikalną wersję.

## 🚀 Jak to działa

1. **Przed każdym commit** – hook sprawdza czy `pubspec.yaml` jest już zmodyfikowany
2. **Jeśli NIE** – zwiększa patch version (np. 1.2.1 → 1.2.2)
3. **Jeśli TAK** – pomija (nie duplikuje zmian)
4. **Automatycznie stage** – zaktualizowany `pubspec.yaml`

## 🔧 Instalacja

 Makefile automatycznie instaluje hook

```bash
make install-pre-commit-hook
```

## ⏼ Wyłączenie hooka

- Tymczasowo

    ```bash
    git commit --no-verify
    ```

- Trwale (używając Makefile)

    ```bash
    make remove-pre-commit-hook
    ```

## 📊 Przykłady

### Przed commitem

```text
🔄 Pre-commit hook: Checking for version increment...
📋 Current version: 1.2.1
🆕 New version: 1.2.2
✅ Version incremented to 1.2.2 and staged for commit
💡 Commit message will include: version 1.2.2
```

### Po commicie

```bash
git log --oneline -1
# Output: abc1234 version 1.3.0
```

## ⚠️ Uwagi

- **Hook działa lokalnie** – każdy developer musi go zainstalować
- **Nie commitować** – hook jest w `.gitignore`
- **Backup** – hook tworzy `.bak` plik (automatycznie usuwany)
- **Git add** – hook automatycznie stage'uje zmiany

## 🐛 Troubleshooting

### Hook nie działa

```bash
# Sprawdź uprawnienia
chmod +x .git/hooks/pre-commit

# Sprawdź czy jest w .git/hooks/
ls -la .git/hooks/

# Lub użyj Makefile do reinstalacji
make remove-pre-commit-hook
make install-pre-commit-hook
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
