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

.PHONY: help
help: ##HELP## Display this help screen.
	@echo "$(FORMAT_BOLD)$(COLOR_CYAN)🎵 TuneTangler - Available Commands$(FORMAT_RESET)"
	@group_key=(SETUP DEVICE BUILD QA MAINTENANCE UTILITIES); \
	group_name=("Development Setup" "Device Management" "Run & Build" "Code Quality" "Maintenance" "Utilities"); \
	group_icon=($(ICON_ROCKET) $(ICON_DEVICE) $(ICON_BUILD) $(ICON_TEST) $(ICON_INFO) $(ICON_UPGRADE)); \
	for id in "$${!group_key[@]}"; do \
		key=$${group_key[$$id]}; \
		name=$${group_name[$$id]}; \
		icon=$${group_icon[$$id]}; \
		printf "\n$(FORMAT_BOLD)$(COLOR_BLUE)$$icon $$name$(FORMAT_RESET)\n"; \
		egrep -h '^[a-zA-Z0-9_-]+:.*?##'"$$key"'## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##'"$$key"'## "}; {printf "'$$(tput setaf 6)$$(tput bold)'  %-30s'$$(tput sgr0)' %s\n", $$1, $$2}' | sed -E 's/`([^`]+)`/'$$(tput setaf 7)$$(tput bold)'\1'$$(tput sgr0)'/g'; \
		if [ "$$key" = "BUILD" ]; then \
			printf "$(COLOR_RED)  $(ICON_INFO) Release mode requires GitHub Actions to build and sign the app bundle$(FORMAT_RESET)\n"; \
		fi; \
	done; \
	echo ""

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
run: ##BUILD## Run app in debug mode. Options: `DEVICE=`
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_ROCKET) Running app in $(FORMAT_BOLD)debug$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) build type...$(FORMAT_RESET)"
	@flutter run --debug

.PHONY: build-apk
build-apk: ##BUILD## Build APK in debug mode
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Building $(FORMAT_BOLD)debug$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) APK...$(FORMAT_RESET)"
	@flutter build apk --debug --build-number=$$(($(date +%s)/1000))

.PHONY: build-apk-release
build-apk-release:
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_INFO) Building $(FORMAT_BOLD)release$(FORMAT_RESET)$(FORMAT_HIGHLIGHT) AAB and APK...$(FORMAT_RESET)"; \
	export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true -Dorg.gradle.jvmargs=-Xmx4g"; \
	flutter build apk --split-per-abi; \
  	flutter build appbundle

.PHONY: install-apk
install-apk: ##BUILD## Build and install APK in debug mode. Options: `DEVICE=`
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_BUILD) APK Installation$(FORMAT_RESET)"
	@DEVICE=$(DEVICE); $(choose-device); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Installing $(FORMAT_BOLD)debug$(FORMAT_RESET)$(COLOR_BLUE) APK on $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_BLUE) device...$(FORMAT_RESET)"; \
	adb -s $$DEVICE install -r build/app/outputs/flutter-apk/app-debug.apk; \
	echo "$(COLOR_GREEN)$(ICON_CHECK)APK installed on $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_GREEN) device!$(FORMAT_RESET)"

.PHONY: install-apk-release
install-apk-release:
	@echo "$(FORMAT_HIGHLIGHT)$(ICON_BUILD) APK Installation$(FORMAT_RESET)"
	@DEVICE=$(DEVICE); $(choose-device); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Installing $(FORMAT_BOLD)debug$(FORMAT_RESET)$(COLOR_BLUE) APK on $(FORMAT_BOLD)$$DEVICE$(FORMAT_RESET)$(COLOR_BLUE) device...$(FORMAT_RESET)"; \
	adb -s $$DEVICE install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk; \
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
start-emulator: ##DEVICE## Start emulator. Options: `EMULATOR=`
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Starting $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_BLUE) emulator...$(FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR

.PHONY: run-emulator
run-emulator: ##DEVICE## Run app on emulator. Options: `EMULATOR=`
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(COLOR_BLUE)$(ICON_INFO) Starting $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_BLUE) emulator and running app...$(FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR; \
	echo "$(COLOR_GREEN)$(ICON_CHECK) Emulator $(FORMAT_BOLD)$$EMULATOR$(FORMAT_RESET)$(COLOR_GREEN) started! Running app...$(FORMAT_RESET)"; \
	make run

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
gen-assets: ##UTILITIES## Generate all icons and splash screens from SVG. Requires: `rsvg-convert` `jq` `sips`
	@bash bin/generate-icons.sh

.PHONY: screenshots
screenshots: ##QA## Capture screenshot sets. Options: `DEVICE_ID=` `DEVICE_NAME=` `SCREEN=`
	@bash bin/screenshots.sh \
		$(if $(DEVICE_ID),--device-id "$(DEVICE_ID)") \
		$(if $(DEVICE_NAME),--device-name "$(DEVICE_NAME)") \
		$(if $(SCREEN),--screen "$(SCREEN)")

# =============================================================================
# GIT HOOKS MANAGEMENT
# =============================================================================

.PHONY: install-pre-commit-hook
install-pre-commit-hook: ##UTILITIES## Install pre-commit hook to run flutter analyze
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
	@if [ -f ".githooks/pre-commit" ]; then \
		cp .githooks/pre-commit .git/hooks/pre-commit; \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook copied from .githooks/$(FORMAT_RESET)"; \
	elif [ -f ".git/hooks/pre-commit" ]; then \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook already in place$(FORMAT_RESET)"; \
	else \
		echo "$(COLOR_RED)$(ICON_ERROR) Error: Pre-commit hook not found in .githooks/$(FORMAT_RESET)"; \
		exit 1; \
	fi
	@chmod +x .git/hooks/pre-commit
	@if [ -x ".git/hooks/pre-commit" ]; then \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Pre-commit hook installed successfully!$(FORMAT_RESET)"; \
		echo "$(COLOR_CYAN)$(ICON_INFO) Hook will now run 'flutter analyze' before each commit$(FORMAT_RESET)"; \
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
