#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

log() {
  printf '[run_android_stable] %s\n' "$*"
}

avd_process_pids() {
  local avd_name="$1"
  ps -ef | awk -v avd="$avd_name" '
    /qemu-system/ && $0 ~ ("-avd " avd "([[:space:]]|$)") { print $2 }
  '
}

is_avd_process_running() {
  local avd_name="$1"
  [[ -n "$(avd_process_pids "$avd_name")" ]]
}

stop_avd_processes() {
  local avd_name="$1"
  local pids
  pids="$(avd_process_pids "$avd_name" | tr '\n' ' ')"
  if [[ -z "${pids// }" ]]; then
    return
  fi

  log "Stopping stale emulator process(es): $pids"
  local pid
  for pid in $pids; do
    kill "$pid" 2>/dev/null || true
  done

  for _ in $(seq 1 20); do
    local any_alive=false
    for pid in $pids; do
      if kill -0 "$pid" 2>/dev/null; then
        any_alive=true
        break
      fi
    done
    if [[ "$any_alive" == false ]]; then
      break
    fi
    sleep 1
  done

  for pid in $pids; do
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
  done
}

start_emulator_process() {
  local avd_name="$1"
  log "Starting emulator: $avd_name"
  local emulator_args=(-avd "$avd_name" -no-boot-anim -no-snapshot -no-audio -netdelay none -netspeed full)
  if [[ -e /dev/kvm && -w /dev/kvm ]]; then
    emulator_args+=(-accel auto)
  else
    # In no-KVM cloud VMs, headless mode is usually more stable.
    emulator_args+=(-accel off -gpu swiftshader_indirect -no-window)
  fi
  if [[ -z "${DISPLAY:-}" ]]; then
    emulator_args+=(-no-window)
  fi
  nohup emulator "${emulator_args[@]}" >/tmp/android-emulator.log 2>&1 &
}

cleanup_stale_avd_entries() {
  local avd_name="$1"
  local running_dir="$HOME/.android/avd/running"
  if [[ ! -d "$running_dir" ]]; then
    return
  fi

  local pid_file pid pid_running avd_value entry_dir
  for pid_file in "$running_dir"/pid_*.ini; do
    if [[ ! -f "$pid_file" ]]; then
      continue
    fi

    avd_value="$(awk -F= '$1=="avd.name" {print $2}' "$pid_file" | tr -d '\r')"
    if [[ "$avd_value" != "$avd_name" ]]; then
      continue
    fi

    pid="$(basename "$pid_file")"
    pid="${pid#pid_}"
    pid="${pid%.ini}"
    pid_running=false
    if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
      pid_running=true
    fi

    if [[ "$pid_running" == false ]]; then
      log "Removing stale AVD running entry: $(basename "$pid_file")"
      rm -f "$pid_file"
      entry_dir="$running_dir/$pid"
      if [[ -d "$entry_dir" ]]; then
        rm -rf "$entry_dir"
      fi
    fi
  done
}

cleanup_stale_avd_locks() {
  local avd_name="$1"
  local avd_dir="$HOME/.android/avd/${avd_name}.avd"
  if [[ ! -d "$avd_dir" ]]; then
    return
  fi

  local lock_file
  for lock_file in "$avd_dir"/hardware-qemu.ini.lock "$avd_dir"/multiinstance.lock; do
    if [[ -f "$lock_file" ]]; then
      log "Removing stale AVD lock: $(basename "$lock_file")"
      rm -f "$lock_file"
    fi
  done
}

first_connected_device() {
  adb devices | awk 'NR>1 && $2=="device" {print $1; exit}'
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

find_flutter_bin() {
  local candidates=(
    "$HOME/flutter-sdk/bin"
    "$HOME/.flutter/bin"
    "$ROOT_DIR/.flutter/bin"
  )
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate/flutter" ]]; then
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

if ! command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN_DIR="$(find_flutter_bin)"
  if [[ -n "$FLUTTER_BIN_DIR" ]]; then
    export PATH="$FLUTTER_BIN_DIR:$PATH"
  fi
fi

require_cmd flutter
require_cmd adb
adb start-server >/dev/null

running_device="$(first_connected_device)"
started_emulator=false
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

  cleanup_stale_avd_entries "$avd_name"
  if is_avd_process_running "$avd_name"; then
    log "Emulator process already running for AVD: $avd_name"
    for _ in $(seq 1 30); do
      running_device="$(first_connected_device)"
      if [[ -n "$running_device" ]]; then
        break
      fi
      sleep 1
    done
    if [[ -z "$running_device" ]]; then
      log "Existing emulator process is not reachable by adb. Restarting AVD."
      stop_avd_processes "$avd_name"
      cleanup_stale_avd_entries "$avd_name"
      cleanup_stale_avd_locks "$avd_name"
      start_emulator_process "$avd_name"
    fi
  else
    cleanup_stale_avd_locks "$avd_name"
    start_emulator_process "$avd_name"
  fi
  started_emulator=true
fi

log "Waiting for device..."
device_id="$running_device"
for _ in $(seq 1 240); do
  if [[ -z "$device_id" ]]; then
    device_id="$(first_connected_device)"
  fi
  if [[ -n "$device_id" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "$device_id" ]]; then
  log "Device not ready after timeout. Check /tmp/android-emulator.log"
  exit 1
fi

if [[ "$started_emulator" == true ]]; then
  log "Waiting for boot completion..."
  for _ in $(seq 1 240); do
    if [[ "$(adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
      break
    fi
    sleep 1
  done
fi

if [[ "$(adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; then
  log "System boot did not complete in time. Check /tmp/android-emulator.log"
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
log "Command: flutter run ${flutter_args[*]} $*"
exec flutter run "${flutter_args[@]}" "$@"
