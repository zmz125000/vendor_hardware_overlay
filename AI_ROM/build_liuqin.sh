#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay
cd "$ROOT/build"
export PATH="$ROOT/build:/usr/bin:/bin:$PATH"
export LD_LIBRARY_PATH="$ROOT/build"
aapt version
JAVA=/mnt/e/Data/Source/vendor_hardware_overlay/ROM/tools/jre/bin/java
export LD_LIBRARY_PATH="$ROOT/build/signapk:$ROOT/build:${LD_LIBRARY_PATH:-}"
"$JAVA" -version

pack() {
  local path="$1"
  local name
  name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$path/Android.mk" | tr -d '\r')"
  echo "Generating $name"
  aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar
  "$JAVA" -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
  rm -f "${name}-unsigned.apk"
}

pack "$ROOT/Xiaomi/MiPad6Pro"
pack "$ROOT/Xiaomi/MiPad6Pro-SystemUI"
ls -lh "$ROOT/build"/treble-overlay-xiaomi-mipad6pro*.apk
echo DONE
