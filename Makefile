# TuneTangler Makefile

# Colors and icons
COLOR_GREEN := \033[32m
COLOR_BLUE := \033[34m
COLOR_YELLOW := \033[33m
COLOR_RED := \033[31m
COLOR_CYAN := \033[36m
FORMAT_BOLD := \033[1m
FORMAT_HIGHLIGHT := \033[7m
FORMAT_RESET := \033[0m


# Icons
ICON_CHECK := ✓
ICON_INFO := ℹ
ICON_QUESTION := ❓
ICON_WARN := ⚠
ICON_ERROR := ✗
ICON_ROCKET := 🚀
ICON_BUILD := 🔨
ICON_TEST := 🧪
ICON_CLEAN := 🧹
ICON_DEVICE := 📱
ICON_EMULATOR := 🖥
ICON_UPGRADE := ⬆
ICON_HELP := ❓

define choose-device
	DEVICES=($$(adb devices | grep -E "^[^[:space:]]+[[:space:]]+device" | awk "{print \$$1}")); \
	if [ $${#DEVICES[@]} -eq 0 ]; then \
		echo "$(COLOR_RED)$(ICON_ERROR) No devices found!$(FORMAT_RESET)"; \
		exit 1; \
	else \
		echo "$(COLOR_CYAN)$(ICON_INFO) Select device to install on:$(FORMAT_RESET)"; \
		select DEVICE in "$${DEVICES[@]}"; do \
			if [ -n "$$DEVICE" ]; then \
				break; \
			else \
				echo "$(COLOR_RED)$(ICON_ERROR) Invalid selection. Please choose a number.$(FORMAT_RESET)"; \
			fi; \
		done; \
	fi; \
	echo "$(COLOR_BLUE)$(ICON_INFO) Selected $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_BLUE) device$(FORMAT_RESET)"
endef

define choose-emulator
	if [ -z "$$EMULATOR" ]; then\
		printf "Loading emulators..."; \
		EMULATORS=($$(flutter emulators | grep -E "^[a-zA-Z0-9_-]+[[:space:]]+•" | grep -v "^Id" | awk "{print \$$1}")); \
		printf "\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r"; \
		if [ $${#EMULATORS[@]} -eq 0 ]; then \
			echo "$(COLOR_RED)$(ICON_ERROR) No emulators found!$(FORMAT_RESET)"; \
			exit 1; \
		elif [ $${#EMULATORS[@]} -eq 1 ]; then \
			echo "$(COLOR_BLUE)$(ICON_INFO) Only one emulator found, starting $${EMULATORS[0]}...$(FORMAT_RESET)"; \
			EMULATOR=$${EMULATORS[0]}; \
		else \
			echo "$(COLOR_CYAN)$(ICON_INFO) Select emulator to start:$(FORMAT_RESET)"; \
			select EMULATOR in "$${EMULATORS[@]}"; do \
				if [ -n "$$EMULATOR" ]; then \
					break; \
				else \
					echo "$(COLOR_RED)$(ICON_ERROR) Invalid selection. Please choose a number.$(FORMAT_RESET)"; \
				fi; \
			done; \
		fi; \
	fi; \
	echo "$(COLOR_BLUE)$(ICON_INFO) Selected $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_BLUE) emulator$(FORMAT_RESET)"
endef

# Auto-generated help: make help
.PHONY: help
help: ## Show this help
	@echo "$(FORMAT_BOLD)$(COLOR_CYAN)TuneTangler - Available Commands$(FORMAT_RESET)"
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_ROCKET) Development Setup$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##SETUP## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_TEST) Code Quality$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##QA##' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_BUILD) Run & Build$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##BUILD## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_RED)$(ICON_INFO) IMPORTANT: To run, build or install app in $(FORMAT_BOLD)release$(FORMAT_RESET)$(COLOR_RED) mode, you need to use GitHub Actions to build and sign the app bundle$(FORMAT_RESET)"
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_DEVICE) Device Management$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##DEVICE## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_INFO) Maintenance$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##MAINTENANCE## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(FORMAT_BOLD)$(COLOR_BLUE)$(ICON_UPGRADE) Utilities$(FORMAT_RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##UTILITIES## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(COLOR_CYAN)%-25s$(FORMAT_RESET) %s\n", $$1, $$2}'

# =============================================================================
# DEVELOPMENT SETUP
# =============================================================================

.PHONY: dev-setup
dev-setup: ##SETUP## Setup development environment
	@echo "$(FORMAT_HIGHLIGHT)$(COLOR_GREEN)$(ICON_ROCKET) Setting up development environment...$(FORMAT_RESET)"
	@make doctor
	@make pub-get
	@echo "$(COLOR_GREEN)$(ICON_CHECK) Environment ready!$(FORMAT_RESET)"
	@echo "$(COLOR_YELLOW)$(ICON_INFO) Run 'make analyze' to check code quality$(FORMAT_RESET)"

.PHONY: quick-start
quick-start: dev-setup list-devices ##SETUP## Setup development environment and show devices
	@echo "$(FORMAT_BOLD)$(COLOR_GREEN)$(ICON_ROCKET) Quick start completed!$(FORMAT_RESET)"
	@echo "$(COLOR_YELLOW)$(ICON_INFO) To run the app, use: make run$(FORMAT_RESET)"

# =============================================================================
# CODE QUALITY
# =============================================================================

.PHONY: analyze
analyze: ##QA## Run code analysis
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Running code analysis...$(FORMAT_RESET)"
	@flutter analyze

.PHONY: test
test: ##QA## Run tests
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_TEST) Running tests...$(FORMAT_RESET)"
	@flutter test

.PHONY: format
format: ##QA## Format code
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Formatting code...$(FORMAT_RESET)"
	@dart format .

.PHONY: lint
lint: ##QA## Check code style
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Checking code style...$(FORMAT_RESET)"
	@dart analyze

# =============================================================================
# BUILD & RUN
# =============================================================================
.PHONY: run
run: ##BUILD## Run app in debug mode
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_ROCKET) Running app in $(FORMAT_BOLD)debug$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) build type...$(FORMAT_RESET)"
	@flutter run --debug

.PHONY: build-apk
build-apk: ##BUILD## Build APK in debug mode
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Building $(FORMAT_BOLD)debug$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) APK...$(FORMAT_RESET)"
	@flutter build apk --debug --build-number=$(($(date +%s)/1000))

.PHONY: build-apk-release
build-apk-release:
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Building $(FORMAT_BOLD)release$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) AAB and APK...$(FORMAT_RESET)"; \
	export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true -Dorg.gradle.jvmargs=-Xmx4g"; \
	flutter build apk --split-per-abi; \
  	flutter build appbundle

.PHONY: install-apk
install-apk: ##BUILD## Build and install APK in debug mode
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_BUILD) APK Installation$(FORMAT_RESET)"
	@DEVICE=$(DEVICE); $(choose-device); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Installing $(FORMAT_BOLD)debug$(FORMAT_RESET)$(COLOR_BLUE) APK on $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_BLUE) device...$(FORMAT_RESET)"; \
	adb -s $$DEVICE install -r build/app/outputs/flutter-apk/app-debug.apk; \
	echo "$(COLOR_GREEN)$(ICON_CHECK)APK installed on $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_GREEN) device!$(FORMAT_RESET)"

.PHONY: clean
clean: ##BUILD## Clean build and cache
	@echo "$(ICON_CLEAN) Cleaning build and cache...$(FORMAT_RESET)"
	@flutter clean
	@make pub-get

.PHONY: full-build
full-build: clean pub-get analyze build-apk ##BUILD## All-in-one: clean, get dependencies, analyze and build debug
	@echo "$(COLOR_GREEN)$(ICON_CHECK) Full build completed!$(FORMAT_RESET)"

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

.PHONY: list-devices
list-devices: ##DEVICE## Show available devices
	@echo "$(COLOR_GREEN)$(ICON_DEVICE) Available devices:$(FORMAT_RESET)"
	@bash -c 'flutter devices | grep -E "^[[:space:]]+[^[:space:]]+.*\\([a-z]+\\)[[:space:]]*•" | sed "s/^[[:space:]]*//"'

.PHONY: list-emulators
list-emulators: ##DEVICE## Show available emulators
	@echo "$(COLOR_GREEN)$(ICON_EMULATOR) Available emulators:$(FORMAT_RESET)"
	@echo "Loading emulators..."
	@bash -c 'flutter emulators | grep -E "^[a-zA-Z0-9_-]+[[:space:]]+•" | grep -v "^Id"'
	@echo "$(COLOR_CYAN)$(ICON_INFO) Use make start-emulator to start emulator with selection$(FORMAT_RESET)"
	@echo "$(COLOR_CYAN)$(ICON_INFO) Use make run-emulator to run app on emulator with selection$(FORMAT_RESET)"

.PHONY: start-emulator
start-emulator: ##DEVICE## Start emulator with interactive selection
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Starting $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_BLUE) emulator...$(FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR

.PHONY: run-emulator
run-emulator: ##DEVICE## Run app on emulator with interactive selection
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Starting $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_BLUE) emulator and running app...$(FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR; \
	echo "$(COLOR_GREEN)$(ICON_CHECK) Emulator $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_GREEN) started! Running app...$(FORMAT_RESET)"; \
	make run-debug

# =============================================================================
# MAINTENANCE
# =============================================================================

.PHONY: doctor
doctor: ##MAINTENANCE## Check flutter environment
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Checking Flutter environment...$(FORMAT_RESET)"
	@flutter doctor

.PHONY: pub-get
pub-get: ##MAINTENANCE## Get dependencies
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Getting dependencies...$(FORMAT_RESET)"
	@flutter pub get

.PHONY: pub-outdated
pub-outdated: ##MAINTENANCE## Check outdated packages
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Checking for outdated packages...$(FORMAT_RESET)"
	@flutter pub outdated

.PHONY: pub-upgrade
pub-upgrade: ##MAINTENANCE## Upgrade dependencies
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_UPGRADE) Upgrading dependencies...$(FORMAT_RESET)"
	@flutter pub upgrade

.PHONY: sdk-upgrade
sdk-upgrade: ##MAINTENANCE## Upgrade Flutter SDK
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_UPGRADE) Upgrading Flutter SDK...$(FORMAT_RESET)"
	@flutter upgrade

# =============================================================================
# UTILITIES
# =============================================================================

.PHONY: gen-l10n
gen-l10n: ##UTILITIES## Generate l10n files
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Generating localization files...$(FORMAT_RESET)"
	@flutter gen-l10n

.PHONY: gen-assets
gen-assets: gen-png-logos gen-icons gen-splash ##UTILITIES## Generate PNG files, app icons and splash screen

.PHONY: gen-png-logos
# SVG generation variables
SVG_SOURCE = assets/svg/logo-rgb.svg

gen-png-logos: ##UTILITIES## Generate PNG variants from JSON configuration
	@if [ ! -f "$(SVG_SOURCE).json" ]; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: $(SVG_SOURCE).json not found$(FORMAT_RESET)"; \
		exit 1; \
	fi; \
	if [ ! -f "$(SVG_SOURCE)" ]; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: $(SVG_SOURCE) not found$(FORMAT_RESET)"; \
		exit 1; \
	fi; \
	echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Generating PNG variants from $(SVG_SOURCE)...$(FORMAT_RESET)"; \
	if ! command -v rsvg-convert >/dev/null 2>&1; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: rsvg-convert not found$(FORMAT_RESET)"; \
		echo "   Please install librsvg2-bin package:"; \
		echo "   - Ubuntu/Debian: sudo apt-get install librsvg2-bin"; \
		echo "   - macOS: brew install librsvg"; \
		echo "   - Windows: Download from https://github.com/miyako/console-rsvg-convert"; \
		exit 1; \
	fi; \
	if ! command -v jq >/dev/null 2>&1; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: jq not found$(FORMAT_RESET)"; \
		echo "   Please install jq:"; \
		echo "   - Ubuntu/Debian: sudo apt-get install jq"; \
		echo "   - macOS: brew install jq"; \
		echo "   - Windows: Download from https://jqlang.github.io/jq/download/"; \
		exit 1; \
	fi
	@echo "$(COLOR_CYAN)Generating temporary SVG variants from JSON config...$(FORMAT_RESET)"; \
	jq -r '.icons[] | @base64' "$(SVG_SOURCE).json" | while read -r icon_data; do \
		name=$$(echo "$$icon_data" | base64 -d | jq -r '.name'); \
		display_name=$$(echo "$$icon_data" | base64 -d | jq -r '.display_name'); \
		width=$$(echo "$$icon_data" | base64 -d | jq -r '.width'); \
		height=$$(echo "$$icon_data" | base64 -d | jq -r '.height'); \
		translate_x=$$(echo "$$icon_data" | base64 -d | jq -r '.translate_x'); \
		translate_y=$$(echo "$$icon_data" | base64 -d | jq -r '.translate_y'); \
		scale=$$(echo "$$icon_data" | base64 -d | jq -r '.scale'); \
		echo "$(COLOR_CYAN)Generating $$display_name (x=$$translate_x, y=$$translate_y, scale=$$scale)...$(FORMAT_RESET)"; \
		SED_CMD="s|width=\"1500\" height=\"1500\"|width=\"$$width\" height=\"$$height\"|g; s|translate(0 0)scale(1)|translate($$translate_x $$translate_y)scale($$scale)|g"; \
		COLOR_RULES=$$(echo "$$icon_data" | base64 -d | jq -r '.colors | to_entries[] | "s|class=\\\"" + .key + "\\\" fill=\\\"[^\\\"]*\\\"|fill=\\\"" + .value + "\\\"|g"' | tr '\n' ';'); \
		SED_CMD="$$SED_CMD; $$COLOR_RULES"; \
		svg_temp=$$(dirname $(SVG_SOURCE))/temp-$$name.svg; \
		sed -e "$$SED_CMD" "$(SVG_SOURCE)" > "$$svg_temp"; \
		echo "$(COLOR_CYAN)Converting $$display_name to PNG ($$width x $$height)...$(FORMAT_RESET)"; \
		rsvg-convert -h $$height -w $$width "$$svg_temp" -o "assets/png/logo-$$name.png"; \
		rm -f "$$svg_temp"; \
	done; \
	echo "$(COLOR_GREEN)$(ICON_CHECK) All icons generated$(FORMAT_RESET)"

.PHONY: gen-icons
gen-icons: ##UTILITIES## Generate app icons
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Generating app icons...$(FORMAT_RESET)"
	@flutter packages pub run flutter_launcher_icons

.PHONY: gen-splash
gen-splash: ##UTILITIES## Generate splash screen
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Generating splash screen...$(FORMAT_RESET)"
	@flutter packages pub run flutter_native_splash:create

# =============================================================================
# GIT HOOKS MANAGEMENT
# =============================================================================

.PHONY: install-pre-commit-hook
install-pre-commit-hook: ##UTILITIES## Install pre-commit hook for automatic version incrementing
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Installing pre-commit hook...$(FORMAT_RESET)"
	@if [ ! -d ".git" ]; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: Not in a git repository$(FORMAT_RESET)"; \
		echo "   Please run this command from the root of your git repository"; \
		exit 1; \
	fi
	@if [ ! -d ".git/hooks" ]; then \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: .git/hooks directory not found$(FORMAT_RESET)"; \
		exit 1; \
	fi
	@if [ -f ".git/hooks/pre-commit" ]; then \
		echo "$(COLOR_YELLOW)$(ICON_WARN) Pre-commit hook already exists, backing up...$(FORMAT_RESET)"; \
		cp .git/hooks/pre-commit .git/hooks/pre-commit.backup; \
	fi
	@if [ -f "scripts/pre-commit" ]; then \
		cp scripts/pre-commit .git/hooks/pre-commit; \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook copied from scripts/$(FORMAT_RESET)"; \
	elif [ -f ".git/hooks/pre-commit" ]; then \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook already in place$(FORMAT_RESET)"; \
	else \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: Pre-commit hook not found in scripts/$(FORMAT_RESET)"; \
		exit 1; \
	fi
	@chmod +x .git/hooks/pre-commit
	@if [ -x ".git/hooks/pre-commit" ]; then \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook installed successfully!$(FORMAT_RESET)"; \
		echo "$(COLOR_CYAN)$(ICON_INFO) Hook will now automatically increment minor version before each commit$(FORMAT_RESET)"; \
		echo ""; \
		echo "$(COLOR_YELLOW)$(ICON_INFO) To test:$(FORMAT_RESET)"; \
		echo "   1. Make some changes to your code"; \
		echo "   2. git add ."; \
		echo "   3. git commit -m 'test commit'"; \
		echo "   4. Check pubspec.yaml for version increment"; \
		echo ""; \
		echo "$(COLOR_CYAN)$(ICON_INFO) To disable temporarily: git commit --no-verify$(FORMAT_RESET)"; \
		echo "$(COLOR_CYAN)$(ICON_INFO) To remove permanently: make remove-pre-commit-hook$(FORMAT_RESET)"; \
	else \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: Failed to make pre-commit hook executable$(FORMAT_RESET)"; \
		exit 1; \
	fi

.PHONY: remove-pre-commit-hook
remove-pre-commit-hook: ##UTILITIES## Remove pre-commit hook
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Removing pre-commit hook...$(FORMAT_RESET)"
	@if [ -f ".git/hooks/pre-commit" ]; then \
		rm .git/hooks/pre-commit; \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook removed$(FORMAT_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)$(ICON_WARN) No pre-commit hook found$(FORMAT_RESET)"; \
	fi
