#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay
cd "$ROOT"
find Xiaomi/MiPad6Pro Xiaomi/MiPad6Pro-SystemUI -type f -print0 | xargs -0 sed -i 's/\r$//'

TOOLS=$ROOT/ROM/tools
export PATH=$TOOLS/xmlstarlet/usr/bin:$PATH
export LD_LIBRARY_PATH=$TOOLS/xmlstarlet/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}

sed 's/\r$//' tests/knownKeys > /tmp/knownKeys
sed 's/\r$//' tests/blacklist > /tmp/blacklist
sed 's/\r$//' overlay.mk > /tmp/overlay.mk

fail=0
check_overlay() {
  folder="$1"
  echo "==== checking $folder ===="
  while read -r b; do
    [ -z "$b" ] && continue
    if grep -qRF "\"$b\"" "$folder"; then
      echo "Fatal: Overlay $folder is defining blacklisted $b"
      fail=1
    fi
  done < /tmp/blacklist

  find "$folder" -name '*.xml' | while read -r xml; do
    if xmlstarlet sel -t -m '//public' -c . "$xml" 2>/dev/null | grep -qE ..; then
      echo "Fatal: $xml declares public.xml"
      fail=1
    fi
  done

  keys="$(find "$folder" -name '*.xml' -print0 | xargs -0 xmlstarlet sel -t -m '//resources/*' -v @name -n 2>/dev/null || true)"
  for key in $keys; do
    [ -z "$key" ] && continue
    if ! grep -qE '^'"$key"'$' /tmp/knownKeys; then
      if ! grep -qF "I swear it makes sense to set $key" -r "$folder"; then
        echo "Fatal: $folder defines a non-existing attribute $key"
        fail=1
      else
        echo "Note: $key allowed via swear comment"
      fi
    fi
  done

  if grep -qE 'config_automatic_brightness_available.*true' -r "$folder"; then
    if ! grep -r -q -e config_autoBrightnessLcdBacklightValues -e config_autoBrightnessDisplayValuesNits "$folder"; then
      echo "Fatal: $folder enables auto brightness without values"
      fail=1
    else
      echo "OK: auto brightness configured"
    fi
  fi

  f="$folder/res/xml/power_profile.xml"
  if [ -f "$f" ]; then
    if xmlstarlet sel -t -m '//*' -v 'name()' -n "$f" | sort -u | grep -qvE '^(array|device|item|value|modem|sleep|idle|active|receive|transmit)'; then
      echo "Fatal: $f sets non-sense power-profile values"
      fail=1
    fi
    cap="$(xmlstarlet sel -t -m '//item[@name="battery.capacity"]' -v . -n "$f")"
    echo "battery.capacity=$cap"
    if [ "$cap" = 1000 ]; then
      echo "Fatal: $f a 1000mAh battery? Sounds wrong."
      fail=1
    fi
  fi
}

# knownKeys check only for android-target static overlays
check_overlay Xiaomi/MiPad6Pro

echo "==== SystemUI (no knownKeys gate) ===="
if grep -qRF '"config_dozeComponent"' Xiaomi/MiPad6Pro-SystemUI; then
  echo "Fatal: blacklisted key in SystemUI"
  fail=1
fi
echo "SystemUI files:"
find Xiaomi/MiPad6Pro-SystemUI -type f

echo "==== overlay.mk listing ===="
grep mipad6pro /tmp/overlay.mk

echo "==== priority uniqueness ===="
pri="$(xmlstarlet sel -t -m '//overlay' -v @android:priority -n Xiaomi/MiPad6Pro/AndroidManifest.xml)"
echo "priority=$pri"
if grep -R --include=AndroidManifest.xml -l "android:priority=\"$pri\"" . | grep -v Xiaomi/MiPad6Pro | grep -v Xiaomi/MiPad6Pro-SystemUI; then
  echo "Warning: priority may be used elsewhere (see above)"
else
  echo "OK: priority $pri unique among other manifests (or only this device pair)"
fi

if [ "$fail" -ne 0 ]; then
  echo FAILED
  exit 1
fi
echo "==== tests passed ===="

echo "==== build ===="
sed 's/\r$//' build/build.sh > /tmp/vho-build.sh
cd "$ROOT/build"
bash /tmp/vho-build.sh --local-aapt "$ROOT/Xiaomi/MiPad6Pro"
bash /tmp/vho-build.sh --local-aapt "$ROOT/Xiaomi/MiPad6Pro-SystemUI"
ls -lh treble-overlay-xiaomi-mipad6pro*.apk
echo DONE
