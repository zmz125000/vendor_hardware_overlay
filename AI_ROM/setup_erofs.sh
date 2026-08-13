#!/bin/bash
set -e
cd /tmp/overlay-tools
for d in *.deb; do
  echo "extracting $d"
  dpkg-deb -x "$d" /tmp/overlay-tools/erofs
done
find /tmp/overlay-tools/erofs -name "*.so*"
export LD_LIBRARY_PATH=/tmp/overlay-tools/erofs/usr/lib/x86_64-linux-gnu:/tmp/overlay-tools/erofs/lib/x86_64-linux-gnu
/tmp/overlay-tools/erofs/usr/bin/dump.erofs --help | head -30
echo OK
