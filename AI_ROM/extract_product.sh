#!/bin/bash
set -euo pipefail
ROOT=/mnt/e/Data/Source/vendor_hardware_overlay/ROM
TOOLS=$ROOT/tools
EROFS=$TOOLS/erofs
SUPER=$ROOT/liuqin_images_OS3.0.7.0.VMYCNXM_15.0/images/super.unsparse.img
OUT=$ROOT/extracted
export LD_LIBRARY_PATH=$EROFS/usr/lib/x86_64-linux-gnu:$EROFS/lib/x86_64-linux-gnu

if [ ! -f "$OUT/product_a.img" ]; then
  python3 $TOOLS/lpunpack.py -p product_a "$SUPER" "$OUT"
fi
if [ ! -f "$OUT/system_ext_a.img" ]; then
  python3 $TOOLS/lpunpack.py -p system_ext_a "$SUPER" "$OUT"
fi
if [ ! -f "$OUT/system_a.img" ]; then
  python3 $TOOLS/lpunpack.py -p system_a "$SUPER" "$OUT"
fi

DUMP=$EROFS/usr/bin/dump.erofs
FSCK=$EROFS/usr/bin/fsck.erofs

echo "==== product overlay ===="
$DUMP --ls --path=/overlay "$OUT/product_a.img" || echo "no /overlay"
$DUMP --ls --path=/product/overlay "$OUT/product_a.img" || echo "no /product/overlay"

echo "==== system_ext overlay ===="
$DUMP --ls --path=/overlay "$OUT/system_ext_a.img" || echo "no system_ext overlay"

echo "==== system framework ===="
$DUMP --ls --path=/system/framework "$OUT/system_a.img" || $DUMP --ls --path=/framework "$OUT/system_a.img" || true
echo DONE
