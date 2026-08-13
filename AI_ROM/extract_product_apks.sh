#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay/ROM
EROFS=$ROOT/tools/erofs
export LD_LIBRARY_PATH=$EROFS/usr/lib/x86_64-linux-gnu:$EROFS/lib/x86_64-linux-gnu
FSCK=$EROFS/usr/bin/fsck.erofs
DUMP=$EROFS/usr/bin/dump.erofs
IMG=$ROOT/extracted/product_a.img
OUT=$ROOT/extracted/files/product_overlay
mkdir -p "$OUT"

apks=(
  DevicesAndroidOverlay.apk
  DevicesOverlay.apk
  AospFrameworkResOverlay.apk
  FrameworksResCommon_Sys.apk
  SystemUIResCommon_Sys.apk
  framework-res__tablet__auto_generated_characteristics_rro.apk
  SettingsRroDeviceTypeOverlay.apk
  SettingsRroDeviceSystemUiOverlay.apk
  CompanionDeviceManager__tablet__auto_generated_characteristics_rro.apk
  AospWifiResOverlay.apk
)

# extract whole overlay dir would be huge; extract each apk via dump --cat
for apk in "${apks[@]}"; do
  echo "extracting $apk"
  $DUMP --cat --path=/overlay/$apk "$IMG" > "$OUT/$apk"
  ls -lh "$OUT/$apk"
done
echo DONE
