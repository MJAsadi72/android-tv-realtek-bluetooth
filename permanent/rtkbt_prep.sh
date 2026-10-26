#!/system/bin/sh
# Run as u:r:su:s0 — make SELinux permissive then load Realtek BT USB driver
echo 0 > /sys/fs/selinux/enforce
/system/bin/setenforce 0
# Module may already be loaded by init; ignore failure
/system/bin/insmod /vendor/lib/modules/rtk_btusb.ko 2>/dev/null
i=0
while [ ! -e /dev/rtkbt_dev ] && [ $i -lt 50 ]; do
  sleep 0.1
  i=$((i+1))
done
/system/bin/chmod 0660 /dev/rtkbt_dev
/system/bin/chown bluetooth.bluetooth /dev/rtkbt_dev
# Restart HAL so it opens the node under permissive
/system/bin/setprop ctl.restart vendor.bluetooth-1-0
exit 0
