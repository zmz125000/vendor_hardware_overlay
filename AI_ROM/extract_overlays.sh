#!/bin/bash
set -e
export LD_LIBRARY_PATH=/tmp/overlay-tools/erofs/usr/lib/x86_64-linux-gnu
DUMP=/tmp/overlay-tools/erofs/usr/bin/dump.erofs
FSCK=/tmp/overlay-tools/erofs/usr/bin/fsck.erofs
VENDOR=/mnt/e/Data/Source/vendor_hardware_overlay/ROM/extracted/vendor_a.img
ODM=/mnt/e/Data/Source/vendor_hardware_overlay/ROM/extracted/odm_a.img
OUT=/mnt/e/Data/Source/vendor_hardware_overlay/ROM/extracted/files
mkdir -p "$OUT/vendor_overlay" "$OUT/odm_overlay" "$OUT/props"

echo "==== vendor /overlay ===="
$DUMP --ls --path=/overlay "$VENDOR"
echo "==== vendor /etc (build.prop-ish) ===="
$DUMP --ls --path=/ "$VENDOR" | head -40
echo "==== vendor build.prop ===="
$DUMP --cat --path=/build.prop "$VENDOR" > "$OUT/props/vendor_build.prop" || true
$DUMP --cat --path=/odm/etc/build.prop "$ODM" > "$OUT/props/odm_build.prop" || true
echo "==== odm /overlay ===="
$DUMP --ls --path=/overlay "$ODM" || echo "no odm overlay"
echo "==== odm root ===="
$DUMP --ls --path=/ "$ODM"

echo "Extracting vendor overlay APKs..."
$FSCK --extract="$OUT/vendor_overlay" --path=/overlay --overwrite "$VENDOR"

echo "Extracting vendor build props..."
$DUMP --cat --path=/build.prop "$VENDOR" > "$OUT/props/vendor_build.prop" || true
ls -lh "$OUT/vendor_overlay" "$OUT/props"
echo DONE
