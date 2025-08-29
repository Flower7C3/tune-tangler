# ⚡ Quick Start

> Szybkie uruchomienie projektu TuneTangler w 5 minut

## 📋 Spis Treści

- [🚀 W 5 Kroków](#-w-5-kroków)
  - [1️⃣ Klonowanie Projektu](#-klonowanie-projektu)
  - [2️⃣ Setup Środowiska](#-setup-środowiska)
  - [3️⃣ Sprawdź Urządzenia](#-sprawdź-urządzenia)
  - [4️⃣ Uruchom Aplikację](#-uruchom-aplikację)
  - [5️⃣ Gotowe! 🎉](#-gotowe--)
- [🚨Jeśli coś nie działa](#jeśli-coś-nie-działa)
  - [❌ Flutter not found](#-flutter-not-found)
  - [❌ No devices found](#-no-devices-found)
  - [❌ Dependencies issues](#-dependencies-issues)
- [📱 Hot Reload](#-hot-reload)
- [🔄 Codzienny Workflow](#-codzienny-workflow)
- [🔨 Makefile](#-makefile)
- [📚 Co Dalej?](#-co-dalej)
- [🆘 Szybka Pomoc](#-szybka-pomoc)

## 🚀 W 5 Kroków

### 1️⃣ Klonowanie Projektu

Sklonuj repozytorium i sprawdź branch

```bash
git clone https://github.com/Flower7C3/tune-tangler.git
cd tune-tangler
git branch
```

Powinno być: `* main`

### 2️⃣ Setup Środowiska

Użyj Makefile do szybkiego setupu

```bash
make dev-setup
```

**To automatycznie:**
✅ Sprawdzi Flutter (flutter doctor)  
✅ Pobierze zależności (flutter pub get)  
✅ Zainstaluje pre-commit hook

### 3️⃣ Sprawdź Urządzenia

Lista dostępnych urządzeń

```bash
make list-devices
```

Lista emulatorów

```bash
make list-emulators
```

### 4️⃣ Uruchom Aplikację

```bash
make run
```

### 5️⃣ Gotowe! 🎉

Aplikacja powinna się uruchomić na wybranym urządzeniu/emulatorze.

## 🚨Jeśli coś nie działa

### ❌ Flutter not found

Sprawdź [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### ❌ No devices found

Sprawdź [Flutter Device Management](https://docs.flutter.dev/get-started/flutter-for/install-and-setup#device-setup)

### ❌ Dependencies issues

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

## 📱 Hot Reload

Podczas działania aplikacji:

```bash
r - Hot reload (zachowuje stan)
R - Hot restart (resetuje stan)
q - Wyjście
h - Pokaż pomoc
```

## 🔄 Codzienny Workflow

Użyj [Makefile](QUICKSTART.md#makefile) do codziennych zadań:

```bash
make dev-setup    # Setup środowiska
make analyze      # Analiza kodu
make test         # Testy
make run          # Uruchomienie
```

## 🔨 Makefile

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

## 📚 Co Dalej?

- **[🔧 Setup](SETUP.md)** – Szczegółowa konfiguracja
- **[🎣 Git Hooks](GIT_HOOKS.md)** – Automatyzacja wersjonowania
- **[🚀 Workflows](WORKFLOWS.md)** – CI/CD i deployment

## 🆘 Szybka Pomoc

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
