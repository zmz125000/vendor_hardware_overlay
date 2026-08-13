#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay/ROM
TOOLS=$ROOT/tools
EROFS=$TOOLS/erofs
VENDOR=$ROOT/extracted/vendor_a.img
ODM=$ROOT/extracted/odm_a.img
OUT=$ROOT/extracted/files
mkdir -p "$TOOLS" "$OUT/vendor_overlay" "$OUT/odm_overlay" "$OUT/props"

cd "$TOOLS"
if [ ! -f lpunpack.py ]; then
  curl -fsSL -o lpunpack.py https://raw.githubusercontent.com/unix3dgforce/lpunpack/master/lpunpack.py
fi

if [ ! -x "$EROFS/usr/bin/dump.erofs" ]; then
  apt-get download erofs-utils libdeflate0 liblz4-1 liblzma5 libselinux1 libzstd1 zlib1g
  mkdir -p "$EROFS"
  for d in *.deb; do
    echo "extracting $d"
    dpkg-deb -x "$d" "$EROFS"
  done
fi

export LD_LIBRARY_PATH=$EROFS/usr/lib/x86_64-linux-gnu:$EROFS/lib/x86_64-linux-gnu
DUMP=$EROFS/usr/bin/dump.erofs
FSCK=$EROFS/usr/bin/fsck.erofs

echo "==== vendor /overlay ===="
$DUMP --ls --path=/overlay "$VENDOR"
echo "==== vendor root ===="
$DUMP --ls --path=/ "$VENDOR"
echo "==== odm /overlay ===="
$DUMP --ls --path=/overlay "$ODM" || echo "no odm overlay"
echo "==== odm root ===="
$DUMP --ls --path=/ "$ODM"

echo "Extracting vendor overlay..."
$FSCK --extract="$OUT/vendor_fs" --path=/overlay --overwrite --no-preserve "$VENDOR"
# Also extract key props and extra overlays if present
$DUMP --cat --path=/build.prop "$VENDOR" > "$OUT/props/vendor_build.prop" || true
$DUMP --cat --path=/odm_dlkm/etc/build.prop "$ODM" > "$OUT/props/odm_dummy.prop" || true
$DUMP --cat --path=/etc/build.prop "$ODM" > "$OUT/props/odm_etc_build.prop" || true
$DUMP --cat --path=/build.prop "$ODM" > "$OUT/props/odm_build.prop" || true

# copy overlay apks to a flat folder
mkdir -p "$OUT/vendor_overlay"
find "$OUT/vendor_fs" -name '*.apk' -exec cp -v {} "$OUT/vendor_overlay/" \;
ls -lh "$OUT/vendor_overlay" "$OUT/props"
echo DONE
