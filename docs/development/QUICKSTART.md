# ⚡ Quick Start

> Szybkie uruchomienie projektu TuneTangler w 5 minut

## 📋 Spis Treści

- [🚀 W 5 Kroków](#5-steps)
  - [1️⃣ Klonowanie Projektu](#clone-project)
  - [2️⃣ Setup Środowiska](#setup-environment)
  - [3️⃣ Sprawdź Urządzenia](#check-devices)
  - [4️⃣ Uruchom Aplikację](#run-app)
  - [5️⃣ Gotowe! 🎉](#ready)
- [🚨Jeśli coś nie działa](#troubleshooting)
  - [❌ Flutter not found](#flutter-not-found)
  - [❌ No devices found](#no-devices-found)
  - [❌ Dependencies issues](#dependencies-issues)
- [📱 Hot Reload](#hot-reload)
- [🔄 Codzienny Workflow](#daily-workflow)
- [🔨 Makefile](#makefile)
- [📚 Co Dalej?](#what-next)
- [🆘 Szybka Pomoc](#quick-help)

## 🚀 W 5 Kroków <a name="5-steps"></a>

### 1️⃣ Klonowanie Projektu <a name="clone-project"></a>

Sklonuj repozytorium i sprawdź branch

```bash
git clone https://github.com/Flower7C3/tune-tangler.git
cd tune-tangler
git branch
```

Powinno być: `* main`

### 2️⃣ Setup Środowiska <a name="setup-environment"></a>

Użyj Makefile do szybkiego setupu

```bash
make dev-setup
```

**To automatycznie:**
✅ Sprawdzi Flutter (flutter doctor)  
✅ Pobierze zależności (flutter pub get)  
✅ Zainstaluje pre-commit hook

### 3️⃣ Sprawdź Urządzenia <a name="check-devices"></a>

Lista dostępnych urządzeń

```bash
make list-devices
```

Lista emulatorów

```bash
make list-emulators
```

### 4️⃣ Uruchom Aplikację <a name="run-app"></a>

```bash
make run
```

### 5️⃣ Gotowe! 🎉 <a name="ready"></a>

Aplikacja powinna się uruchomić na wybranym urządzeniu/emulatorze.

## 🚨Jeśli coś nie działa <a name="troubleshooting"></a>

### ❌ Flutter not found <a name="flutter-not-found"></a>

Sprawdź [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### ❌ No devices found <a name="no-devices-found"></a>

Sprawdź [Flutter Device Management](https://docs.flutter.dev/get-started/flutter-for/install-and-setup#device-setup)

### ❌ Dependencies issues <a name="dependencies-issues"></a>

**Wyczyść cache:**

```bash
flutter clean
```

**Pobierz ponownie:**

```bash
flutter pub get
```

**Sprawdź Flutter:**

```bash
flutter doctor
```

## 📱 Hot Reload <a name="hot-reload"></a>

Podczas działania aplikacji:

```bash
r - Hot reload (zachowuje stan)
R - Hot restart (resetuje stan)
q - Wyjście
h - Pokaż pomoc
```

## 🔄 Codzienny Workflow <a name="daily-workflow"></a>

Użyj [Makefile](QUICKSTART.md#makefile) do codziennych zadań:

```bash
make dev-setup    # Setup środowiska
make analyze      # Analiza kodu
make test         # Testy
make run          # Uruchomienie
```

## 🔨 Makefile <a name="makefile"></a>

Główne komendy do codziennej pracy:

```bash
# Setup środowiska
make dev-setup          # Pełna konfiguracja
make quick-start        # Szybki start z listą urządzeń

# Code quality
make analyze            # Analiza kodu
make test               # Uruchomienie testów
make format             # Formatowanie kodu

# Build & Run
make run                # Uruchomienie aplikacji
make build-apk          # Budowanie APK
make install-apk        # Budowanie i instalacja APK

# Git hooks
make install-pre-commit-hook    # Instalacja pre-commit hooka
make remove-pre-commit-hook     # Usunięcie pre-commit hooka
```

**Wszystkie komendy:** `make help`

## 📚 Co Dalej? <a name="what-next"></a>

- **[🔧 Setup](SETUP.md)** – Szczegółowa konfiguracja
- **[🎣 Git Hooks](GIT_HOOKS.md)** – Automatyzacja wersjonowania
- **[🚀 Workflows](WORKFLOWS.md)** – CI/CD i deployment

## 🆘 Szybka Pomoc <a name="quick-help"></a>

Sprawdź status

```bash
make help
```

Diagnostyka

```bash
flutter doctor -v
```

Logi

```bash
flutter logs
```

Reset

```bash
flutter clean && flutter pub get
```
