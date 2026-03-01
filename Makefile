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
	@flutter build apk --debug --build-number=$$(($(date +%s)/1000))

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

# Screenshots: DEVICE_ID=adb_id DEVICE_NAME=pixel9|tablet10 SCREEN=main (name for filenames)
SCREENSHOTS_DIR := assets/screenshots
SCREENSHOTS_LANGS := en pl
SCREENSHOTS_MODES := light dark
SCREENSHOTS_SCREENS := main drawer drawer-recording drawer-tracks drawer-screen drawer-danger navigation-menu row-menu details-empty recording details-recording details-overview details-controls details-info
SCREEN :=
SCREENSHOTS_SCREENS_RESOLVED := $(if $(SCREEN),$(SCREEN),$(SCREENSHOTS_SCREENS))
SCREENSHOT_ACTION := pro.kwiatek.tune_tangler.SCREENSHOT_CMD
SCREENSHOT_DEMO_ACTION := com.android.systemui.demo
SCREENSHOT_DELAY_SHORT := 0.3
SCREENSHOT_DELAY_ANIM := 0.8
SCREENSHOT_DELAY_REBUILD := 1.0

.PHONY: screenshots
screenshots: ##DEVICE## Capture screenshot set (`DEVICE_ID=` DEVICE_NAME= SCREEN= optional)
	@device_id="$(DEVICE_ID)"; device_name="$(DEVICE_NAME)"; \
	mkdir -p $(SCREENSHOTS_DIR); \
	if [ -z "$$device_id" ]; then \
		DEVICES=($$(adb devices | grep -E "^[^[:space:]]+[[:space:]]+device" | awk '{print $$1}')); \
		if [ "$${#DEVICES[@]}" -eq 0 ]; then \
			echo "$(COLOR_RED)$(ICON_ERROR) No devices found!$(FORMAT_RESET)"; exit 1; \
		fi; \
		echo "$(COLOR_CYAN)$(ICON_INFO) Select device (ID):$(FORMAT_RESET)"; \
		select device_id in "$${DEVICES[@]}"; do \
			if [ -n "$$device_id" ]; then break; fi; \
			echo "$(COLOR_RED)$(ICON_ERROR) Invalid selection$(FORMAT_RESET)"; \
		done; \
		echo "$(COLOR_BLUE)$(ICON_INFO) Device: $(FORMAT_BOLD)$$device_id$(FORMAT_RESET)$(COLOR_BLUE)$(FORMAT_RESET)"; \
	fi; \
	if [ -z "$$device_name" ]; then device_name="$$device_id"; fi; \
	echo "$(COLOR_BLUE)$(ICON_INFO) Device name for files: $(FORMAT_BOLD)$$device_name$(FORMAT_RESET)$(COLOR_BLUE)$(FORMAT_RESET)"; \
	echo "$(FORMAT_HIGHLIGHT)$(ICON_BUILD) Screenshots → $(SCREENSHOTS_DIR)/tune-tangler-$$device_name-<lang>-<mode>-<index>-<screen>.png$(FORMAT_RESET)"; \
	echo ""; \
	echo "$(COLOR_CYAN)$(ICON_INFO) Automated screens: $(FORMAT_BOLD)main, drawer*$(FORMAT_RESET)$(COLOR_CYAN) (language & theme switched via ADB)$(FORMAT_RESET)"; \
	echo "$(COLOR_YELLOW)$(ICON_INFO) Manual screens will prompt you to prepare the app$(FORMAT_RESET)"; \
	echo ""; \
	cleanup() { \
		echo ""; \
		echo "$(COLOR_CYAN)$(ICON_INFO) Restoring device settings...$(FORMAT_RESET)"; \
		adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command exit > /dev/null 2>&1; \
		adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd closeDrawer > /dev/null 2>&1; \
		echo "$(COLOR_GREEN)$(ICON_CHECK) Demo mode disabled$(FORMAT_RESET)"; \
	}; \
	trap cleanup EXIT; \
	echo "$(COLOR_CYAN)$(ICON_INFO) Enabling demo mode (clean status bar)...$(FORMAT_RESET)"; \
	adb -s "$$device_id" shell settings put global sysui_demo_allowed 1 > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command enter > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command clock -e hhmm 1200 > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command battery -e level 100 -e plugged false > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command network -e wifi show -e level 4 > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command network -e mobile show -e datatype none -e level 4 > /dev/null 2>&1; \
	adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_DEMO_ACTION) -e command notifications -e visible false > /dev/null 2>&1; \
	echo "$(COLOR_GREEN)$(ICON_CHECK) Demo mode enabled (12:00, full battery, full signal, no notifications)$(FORMAT_RESET)"; \
	echo ""; \
	all_screens=($(SCREENSHOTS_SCREENS)); \
	screens=($(SCREENSHOTS_SCREENS_RESOLVED)); \
	for screen in "$${screens[@]}"; do \
		printf "====================================\n$(COLOR_BLUE)Set $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_BLUE) screen$(FORMAT_RESET)" "$$screen"; \
		rm -f $(SCREENSHOTS_DIR)/tune-tangler-$$device_name-*-$$screen.png 2>/dev/null; \
		case "$$screen" in \
			main|navigation-menu) \
			  	printf ", $(COLOR_CYAN)close drawer$(FORMAT_RESET)"; \
				adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd closeDrawer > /dev/null 2>&1; \
				printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
				sleep $(SCREENSHOT_DELAY_ANIM); \
				;; \
			drawer*) \
			  	printf ", $(COLOR_CYAN)close drawer$(FORMAT_RESET)"; \
				adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd closeDrawer > /dev/null 2>&1; \
				printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
				sleep $(SCREENSHOT_DELAY_ANIM); \
			  	printf ", $(COLOR_CYAN)open drawer$(FORMAT_RESET)"; \
				adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd openDrawer > /dev/null 2>&1; \
				printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
				sleep $(SCREENSHOT_DELAY_ANIM); \
				;; \
		esac; \
		printf "\n"; \
		for lang in $(SCREENSHOTS_LANGS); do \
			printf "  $(COLOR_CYAN)using $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_CYAN) screen$(FORMAT_RESET), $(COLOR_BLUE)set $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_BLUE) lang" "$$screen" "$$lang"; \
			adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd setLocale --es lang "$$lang" > /dev/null 2>&1; \
			printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
			sleep $(SCREENSHOT_DELAY_REBUILD); \
			case "$$screen" in \
				main|navigation-menu) \
				;; \
				drawer*) \
				;; \
				*) \
					printf ", $(COLOR_YELLOW)prepare screen on device and press Enter...$(FORMAT_RESET)"; read _; \
				;; \
			esac; \
			printf "\n"; \
			for mode in $(SCREENSHOTS_MODES); do \
				printf "  $(COLOR_CYAN)using $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_CYAN) screen$(FORMAT_RESET), $(COLOR_CYAN)using $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_CYAN) lang$(FORMAT_RESET), $(COLOR_BLUE)set $(FORMAT_BOLD)%s$(FORMAT_RESET)$(COLOR_BLUE) theme$(FORMAT_RESET)" "$$screen" "$$lang" "$$mode"; \
				adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd setThemeMode --es mode "$$mode" > /dev/null 2>&1; \
				printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
				sleep $(SCREENSHOT_DELAY_REBUILD); \
				case "$$screen" in \
					drawer-*) \
					  	section="$${screen#drawer-}"; \
						printf ", $(COLOR_CYAN)expand drawer section$(FORMAT_RESET)"; \
						adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd expandDrawerSection --es section "$$section" > /dev/null 2>&1; \
						printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
						sleep $(SCREENSHOT_DELAY_ANIM); \
						sleep $(SCREENSHOT_DELAY_ANIM); \
						sleep $(SCREENSHOT_DELAY_ANIM); \
						;; \
					navigation-menu) \
						printf ", $(COLOR_CYAN)open nav menu$(FORMAT_RESET)"; \
						adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd openNavigationMenu > /dev/null 2>&1; \
						printf " [$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]"; \
						sleep $(SCREENSHOT_DELAY_ANIM); \
						;; \
				esac; \
				file_index=0; for _i in $${!all_screens[@]}; do if [ "$${all_screens[$$_i]}" = "$$screen" ]; then file_index=$$((_i + 1)); break; fi; done; \
				file="$(SCREENSHOTS_DIR)/tune-tangler-$$device_name-$$lang-$$mode-$$file_index-$$screen.png"; \
				printf ", taking screenshot [ ]"; \
				adb -s "$$device_id" exec-out screencap -p > "$$file" && printf "\b\b\b[$(COLOR_GREEN)$(ICON_CHECK)$(FORMAT_RESET)]\n" || printf "\b\b\b[$(COLOR_RED)$(ICON_ERROR)$(FORMAT_RESET)]\n"; \
				sleep $(SCREENSHOT_DELAY_SHORT); \
				case "$$screen" in \
					navigation-menu) \
						echo "  going back..."; \
						adb -s "$$device_id" shell input keyevent KEYCODE_BACK > /dev/null 2>&1; \
						sleep $(SCREENSHOT_DELAY_ANIM); \
						;; \
				esac; \
			done; \
			case "$$screen" in \
				row-menu|details*) \
					echo "  going back..."; \
					adb -s "$$device_id" shell input keyevent KEYCODE_BACK; \
					sleep $(SCREENSHOT_DELAY_ANIM); \
				;; \
			esac; \
		done; \
		case "$$screen" in \
			drawer*) \
				adb -s "$$device_id" shell am broadcast -a $(SCREENSHOT_ACTION) --es cmd closeDrawer > /dev/null 2>&1; \
				sleep $(SCREENSHOT_DELAY_ANIM); \
				;; \
		esac; \
	done; \
	echo ""; \
	echo "$(COLOR_GREEN)$(ICON_CHECK) Screenshots saved to $(SCREENSHOTS_DIR)/$(FORMAT_RESET)"

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
