#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay
cd "$ROOT"

# unix line endings on new overlay files
find Xiaomi/MiPad6Pro Xiaomi/MiPad6Pro-SystemUI -type f -print0 | xargs -0 sed -i 's/\r$//'

# xmlstarlet for tests
TOOLS=$ROOT/ROM/tools
mkdir -p "$TOOLS/xmlstarlet"
if [ ! -x "$TOOLS/xmlstarlet/usr/bin/xmlstarlet" ]; then
  cd "$TOOLS"
  apt-get download xmlstarlet libxml2-16 libxslt1.1
  for d in xmlstarlet_*.deb libxml2-16_*.deb libxslt1.1_*.deb; do
    [ -f "$d" ] && dpkg-deb -x "$d" "$TOOLS/xmlstarlet"
  done
  cd "$ROOT"
fi
export PATH=$TOOLS/xmlstarlet/usr/bin:$PATH
export LD_LIBRARY_PATH=$TOOLS/xmlstarlet/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}

echo "xmlstarlet: $(command -v xmlstarlet)"
xmlstarlet --version || true

echo "==== tests.sh ===="
sed 's/\r$//' tests/tests.sh > /tmp/vho-tests.sh
# Force repo root; original script derives it from $0
sed -i 's|^base=.*|base="'"$ROOT"'"|' /tmp/vho-tests.sh
bash /tmp/vho-tests.sh

echo "==== build overlays ===="
sed 's/\r$//' build/build.sh > /tmp/vho-build.sh
chmod +x /tmp/vho-build.sh
cd "$ROOT/build"
bash /tmp/vho-build.sh --local-aapt "$ROOT/Xiaomi/MiPad6Pro"
bash /tmp/vho-build.sh --local-aapt "$ROOT/Xiaomi/MiPad6Pro-SystemUI"
ls -lh treble-overlay-xiaomi-mipad6pro*.apk
echo DONE
