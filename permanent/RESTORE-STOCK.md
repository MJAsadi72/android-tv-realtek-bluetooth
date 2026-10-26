# Restore stock MediaTek Bluetooth (undo permanent install)

On the TV (adb root):

```bash
mount -o remount,rw /vendor
cp /data/local/bt-permanent-backup/libbt-vendor.so.mtk /vendor/lib/libbt-vendor.so
chcon u:object_r:same_process_hal_file:s0 /vendor/lib/libbt-vendor.so
cp /data/local/bt-permanent-backup/bt_addr.conf /vendor/etc/bluetooth/bt_addr.conf
rm -f /vendor/etc/bluetooth/rtkbt.conf
rm -f /vendor/lib/modules/rtk_btusb.ko
rm -f /vendor/firmware/rtl8761b_fw /vendor/firmware/rtl8761b_config
rm -rf /vendor/etc/firmware
rm -f /vendor/etc/init/init.rtkbt.rc
rm -f /vendor/bin/rtkbt_prep.sh
cp /data/local/bt-permanent-backup/ueventd.rc.orig /vendor/ueventd.rc
# restore SELinux file_contexts if backed up
if [ -f /data/local/bt-permanent-backup/vendor_file_contexts.orig ]; then
  cp /data/local/bt-permanent-backup/vendor_file_contexts.orig /vendor/etc/selinux/vendor_file_contexts
fi
setprop persist.sys.bluetooth false
settings put global bluetooth_on 1
sync
mount -o remount,ro /vendor
reboot
```
