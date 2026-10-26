# Permanent Realtek USB Bluetooth — installed

Verified after reboot on 2026-10-26:

- SELinux: **Enforcing**
- Module `rtk_btusb` loaded; `/dev/rtkbt_dev` labeled `u:object_r:bluetooth_device:s0`
- `persist.sys.bluetooth=true`; `bluetooth_manager` registered
- Adapter ON `00:E0:4C:23:99:87` (`Bluetooth Smart-TV`)
- Bonded / connected: Redmi TV Soundbar `08:EB:ED:C1:64:D1`
- Native Settings (`android.settings.BLUETOOTH_SETTINGS`) opens

## Files on TV (`/vendor`, remounted RO)

| Path | Role |
|---|---|
| `/vendor/lib/modules/rtk_btusb.ko` | Kernel driver |
| `/vendor/lib/libbt-vendor.so` | Realtek HAL vendor lib (replaced MTK) |
| `/vendor/etc/bluetooth/rtkbt.conf` | `BtDeviceNode=/dev/rtkbt_dev` |
| `/vendor/etc/bluetooth/bt_addr.conf` | BD address file |
| `/vendor/firmware/rtl8761b_fw` + `_config` | Userspace firmware path |
| `/vendor/etc/firmware/rtl8761b_fw` + `_config` | Kernel `request_firmware` path |
| `/vendor/etc/init/init.rtkbt.rc` | Boot: insmod, perms, restorecon, restart HAL |
| `/vendor/ueventd.rc` | Added `/dev/rtkbt_dev` 0660 bluetooth |
| `/vendor/etc/selinux/vendor_file_contexts` | `/dev/rtkbt_dev` → `bluetooth_device` |

MTK originals backed up under `/data/local/bt-permanent-backup/`.

See `RESTORE-STOCK.md` to undo.
