#!/usr/bin/env bash
# Prepares Godot's Android export on a CI runner: debug keystore and editor settings.
# ANDROID_DEBUG_KEYSTORE_BASE64 (optional) is a fixed key so every build is signed the same
# way and a newer APK installs over an older one; without it a throwaway key is made.
set -euo pipefail

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
JDK="${JAVA_HOME:-}"
KEYSTORE="$HOME/.android/debug.keystore"

[ -d "$SDK" ] || { echo "Android SDK not found (set ANDROID_HOME)" >&2; exit 1; }
[ -d "$JDK" ] || { echo "JDK not found (set JAVA_HOME)" >&2; exit 1; }

mkdir -p "$HOME/.android"
if [ -n "${ANDROID_DEBUG_KEYSTORE_BASE64:-}" ]; then
  printf '%s' "$ANDROID_DEBUG_KEYSTORE_BASE64" | tr -d '\r\n ' | base64 -d > "$KEYSTORE"
elif [ ! -f "$KEYSTORE" ]; then
  keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android \
    -keystore "$KEYSTORE" -storepass android \
    -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
fi

SETTINGS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/godot"
mkdir -p "$SETTINGS_DIR"
cat > "$SETTINGS_DIR/editor_settings-4.tres" <<SETTINGS
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$SDK"
export/android/java_sdk_path = "$JDK"
export/android/debug_keystore = "$KEYSTORE"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
SETTINGS
