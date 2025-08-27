# TuneTangler Makefile
# Auto-generated help: make help
BUILD_TYPE ?= ""
BUILD_TYPE_SELECTED := false

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
@ICON_QUESTION := ❓
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



VALID_BUILD_TYPES := debug release

# Jeśli drugim "celem" jest build type → ustaw i połknij
ifeq ($(filter $(word 2,$(MAKECMDGOALS)),$(VALID_BUILD_TYPES)),$(word 2,$(MAKECMDGOALS)))
  BUILD_TYPE := $(word 2,$(MAKECMDGOALS))
  $(eval $(word 2,$(MAKECMDGOALS)):;@:)  # dummy target
endif

define choose-build-type
	if [ -z "$$BUILD_TYPE" ]; then \
		echo "$(@COLOR_CYAN)$(@ICON_QUESTION) Choose build type:$(@FORMAT_RESET)"; \
		select BUILD_TYPE in "debug" "release"; do \
			if [ -n "$$BUILD_TYPE" ]; then \
				break; \
			else \
				echo "$(@COLOR_RED)$(@ICON_ERROR) Invalid selection. Please choose a number.$(@FORMAT_RESET)"; \
			fi; \
		done; \
	fi; \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Selected $(@FORMAT_BOLD)$(BUILD_TYPE)$(@FORMAT_RESET)$(@COLOR_BLUE) build type$(@FORMAT_RESET)"
endef

define choose-device
	DEVICES=($$(adb devices | grep -E "^[^[:space:]]+[[:space:]]+device" | awk "{print \$$1}")); \
	if [ $${#DEVICES[@]} -eq 0 ]; then \
		echo "$(@COLOR_RED)$(@ICON_ERROR) No devices found!$(@FORMAT_RESET)"; \
		exit 1; \
	else \
		echo "$(@COLOR_CYAN)$(@ICON_INFO) Select device to install on:$(@FORMAT_RESET)"; \
		select DEVICE in "$${DEVICES[@]}"; do \
			if [ -n "$$DEVICE" ]; then \
				break; \
			else \
				echo "$(@COLOR_RED)$(@ICON_ERROR) Invalid selection. Please choose a number.$(@FORMAT_RESET)"; \
			fi; \
		done; \
	fi;\ 
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Selected $(@FORMAT_BOLD)$$DEVICE$(@FORMAT_RESET)$(@COLOR_BLUE) device$(@FORMAT_RESET)"
endef

define choose-emulator
	if [ -z "$$EMULATOR" ]; then\
		printf "Loading emulators..."; \
		EMULATORS=($$(flutter emulators | grep -E "^[a-zA-Z0-9_-]+[[:space:]]+•" | grep -v "^Id" | awk "{print \$$1}")); \
		printf "\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r"; \
		if [ $${#EMULATORS[@]} -eq 0 ]; then \
			echo "$(@COLOR_RED)$(@ICON_ERROR) No emulators found!$(@FORMAT_RESET)"; \
			exit 1; \
		elif [ $${#EMULATORS[@]} -eq 1 ]; then \
			echo "$(@COLOR_BLUE)$(@ICON_INFO) Only one emulator found, starting $${EMULATORS[0]}...$(@FORMAT_RESET)"; \
			EMULATOR=$${EMULATORS[0]}; \
		else \
			echo "$(@COLOR_CYAN)$(@ICON_INFO) Select emulator to start:$(@FORMAT_RESET)"; \
			select EMULATOR in "$${EMULATORS[@]}"; do \
				if [ -n "$$EMULATOR" ]; then \
					break; \
				else \
					echo "$(@COLOR_RED)$(@ICON_ERROR) Invalid selection. Please choose a number.$(@FORMAT_RESET)"; \
				fi; \
			done; \
		fi; \
	fi; \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Selected $(@FORMAT_BOLD)$$EMULATOR$(@FORMAT_RESET)$(@COLOR_BLUE) emulator$(@FORMAT_RESET)"
endef

.PHONY: help
help: ## Show this help
	@echo "$(@FORMAT_BOLD)$(@COLOR_CYAN)TuneTangler - Available Commands$(@FORMAT_RESET)"
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
	@grep -E '^[a-zA-Z0-9_-%]+.*:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '##DEVICE## ' | awk 'BEGIN {FS = ":.*?##.*?## "}; {printf "$(@COLOR_CYAN)%-25s$(@FORMAT_RESET) %s\n", $$1, $$2}'
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
analyze: ##QA## Run code analysis
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
run: ##BUILD## Run app with argument (debug/release) or interactive selection
	@BUILD_TYPE="$(BUILD_TYPE)"; \
	$(choose-build-type); \
	echo "$(@COLOR_BLUE)$(@ICON_ROCKET) Running app $(@FORMAT_BOLD)$$BUILD_TYPE$(@FORMAT_RESET)$(@COLOR_BLUE) build type...$(@FORMAT_RESET)"; \
	flutter run --$$BUILD_TYPE

.PHONY: run-debug
run-debug: ##BUILD## Run app (debug)
	@make run debug

.PHONY: run-release
run-release: ##BUILD## Run app (release)
	@make run release

.PHONY: increment-build-version
increment-build-version: ##BUILD## Increment build version
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD) Increment build version...$(@FORMAT_RESET)"
	@echo ./scripts/increment_build.sh

.PHONY: build-apk
build-apk: ##BUILD## Build APK with argument (debug/release) or interactive selection
	@BUILD_TYPE="$(BUILD_TYPE)"; \
	$(choose-build-type); \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Building $(@FORMAT_BOLD)$$BUILD_TYPE$(@FORMAT_RESET)$(@COLOR_BLUE) APK...$(@FORMAT_RESET)"; \
	echo flutter build apk --$$BUILD_TYPE; \
	echo "$$(@COLOR_GREEN)$(@ICON_CHECK) APK built successfully!$(@FORMAT_RESET)"

.PHONY: build-apk-debug
build-apk-debug: increment-build-version ##BUILD## Build APK (debug)
	@make build-apk debug

.PHONY: build-apk-release
build-apk-release: increment-build-version ##BUILD## Build APK (release)
	@make build-apk release

#.PHONY: build-ios
#build-ios: ##BUILD## Build iOS (debug)
#	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD) Building iOS (debug)...$(@FORMAT_RESET)"
#	@flutter build ios --debug

.PHONY: install-apk
install-apk: ##BUILD## Build and install APK with argument (debug/release) or interactive selection
	@echo "$(@FORMAT_BOLD)$(@ICON_BUILD) APK Installation$(@FORMAT_RESET)"
	@echo ""
	@DEVICE=$(DEVICE); \
	$(choose-device); \
	BUILD_TYPE="$(BUILD_TYPE)"; \
	$(choose-build-type); \
	make build-apk-$$BUILD_TYPE; \
	echo ""; \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Installing $(@FORMAT_BOLD)$$BUILD_TYPE$(@FORMAT_RESET)$(@COLOR_BLUE) APK on $$DEVICE...$(@FORMAT_RESET)"; \
	if [ "$$BUILD_TYPE" = "debug" ]; then \
		echo adb -s $$DEVICE install -r build/app/outputs/flutter-apk/app-debug.apk; \
	else \
		echo adb -s $$DEVICE install build/app/outputs/flutter-apk/app-release.apk; \
	fi; \
	echo ""; \
	echo "$(@COLOR_GREEN)$(@ICON_CHECK) $(@FORMAT_BOLD)$$BUILD_TYPE$(@FORMAT_RESET)$(@COLOR_GREEN) APK installed on $$DEVICE!$(@FORMAT_RESET)"

.PHONY: install-apk-debug
install-apk-debug: ##BUILD## Build and install APK (debug)
	@make install-apk debug
	
.PHONY: install-apk-release
install-apk-release: ##BUILD## Build and install APK (release)
	@make install-apk release

.PHONY: clean
clean: ##BUILD## Clean build and cache
	@echo "$(@ICON_CLEAN) Cleaning build and cache...$(@FORMAT_RESET)"
	@flutter clean
	@make pub-get

.PHONY: full-build
full-build: clean pub-get analyze build-apk ##BUILD## All-in-one: clean, get dependencies, analyze and build debug
	@echo "$(@COLOR_GREEN)$(@ICON_CHECK) Full build completed!$(@FORMAT_RESET)"

# =============================================================================
# DEVICE MANAGEMENT
# =============================================================================

.PHONY: list-devices
list-devices: ##DEVICE## Show available devices
	@echo "$(@COLOR_GREEN)$(@ICON_DEVICE) Available devices:$(@FORMAT_RESET)"
	@bash -c 'flutter devices | grep -E "^[[:space:]]+[^[:space:]]+.*\\([a-z]+\\)[[:space:]]*•" | sed "s/^[[:space:]]*//"'

.PHONY: list-emulators
list-emulators: ##DEVICE## Show available emulators
	@echo "$(@COLOR_GREEN)$(@ICON_EMULATOR) Available emulators:$(@FORMAT_RESET)"
	@echo "Loading emulators..."
	@bash -c 'flutter emulators | grep -E "^[a-zA-Z0-9_-]+[[:space:]]+•" | grep -v "^Id"'
	@echo "$(@COLOR_CYAN)$(@ICON_INFO) Use make start-emulator to start emulator with selection$(@FORMAT_RESET)"
	@echo "$(@COLOR_CYAN)$(@ICON_INFO) Use make run-emulator to run app on emulator with selection$(@FORMAT_RESET)"

.PHONY: start-emulator
start-emulator: ##DEVICE## Start emulator with interactive selection
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Starting $(@FORMAT_BOLD)$$EMULATOR$(@FORMAT_RESET)$(@COLOR_BLUE) emulator...$(@FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR

.PHONY: run-emulator
run-emulator: ##DEVICE## Run app on emulator with interactive selection
	@EMULATOR=$(EMULATOR); \
	$(choose-emulator); \
	echo "$(@COLOR_BLUE)$(@ICON_INFO) Starting $(@FORMAT_BOLD)$$EMULATOR$(@FORMAT_RESET)$(@COLOR_BLUE) emulator and running app...$(@FORMAT_RESET)"; \
	flutter emulators --launch $$EMULATOR; \
	echo "$(@COLOR_GREEN)$(@ICON_CHECK) Emulator $(@FORMAT_BOLD)$$EMULATOR$(@FORMAT_RESET)$(@COLOR_GREEN) started! Running app...$(@FORMAT_RESET)"; \
	make run-debug

# =============================================================================
# MAINTENANCE
# =============================================================================

.PHONY: doctor
doctor: ##MAINTENANCE## Check flutter environment
	@echo "$(@ICON_INFO) Checking Flutter environment...$(@FORMAT_RESET)"
	@flutter doctor

.PHONY: pub-get
pub-get: ##MAINTENANCE## Get dependencies
	@echo "$(@ICON_INFO) Getting dependencies...$(@FORMAT_RESET)"
	@flutter pub get

.PHONY: pub-outdated
pub-outdated: ##MAINTENANCE## Check outdated packages
	@echo "$(@COLOR_YELLOW)$(@ICON_INFO) Checking for outdated packages...$(@FORMAT_RESET)"
	@flutter pub outdated

.PHONY: pub-upgrade
pub-upgrade: ##MAINTENANCE## Upgrade dependencies
	@echo "$(@ICON_UPGRADE) Upgrading dependencies...$(@FORMAT_RESET)"
	@flutter pub upgrade

.PHONY: sdk-upgrade
sdk-upgrade: ##MAINTENANCE## Upgrade Flutter SDK
	@echo "$(@ICON_UPGRADE) Upgrading Flutter SDK...$(@FORMAT_RESET)"
	@flutter upgrade

# =============================================================================
# UTILITIES
# =============================================================================

.PHONY: gen-l10n
gen-l10n: ##UTILITIES## Generate l10n files
	@echo "$(@ICON_INFO) Generating localization files...$(@FORMAT_RESET)"
	@flutter gen-l10n

.PHONY: gen-icons
gen-icons: ##UTILITIES## Generate app icons
	@echo "$(@ICON_INFO) Generating app icons...$(@FORMAT_RESET)"
	@dart run flutter_launcher_icons

.PHONY: gen-splash
gen-splash: ##UTILITIES## Generate splash screen
	@echo "$(@ICON_INFO) Generating splash screen...$(@FORMAT_RESET)"
	@dart run flutter_native_splash:create

# Git hook commands removed - version incrementing now handled by GitHub workflow

.PHONY: create-tag
create-tag: ##UTILITIES## Create and push version tag
	@echo "$(@COLOR_BLUE)$(@ICON_INFO) Creating version tag...$(@FORMAT_RESET)"
	@if [ -f pubspec.yaml ]; then \
		VERSION=$$(grep '^version:' pubspec.yaml | sed 's/.*version: //' | sed 's/+.*//'); \
		echo "$(@COLOR_CYAN)$(@ICON_INFO) Creating tag v$$VERSION...$(@FORMAT_RESET)"; \
		git tag "v$$VERSION"; \
		git push origin "v$$VERSION"; \
		echo "$(@COLOR_GREEN)$(@ICON_CHECK) Tag $(@FORMAT_BOLD)v$$VERSION$(@FORMAT_RESET)$(@COLOR_GREEN) created and pushed"; \
	else \
		echo "$(@COLOR_RED)$(@ICON_ERROR) pubspec.yaml not found!$(@FORMAT_RESET)"; \
		exit 1; \
	fi

.PHONY: list-tags
list-tags: ##UTILITIES## List all version tags
	@echo "$(@COLOR_BLUE)$(@ICON_INFO) Available version tags:$(@FORMAT_RESET)"
	@git tag --sort=-version:refname | head -10

#.PHONY: rename
#rename: ## Change name
#	@echo "$(@ICON_INFO) Changing app name...$(@FORMAT_RESET)"
#	dart run rename_app:main all="Tune Tangler"
