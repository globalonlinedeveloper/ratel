#!/usr/bin/env bash
# Android APK smoke test — runs on a real emulator in CI.
# Asserts the shipped release APK: has network permission (regression guard
# for the INTERNET bug), launches, stays alive, throws no fatal exception,
# and actually renders UI (screenshot must not be a blank frame).
set -euo pipefail
PKG=io.github.globalonlinedeveloper.ratel

echo "== install =="
adb install -r app-release.apk

echo "== INTERNET permission (regression guard) =="
adb shell dumpsys package $PKG | grep -q "android.permission.INTERNET: granted=true" \
  || { echo "FAIL: INTERNET permission missing from the release APK"; exit 1; }

echo "== launch =="
adb logcat -c || true
adb shell am start -W -n $PKG/.MainActivity
sleep 25

echo "== process alive =="
adb shell pidof $PKG >/dev/null \
  || { echo "FAIL: app process died after launch"; adb logcat -d | tail -120; exit 1; }

echo "== no fatal exception =="
if adb logcat -d | grep -q "FATAL EXCEPTION"; then
  echo "FAIL: fatal exception in logcat"
  adb logcat -d | grep -B2 -A30 "FATAL EXCEPTION" | head -80
  exit 1
fi

echo "== render sanity (screenshot must not be blank) =="
adb exec-out screencap -p > android-screen.png
SIZE=$(stat -c%s android-screen.png)
echo "screenshot bytes: $SIZE"
if [ "$SIZE" -lt 60000 ]; then
  echo "FAIL: screenshot is suspiciously small ($SIZE bytes) — likely a blank/solid frame"
  exit 1
fi

echo "ANDROID SMOKE PASS — installed, networked, launched, alive, rendering"
