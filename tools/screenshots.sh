#!/usr/bin/env bash
set -euo pipefail

# Capture screenshot sets for the app across locales, themes, and screens.
# Writes under fastlane/metadata/android/<locale>/images/{phone|seven|ten}InchScreenshots/
# (Play / F-Droid). Configuration: tools/screenshots.json.
#
# Usage: screenshots.sh [--device-id ID] [--device-name NAME] [--screen SCREEN]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/screenshots.json"

# ─── Colors & Icons ──────────────────────────────────────────────────────────

C_GREEN='\033[32m'  C_BLUE='\033[34m'   C_YELLOW='\033[33m'
C_RED='\033[31m'    C_CYAN='\033[36m'
BOLD='\033[1m'      HIGHLIGHT='\033[7m'  RST='\033[0m'
ICO_OK='✓' ICO_ERR='✗' ICO_INFO='ℹ' ICO_BUILD='🔨'

# ─── Arguments ───────────────────────────────────────────────────────────────

DEVICE_ID="" DEVICE_NAME="" SCREEN_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device-id)   DEVICE_ID="$2";    shift 2 ;;
    --device-name) DEVICE_NAME="$2";  shift 2 ;;
    --screen)      SCREEN_FILTER="$2"; shift 2 ;;
    *) echo -e "${C_RED}${ICO_ERR} Unknown argument: $1${RST}"; exit 1 ;;
  esac
done

# ─── Validate ────────────────────────────────────────────────────────────────

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo -e "${C_RED}${ICO_ERR} Config not found: $CONFIG_PATH${RST}"; exit 1
fi

for tool in jq adb; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo -e "${C_RED}${ICO_ERR} Required tool not found: $tool${RST}"; exit 1
  fi
done

# ─── Read Config ─────────────────────────────────────────────────────────────

if ! jq -e '.locale_map | type == "object" and length > 0' "$CONFIG_PATH" >/dev/null 2>&1; then
  echo -e "${C_RED}${ICO_ERR} screenshots.json: locale_map must be a non-empty object${RST}"; exit 1
fi

METADATA_ROOT=$(jq -r '.fastlane_metadata_root // "fastlane/metadata/android"' "$CONFIG_PATH")
FILE_PREFIX=$(jq -r '.file_prefix' "$CONFIG_PATH")

APP_LOCALES=()
while IFS= read -r v; do APP_LOCALES+=("$v"); done < <(jq -r '.locale_map | keys[]' "$CONFIG_PATH")
THEMES=()
while IFS= read -r v; do THEMES+=("$v"); done < <(jq -r '.themes[]' "$CONFIG_PATH")

DELAY_SHORT=$(jq -r '.delays.short' "$CONFIG_PATH")
DELAY_ANIM=$(jq -r '.delays.animation' "$CONFIG_PATH")
DELAY_REBUILD=$(jq -r '.delays.rebuild' "$CONFIG_PATH")

ADB_ACTION=$(jq -r '.adb.action' "$CONFIG_PATH")
DEMO_ACTION=$(jq -r '.adb.demo_action' "$CONFIG_PATH")

SCREEN_COUNT=$(jq '.screens | length' "$CONFIG_PATH")
ALL_SCREEN_NAMES=()
while IFS= read -r v; do ALL_SCREEN_NAMES+=("$v"); done < <(jq -r '.screens[].name' "$CONFIG_PATH")

# Fastlane directory (BCP-47) for an app locale key from locale_map.
fastlane_locale_dir() {
  jq -r --arg l "$1" '(.locale_map[$l] // $l)' "$CONFIG_PATH"
}

# ─── Device Selection ────────────────────────────────────────────────────────

if [[ -z "$DEVICE_ID" ]]; then
  DEVICES=()
  while IFS= read -r d; do DEVICES+=("$d"); done \
    < <(adb devices | grep -E '^[^[:space:]]+\s+device$' | awk '{print $1}')

  if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo -e "${C_RED}${ICO_ERR} No devices found!${RST}"; exit 1
  fi

  echo -e "${C_CYAN}${ICO_INFO} Select device (ID):${RST}"
  select DEVICE_ID in "${DEVICES[@]}"; do
    if [[ -n "$DEVICE_ID" ]]; then break; fi
    echo -e "${C_RED}${ICO_ERR} Invalid selection${RST}"
  done
fi

if [[ -z "$DEVICE_NAME" ]]; then
  DEVICE_NAME="$DEVICE_ID"
fi

# Play / Fastlane: phone vs tablet buckets (by capture device label)
IMAGE_SUBDIR="phoneScreenshots"
case "$DEVICE_NAME" in
  *tablet10*) IMAGE_SUBDIR="tenInchScreenshots" ;;
  *tablet7*)  IMAGE_SUBDIR="sevenInchScreenshots" ;;
esac

echo -e "${C_BLUE}${ICO_INFO} Device: ${BOLD}$DEVICE_ID${RST}"
echo -e "${C_BLUE}${ICO_INFO} Device name for files: ${BOLD}$DEVICE_NAME${RST}"
echo -e "${C_BLUE}${ICO_INFO} Fastlane image folder: ${BOLD}$IMAGE_SUBDIR${RST}"

for lang in "${APP_LOCALES[@]}"; do
  loc=$(fastlane_locale_dir "$lang")
  mkdir -p "$PROJECT_DIR/$METADATA_ROOT/$loc/images/$IMAGE_SUBDIR"
done

# ─── Helpers ─────────────────────────────────────────────────────────────────

adb_cmd() { adb -s "$DEVICE_ID" "$@"; }
broadcast() { adb_cmd shell am broadcast -a "$@" > /dev/null 2>&1 || true; }

send_app_cmd() {
  local cmd_name="$1"; shift
  local args=( --es cmd "$cmd_name" )
  for kv in "$@"; do
    args+=( --es "${kv%%=*}" "${kv#*=}" )
  done
  broadcast "$ADB_ACTION" "${args[@]}"
}

# Execute a single action string: cmd:NAME key=val | key:KEYCODE | wait:SECONDS
# $2 = style: "inline" prints on same line, "block" prints on own line
run_action() {
  local action="$1" style="${2:-inline}"
  local type="${action%%:*}" rest="${action#*:}"

  case "$type" in
    cmd)
      local parts=($rest)
      local cmd_name="${parts[0]}"
      if [[ "$style" == "block" ]]; then
        printf "  ${C_CYAN}%s${RST}" "$cmd_name"
      else
        printf ", ${C_CYAN}%s${RST}" "$cmd_name"
      fi
      send_app_cmd "${parts[@]}"
      printf " [${C_GREEN}${ICO_OK}${RST}]"
      [[ "$style" == "block" ]] && printf "\n"
      sleep "$DELAY_ANIM"
      ;;
    key)
      if [[ "$style" == "block" ]]; then
        echo -e "  going back..."
      fi
      adb_cmd shell input keyevent "$rest" > /dev/null 2>&1
      sleep "$DELAY_ANIM"
      ;;
    wait)
      sleep "$rest"
      ;;
  esac
}

# Execute all actions for a screen hook (before_screen, before_capture, etc.)
run_hook() {
  local screen_idx="$1" hook="$2" style="${3:-inline}"
  local count
  count=$(jq --argjson i "$screen_idx" --arg h "$hook" \
    '(.screens[$i][$h] // []) | length' "$CONFIG_PATH")
  for ((a=0; a<count; a++)); do
    local action
    action=$(jq -r --argjson i "$screen_idx" --arg h "$hook" --argjson a "$a" \
      '.screens[$i][$h][$a]' "$CONFIG_PATH")
    run_action "$action" "$style"
  done
}

# ─── Cleanup ─────────────────────────────────────────────────────────────────

cleanup() {
  echo ""
  echo -e "${C_CYAN}${ICO_INFO} Restoring device settings...${RST}"
  broadcast "$DEMO_ACTION" -e command exit
  send_app_cmd closeDrawer
  echo -e "${C_GREEN}${ICO_OK} Demo mode disabled${RST}"
}
trap cleanup EXIT

# ─── Enable Demo Mode ────────────────────────────────────────────────────────

echo -e "${HIGHLIGHT}${ICO_BUILD} Screenshots → ${METADATA_ROOT}/<locale>/images/${IMAGE_SUBDIR}/${FILE_PREFIX}-${DEVICE_NAME}-<mode>-<index>-<screen>.png${RST}"
echo ""
echo -e "${C_CYAN}${ICO_INFO} Automated screens are switched via ADB${RST}"
echo -e "${C_YELLOW}${ICO_INFO} Manual screens will prompt you to prepare the app${RST}"
echo ""

echo -e "${C_CYAN}${ICO_INFO} Enabling demo mode (clean status bar)...${RST}"

DEMO_CLOCK=$(jq -r '.demo_mode.clock' "$CONFIG_PATH")
DEMO_BATTERY=$(jq -r '.demo_mode.battery_level' "$CONFIG_PATH")
DEMO_WIFI=$(jq -r '.demo_mode.wifi_level' "$CONFIG_PATH")
DEMO_MOBILE=$(jq -r '.demo_mode.mobile_level' "$CONFIG_PATH")

adb_cmd shell settings put global sysui_demo_allowed 1 > /dev/null 2>&1
broadcast "$DEMO_ACTION" -e command enter
broadcast "$DEMO_ACTION" -e command clock -e hhmm "$DEMO_CLOCK"
broadcast "$DEMO_ACTION" -e command battery -e level "$DEMO_BATTERY" -e plugged false
broadcast "$DEMO_ACTION" -e command network -e wifi show -e level "$DEMO_WIFI"
broadcast "$DEMO_ACTION" -e command network -e mobile show -e datatype none -e level "$DEMO_MOBILE"
broadcast "$DEMO_ACTION" -e command notifications -e visible false

echo -e "${C_GREEN}${ICO_OK} Demo mode enabled (${DEMO_CLOCK}, battery ${DEMO_BATTERY}%, full signal, no notifications)${RST}"
echo ""

# ─── Main Loop ───────────────────────────────────────────────────────────────

for ((si=0; si<SCREEN_COUNT; si++)); do
  screen_name="${ALL_SCREEN_NAMES[$si]}"

  if [[ -n "$SCREEN_FILTER" && "$screen_name" != "$SCREEN_FILTER" ]]; then
    continue
  fi

  is_auto=$(jq -r --argjson i "$si" '.screens[$i].auto' "$CONFIG_PATH")
  file_index=$((si + 1))

  printf "====================================\n"
  printf "${C_BLUE}Set ${BOLD}%s${RST}${C_BLUE} screen${RST}" "$screen_name"

  for lang in "${APP_LOCALES[@]}"; do
    loc=$(fastlane_locale_dir "$lang")
    od="$PROJECT_DIR/$METADATA_ROOT/$loc/images/$IMAGE_SUBDIR"
    rm -f "$od/${FILE_PREFIX}-${DEVICE_NAME}-"*"-${file_index}-${screen_name}.png" 2>/dev/null || true
  done

  # ── before_screen ──
  run_hook "$si" "before_screen" "inline"
  printf "\n"

  for lang in "${APP_LOCALES[@]}"; do
    printf "  ${C_CYAN}using ${BOLD}%s${RST}${C_CYAN} screen${RST}" "$screen_name"
    printf ", ${C_BLUE}set ${BOLD}%s${RST}${C_BLUE} lang" "$lang"
    send_app_cmd setLocale "lang=$lang"
    printf " [${C_GREEN}${ICO_OK}${RST}]"
    sleep "$DELAY_REBUILD"

    # Manual prompt
    if [[ "$is_auto" != "true" ]]; then
      printf ", ${C_YELLOW}prepare screen on device and press Enter...${RST}"
      read -r _
    fi
    printf "\n"

    for mode in "${THEMES[@]}"; do
      printf "  ${C_CYAN}using ${BOLD}%s${RST}${C_CYAN} screen${RST}" "$screen_name"
      printf ", ${C_CYAN}using ${BOLD}%s${RST}${C_CYAN} lang${RST}" "$lang"
      printf ", ${C_BLUE}set ${BOLD}%s${RST}${C_BLUE} theme${RST}" "$mode"
      send_app_cmd setThemeMode "mode=$mode"
      printf " [${C_GREEN}${ICO_OK}${RST}]"
      sleep "$DELAY_REBUILD"

      # ── before_capture ──
      run_hook "$si" "before_capture" "inline"

      loc=$(fastlane_locale_dir "$lang")
      out_dir="$PROJECT_DIR/$METADATA_ROOT/$loc/images/$IMAGE_SUBDIR"
      local_file="$out_dir/${FILE_PREFIX}-${DEVICE_NAME}-${mode}-${file_index}-${screen_name}.png"
      printf ", taking screenshot [ ]"
      if adb_cmd exec-out screencap -p > "$local_file"; then
        printf "\b\b\b[${C_GREEN}${ICO_OK}${RST}]\n"
      else
        printf "\b\b\b[${C_RED}${ICO_ERR}${RST}]\n"
      fi
      sleep "$DELAY_SHORT"

      # ── after_capture ──
      run_hook "$si" "after_capture" "block"
    done

    # ── after_lang ──
    run_hook "$si" "after_lang" "block"
  done

  # ── after_screen ──
  run_hook "$si" "after_screen" "block"
done

echo ""
echo -e "${C_GREEN}${ICO_OK} Screenshots saved under ${METADATA_ROOT}/*/images/${IMAGE_SUBDIR}/${RST}"
