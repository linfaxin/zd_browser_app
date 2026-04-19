#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

log() {
  printf '[run_android_stable] %s\n' "$*"
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
  for candidate in "${candidates[@]}"; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

has_impeller_flag=false
for arg in "$@"; do
  if [[ "$arg" == "--no-enable-impeller" || "$arg" == "--enable-impeller" ]]; then
    has_impeller_flag=true
    break
  fi
done

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$(find_android_sdk)}"
if [[ -n "$ANDROID_SDK_ROOT" ]]; then
  export ANDROID_SDK_ROOT
  export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
fi

JAVA_17_HOME="$(find_java17_home)"
if [[ -n "$JAVA_17_HOME" ]]; then
  export JAVA_HOME="$JAVA_17_HOME"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

require_cmd flutter
require_cmd adb

running_device="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
if [[ -z "$running_device" ]]; then
  require_cmd emulator
  avd_name="${ANDROID_AVD_NAME:-}"
  if [[ -z "$avd_name" ]]; then
    avd_name="$(emulator -list-avds | awk 'NF {print; exit}')"
  fi
  if [[ -z "$avd_name" ]]; then
    log "No AVD found. Create one or set ANDROID_AVD_NAME."
    exit 1
  fi

  log "Starting emulator: $avd_name"
  emulator_args=(-avd "$avd_name" -no-boot-anim -no-snapshot -netdelay none -netspeed full)
  if [[ -e /dev/kvm && -w /dev/kvm ]]; then
    emulator_args+=(-accel auto)
  else
    emulator_args+=(-accel off -gpu swiftshader_indirect)
  fi
  nohup emulator "${emulator_args[@]}" >/tmp/android-emulator.log 2>&1 &
fi

log "Waiting for device..."
adb wait-for-device >/dev/null

log "Waiting for boot completion..."
for _ in $(seq 1 180); do
  if [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
    break
  fi
  sleep 1
done

device_id="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
if [[ -z "$device_id" ]]; then
  log "Device not ready. Check /tmp/android-emulator.log"
  exit 1
fi

log "Using device: $device_id"
log "Running flutter pub get..."
flutter pub get

flutter_args=(-d "$device_id")
if [[ "$has_impeller_flag" == false ]]; then
  flutter_args+=(--no-enable-impeller)
fi

log "Launching app..."
exec flutter run "${flutter_args[@]}" "$@"
