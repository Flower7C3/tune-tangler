# TuneTangler Makefile
# Auto-generated help: make help

# Colors and icons
@COLOR_GREEN := \033[32m
@COLOR_BLUE := \033[34m
@COLOR_YELLOW := \033[33m
@COLOR_RED := \033[31m
@COLOR_CYAN := \033[36m
@FORMAT_BOLD := \033[1m
@FORMAT_RESET := \033[0m


# Icons
@ICON_CHECK := ✓
@ICON_INFO := ℹ
@ICON_WARN := ⚠
@ICON_ERROR := ✗
@ICON_ROCKET := 🚀
@ICON_BUILD := 🔨
@ICON_TEST := 🧪
@ICON_CLEAN := 🧹
@ICON_DEVICE := 📱
@ICON_EMULATOR := 🖥
@ICON_UPGRADE := ⬆
@ICON_HELP := ❓

.PHONY: help
help: ## Show this help
	@echo "$(@FORMAT_BOLD)$(@COLOR_CYAN)TuneTangler - Available Commands$(@RESET)"
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_ROCKET) Development Setup$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##SETUP## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_TEST) Code Quality$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##QA##' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_BUILD) Run & Build$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##BUILD## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_DEVICE) Device Management$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##DEVICE## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Maintenance$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##MAINTENANCE## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_UPGRADE) Utilities$(@FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##UTILITIES## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'

# =============================================================================
# DEVELOPMENT SETUP
# =============================================================================

.PHONY: dev-setup
dev-setup: ##SETUP## Setup development environment
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_ROCKET) Setting up development environment...$(@FORMAT_RESET)"
	@make doctor
	@make pub-get
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_CHECK) Environment ready!$(@FORMAT_RESET)"
	@echo "$(@COLOR_YELLOW)$(@ICON_INFO) Run 'make analyze' to check code quality$(@FORMAT_RESET)"

.PHONY: quick-start
quick-start: dev-setup list-devices ##SETUP## Setup development environment and show devices
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_ROCKET) Quick start completed!$(@FORMAT_RESET)"
	@echo "$(@COLOR_YELLOW)$(@ICON_INFO) To run the app, use: make run$(@FORMAT_RESET)"

# =============================================================================
# CODE QUALITY
# =============================================================================

.PHONY: analyze
analyze: ##QA## Analyze code quality
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Running code analysis...$(@FORMAT_RESET)"
	@flutter analyze

.PHONY: test
test: ##QA## Run tests
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_TEST) Running tests...$(@FORMAT_RESET)"
	@flutter test

.PHONY: format
format: ##QA## Format code
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Formatting code...$(@FORMAT_RESET)"
	@dart format .

.PHONY: lint
lint: ##QA## Check code style
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Checking code style...$(@FORMAT_RESET)"
	@dart analyze

# =============================================================================
# BUILD & RUN
# =============================================================================

.PHONY: run
run: run-debug ##BUILD## Run app (debug) - alias

.PHONY: run-debug
run-debug: ##BUILD## Run app (debug)
	@echo "$(@FORMAT_BOLD)$(@ICON_ROCKET)$(@ICON_INFO) Running app (debug)...$(@FORMAT_RESET)"
	@flutter run --debug

.PHONY: run-release
run-release: ##BUILD## Run app (release)
	@echo "$(@FORMAT_BOLD)$(@ICON_ROCKET)$(@ICON_INFO) Running app (release)...$(@FORMAT_RESET)"
	@flutter run --release

.PHONY: increment-build-version
increment-build-version: ##BUILD## Increment build version
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Increment build version...$(@FORMAT_RESET)"
	@./scripts/increment_build.sh

.PHONY: build-apk
build-apk: build-apk-debug ##BUILD## Build APK (debug) - alias

.PHONY: build-apk-debug
build-apk-debug: increment-build-version ##BUILD## Build APK (debug with build version incrementation)
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Building APK (debug)...$(@FORMAT_RESET)"
	@flutter build apk --debug

.PHONY: build-apk-release
build-apk-release: increment-build-version ##BUILD## Build APK (release, with build version incrementation)
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Building APK (release)...$(@FORMAT_RESET)"
	@flutter build apk --release

#.PHONY: build-ios
#build-ios: ##BUILD## Build iOS (debug)
#	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Building iOS (debug)...$(@FORMAT_RESET)"
#	@flutter build ios --debug

.PHONY: install-apk
install-apk: install-apk-debug ##BUILD## Build and install APK (debug) - alias

.PHONY: install-apk-debug
install-apk-debug: build-apk-debug ##BUILD## Build and install APK (debug)
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Installing APK (debug)...$(@FORMAT_RESET)"
	adb install build/app/outputs/flutter-apk/app-debug.apk
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_CHECK) Application installed!$(@FORMAT_RESET)"

.PHONY: install-apk-release
install-apk-release: build-apk-release ##BUILD## Build and install APK (release)
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD)$(@ICON_INFO) Installing APK (release)...$(@FORMAT_RESET)"
	adb install build/app/outputs/flutter-apk/app-release.apk
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_CHECK) Application installed!$(@FORMAT_RESET)"

.PHONY: clean
clean: ##BUILD## Clean build and cache
	@echo "$(@FORMAT_BOLD)$(@ICON_CLEAN)$(@ICON_INFO) Cleaning build and cache...$(@FORMAT_RESET)"
	@flutter clean
	@make pub-get

.PHONY: full-build
full-build: clean pub-get analyze build-apk ##BUILD## All-in-one: clean, get dependencies, analyze and build debug
	@echo "$(@FORMAT_BOLD)$(@COLOR_GREEN)$(@ICON_CHECK) Full build completed!$(@FORMAT_RESET)"

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

.PHONY: list-devices
list-devices: ##DEVICE## Show available devices
	@echo "$(@FORMAT_BOLD)$(@ICON_DEVICE)$(@ICON_INFO) Available devices:$(@FORMAT_RESET)"
	@flutter devices

.PHONY: list-emulators
list-emulators: ##DEVICE## Show available emulators
	@echo "$(@FORMAT_BOLD)$(@ICON_EMULATOR)$(@ICON_INFO) Available emulators:$(@FORMAT_RESET)"
	@flutter emulators

# =============================================================================
# MAINTENANCE
# =============================================================================

.PHONY: doctor
doctor: ##MAINTENANCE## Check flutter environment
	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Checking Flutter environment...$(@FORMAT_RESET)"
	@flutter doctor

.PHONY: pub-get
pub-get: ##MAINTENANCE## Get dependencies
	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Getting dependencies...$(@FORMAT_RESET)"
	@flutter pub get

.PHONY: pub-outdated
pub-outdated: ##MAINTENANCE## Check outdated packages
	@echo "$(@FORMAT_BOLD)$(@COLOR_WARN)$(@ICON_INFO) Checking for outdated packages...$(@FORMAT_RESET)"
	@flutter pub outdated

.PHONY: pub-upgrade
pub-upgrade: ##MAINTENANCE## Upgrade dependencies
	@echo "$(@FORMAT_BOLD)$(@ICON_UPGRADE)$(@ICON_INFO) Upgrading dependencies...$(@FORMAT_RESET)"
	@flutter pub upgrade

.PHONY: sdk-upgrade
sdk-upgrade: ##MAINTENANCE## Upgrade Flutter SDK
	@echo "$(@FORMAT_BOLD)$(@ICON_UPGRADE)$(@ICON_INFO) Upgrading Flutter SDK...$(@FORMAT_RESET)"
	@flutter upgrade

# =============================================================================
# UTILITIES
# =============================================================================

.PHONY: gen-l10n
gen-l10n: ##UTILITIES## Generate l10n files
	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Generating localization files...$(@FORMAT_RESET)"
	@flutter gen-l10n

.PHONY: gen-icons
gen-icons: ##UTILITIES## Generate app icons
	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Generating app icons...$(@FORMAT_RESET)"
	@dart run flutter_launcher_icons

.PHONY: gen-splash
gen-splash: ##UTILITIES## Generate splash screen
	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Generating splash screen...$(@FORMAT_RESET)"
	@dart run flutter_native_splash:create

# Git hook commands removed - version incrementing now handled by GitHub workflow

.PHONY: create-tag
create-tag: ##UTILITIES## Create and push version tag
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Creating version tag...$(@FORMAT_RESET)"
	@if [ -f pubspec.yaml ]; then \
		VERSION=$$(grep '^version:' pubspec.yaml | sed 's/.*version: //' | sed 's/+.*//'); \
		echo "$(@COLOR_CYAN)Creating tag v$$VERSION...$(@FORMAT_RESET)"; \
		git tag "v$$VERSION"; \
		git push origin "v$$VERSION"; \
		echo "$(@COLOR_GREEN)$(@ICON_CHECK) Tag v$$VERSION created and pushed"; \
	else \
		echo "$(@COLOR_RED)$(@ICON_ERROR) pubspec.yaml not found!$(@FORMAT_RESET)"; \
		exit 1; \
	fi

.PHONY: list-tags
list-tags: ##UTILITIES## List all version tags
	@echo "$(@FORMAT_BOLD)$(@COLOR_BLUE)$(@ICON_INFO) Available version tags:$(@FORMAT_RESET)"
	@git tag --sort=-version:refname | head -10

#.PHONY: rename
#rename: ## Change name
#	@echo "$(@FORMAT_BOLD)$(@ICON_INFO) Changing app name...$(@FORMAT_RESET)"
#	dart run rename_app:main all="Tune Tangler"
