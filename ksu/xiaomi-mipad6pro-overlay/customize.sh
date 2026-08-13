#!/system/bin/sh
# Sourced by KernelSU / Magisk after extract.

ui_print "- Xiaomi Pad 6 Pro (liuqin) GSI overlays"
ui_print "- treble-overlay-xiaomi-mipad6pro"
ui_print "- treble-overlay-xiaomi-mipad6pro-systemui"

set_perm_recursive "$MODPATH/system" 0 0 0755 0644 u:object_r:system_file:s0

fp="$(getprop ro.vendor.build.fingerprint)"
case "$fp" in
  *liuqin*)
    ui_print "- Device match: $fp"
    ;;
  *)
    ui_print "- Warning: fingerprint is not Xiaomi/liuqin*"
    ui_print "  Static overlay will stay inactive on other devices"
    ;;
esac

if [ "$KSU" = "true" ]; then
  ui_print "- KernelSU: /system mounts need a metamodule"
  ui_print "  (meta-overlayfs / Hybrid Mount / Magic Mount)"
fi
