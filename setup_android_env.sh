#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DEFAULT_AVD_NAME="cursor_pixel_api_30_atd"
DEFAULT_SYSTEM_IMAGE="system-images;android-30;google_atd;x86_64"
DEFAULT_DEVICE_PROFILE="pixel"

log() {
  printf '[setup_android_env] %s\n' "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing command: $1"
    exit 1
  fi
}

find_android_sdk() {
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "${ANDROID_SDK_ROOT}" ]]; then
    echo "${ANDROID_SDK_ROOT}"
    return
  fi
  if [[ -n "${ANDROID_HOME:-}" && -d "${ANDROID_HOME}" ]]; then
    echo "${ANDROID_HOME}"
    return
  fi
  local candidates=(
    "$HOME/Android/Sdk"
    "$HOME/android-sdk"
    "/opt/android-sdk"
    "/usr/lib/android-sdk"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

find_java17_home() {
  local candidates=(
    "/usr/lib/jvm/java-17-openjdk-amd64"
    "/usr/lib/jvm/java-17-openjdk"
    "$HOME/.jdks/temurin-17"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

find_flutter_bin() {
  local candidates=(
    "$HOME/flutter-sdk/bin"
    "$HOME/.flutter/bin"
    "$ROOT_DIR/.flutter/bin"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate/flutter" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

avd_exists() {
  local avd_name="$1"
  emulator -list-avds | awk -v avd="$avd_name" '$0==avd{found=1} END{exit !found}'
}

ensure_avd_config() {
  local avd_name="$1"
  local avd_config="$HOME/.android/avd/${avd_name}.avd/config.ini"
  if [[ ! -f "$avd_config" ]]; then
    return
  fi
  if ! rg -q '^hw.keyboard=yes$' "$avd_config"; then
    printf '\nhw.keyboard=yes\n' >>"$avd_config"
  fi
}

AVD_NAME="${DEFAULT_AVD_NAME}"
SYSTEM_IMAGE="${DEFAULT_SYSTEM_IMAGE}"
DEVICE_PROFILE="${DEFAULT_DEVICE_PROFILE}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --avd-name)
      AVD_NAME="$2"
      shift 2
      ;;
    --system-image)
      SYSTEM_IMAGE="$2"
      shift 2
      ;;
    --device-profile)
      DEVICE_PROFILE="$2"
      shift 2
      ;;
    *)
      log "Unknown argument: $1"
      exit 1
      ;;
  esac
done

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$(find_android_sdk)}"
if [[ -z "$ANDROID_SDK_ROOT" ]]; then
  log "Android SDK not found. Install SDK first."
  exit 1
fi

export ANDROID_SDK_ROOT
export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

JAVA_17_HOME="$(find_java17_home)"
if [[ -n "$JAVA_17_HOME" ]]; then
  export JAVA_HOME="$JAVA_17_HOME"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if ! command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN_DIR="$(find_flutter_bin)"
  if [[ -n "$FLUTTER_BIN_DIR" ]]; then
    export PATH="$FLUTTER_BIN_DIR:$PATH"
  fi
fi

require_cmd sdkmanager
require_cmd avdmanager
require_cmd emulator
require_cmd adb
require_cmd flutter

log "Accepting Android SDK licenses..."
yes | sdkmanager --licenses >/tmp/android-sdk-licenses.log 2>&1 || true

log "Ensuring required Android SDK packages..."
sdkmanager --install \
  "platform-tools" \
  "emulator" \
  "platforms;android-35" \
  "build-tools;35.0.0" \
  "$SYSTEM_IMAGE"

if avd_exists "$AVD_NAME"; then
  log "AVD already exists: $AVD_NAME"
else
  log "Creating AVD: $AVD_NAME"
  echo "no" | avdmanager create avd \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE" \
    --device "$DEVICE_PROFILE" \
    --force
fi

ensure_avd_config "$AVD_NAME"
adb start-server >/dev/null

log "Android environment is ready."
log "Default AVD: $AVD_NAME"
log "Run app with: ./run_android_stable.sh"
