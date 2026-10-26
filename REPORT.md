# Native Bluetooth POC — Result Report

Date: 2026-10-26
TV: `192.168.1.113:5555`, Gplus **GTV-50MU724S** (MediaTek `m7332_gplus`), Android 9 (SDK 28), firmware **V3.2.0** (`kgzn.ver.android=202111161819.9ff4847`, display id `m7332_gplus-userdebug 9 PPR2.180905.006.A1 202111161817`), kernel `4.9.118+` armv7l, `userdebug` build (`adb root` works). See [`TV-AND-DEBUG.md`](TV-AND-DEBUG.md) for About / Debug unlock.
Dongle: Realtek Bluetooth Radio, USB `0bda:8771` (RTL8761B, USB), BD address `00:E0:4C:23:99:87`

## Outcome: SUCCESS (proof-of-concept, temporary)

Native Bluetooth works end-to-end with the Realtek USB dongle:

- `bluetooth_manager` service registered and responding
- Bluetooth state **ON**, adapter name `Bluetooth Smart-TV`, address `00:E0:4C:23:99:87`
- Native Settings page `com.kgzn.setting/.view.others.OthersActivity` (via `android.settings.BLUETOOTH_SETTINGS`) opens without the previous `Bluetooth binder is null` / NPE crash, and Settings itself toggled Bluetooth (`Enabled due to APPLICATION_REQUEST by com.kgzn.setting`)
- Discovery + pairing from the TV UI worked; bonded device: `08:EB:ED:C1:64:D1 [BR/EDR] Redmi TV Soundbar`
- A2DP: `mActiveDevice: 08:EB:ED:C1:64:D1`, A2dpStateMachine `Connected`, `mIsPlaying: true`, codec SBC 48000 Hz / 16-bit / STEREO, audio state STARTED
- Full proof dump: `baseline/verification-bluetooth-on.txt` in this directory

## Working combination (exact artifacts)

All artifacts staged on the TV under `/data/local/tmp/bt-poc/` and on the laptop in `/home/mja/WorkSpace/bt-poc/staging/`.

| Artifact | Source | SHA-256 |
|---|---|---|
| `rtk_btusb.ko` (v4.1.5, `20180702_BT_ANDROID_8.1` + local patches) | Built from `rtk_btusb.c/.h` (hanwckf/linux-rk3328) with two patches: (1) added patch-table entry `{0x0BDA, 0x8771, 0x8761, ..., "mp_rtl8761b_fw", "rtl8761b_fw", "rtl8761b_config", ..., MAX_PATCH_SIZE_40K}`; (2) extended `project_id[]` in the header so index `14` maps to `ROM_LMP_8761a` (RTL8761B firmware project ID, parsed from the firmware extension section) | `a7bf3b3720ceaa9a50dc0e6116917d2e894aa2676ce41fd550c78329efbc6b2c` |
| `libbt-vendor.so` (Realtek prebuilt, Android 28, ARM 32-bit) | `Realtek-OpenSource/android_hardware_realtek`, `bt/rtkbt/code/libbt-vendor/libbt-vendor.so` (RTKBT Android 9.0 release `20180517`) | `7db242a682f354987e2be67b1af4d3178bba7ae9678bc4907f95e623a5faf5ed` |
| `rtl8761b_fw` | Same repo, `bt/rtkbt/Firmware/TV/rtl8761b_fw` | `15f75c1733b4e0075a418555a1e72e2e834bc80bc6347f47bf7abb4470c24e60` |
| `rtl8761b_config` | Same repo, `bt/rtkbt/Firmware/TV/rtl8761b_config` | `c893e8423b790a3ea7ff5cfd6a7594b9e069c378f8c18f8aa3ad05db5728fd37` |
| `rtkbt.conf` | Same repo `vendor/etc/bluetooth/rtkbt.conf`, one line changed: `BtDeviceNode=/dev/rtkbt_dev` | staged at `staging/btetc/rtkbt.conf` |

Kernel build details:

- Vanilla `linux-4.9.118` source + TV's own `/proc/config.gz` as `.config`
- Toolchain: Bootlin `armv7-eabihf--glibc--stable-2017.05` (gcc 5.4.0) — the exact Linaro 4.9-2014.11 toolchain used by the TV vendor is no longer downloadable; gcc 5.4 produced a loadable module
- `Module.symvers` synthesized from the `__versions` sections of all 29 stock `/vendor/lib/modules/*.ko` files (2832 symbol CRCs, zero conflicts)
- Local Kconfig tweak in the build tree only: removed `select ARM_PATCH_PHYS_VIRT` from `ARCH_MULTIPLATFORM` and set `CONFIG_PHYS_OFFSET=0x20000000`, so vermagic is exactly `4.9.118+ SMP preempt mod_unload modversions ARMv7 thumb2 ` (matches stock `btmtk_usb.ko`)
- `make modules_prepare` + external module build; 6 symbols (`_raw_write_lock/unlock`, `devm_kmalloc`, `usb_disable_autosuspend`, `usb_get_from_anchor`, `usb_scuttle_anchored_urbs`) had no harvested CRC and were accepted by the loader without a version record

## Runtime steps used (in order)

```bash
# laptop -> TV staging (adb with proxychains bypass: env -u LD_PRELOAD adb ...)
adb push staging/rtk_btusb.ko            /data/local/tmp/bt-poc/
adb push staging/firmware/*              /data/local/tmp/bt-poc/firmware/
adb push staging/hal/libbt-vendor.so     /data/local/tmp/bt-poc/hal/
adb push staging/btetc/*                 /data/local/tmp/bt-poc/btetc/
adb push staging/fwvendor/*              /data/local/tmp/bt-poc/fwvendor/

# one-time gate to make system_server register bluetooth_manager
# (MTK framework in services.vdex references persist.sys.bluetooth; it was "false")
adb shell settings put global bluetooth_on 0
adb shell setprop persist.sys.bluetooth true
adb reboot

# after reboot (adb root again), temporary stack:
setenforce 0
echo -n "/data/local/tmp/bt-poc/firmware" > /sys/module/firmware_class/parameters/path
insmod /data/local/tmp/bt-poc/rtk_btusb.ko
chown bluetooth /dev/rtkbt_dev; chmod 0660 /dev/rtkbt_dev
mount -o bind /data/local/tmp/bt-poc/btetc     /vendor/etc/bluetooth
mount -o bind /data/local/tmp/bt-poc/hal/libbt-vendor.so /vendor/lib/libbt-vendor.so
mount -o bind /data/local/tmp/bt-poc/fwvendor  /vendor/firmware
setprop ctl.restart vendor.bluetooth-1-0
svc bluetooth enable
am start -a android.settings.BLUETOOTH_SETTINGS
```

Notes / gotchas discovered:

- This driver does **not** create kernel `/sys/class/bluetooth/hci0`; it creates `/dev/rtkbt_dev`, which is the transport the Android `libbt-vendor` expects. Phase 2's success criterion was met in this equivalent form.
- Firmware is consumed twice: the kernel driver via `request_firmware` (firmware-class path) **and** the userspace lib from the hardcoded path `/vendor/firmware/rtl8761b_fw|_config`. Missing the latter caused a deterministic HAL segfault (`hw_usb_config_cback` null deref after `Can't access firmware`). Both locations must have the files.
- The userspace lib issues one ioctl the 4.1.5 driver does not implement (`DWFW_CMPLT` 205, logged as `Failed with wrong Cmd:1074022605`); it is non-fatal.
- After the controlled reboot, the dongle did not enumerate on its original USB port (bus 2) until it was moved to another port (enumerated as `1-1`); the driver then probed it correctly.
- SELinux ran permissive during the POC; several `avc: denied ... permissive=1` lines (module load, `/dev/rtkbt_dev` access, lib loading) show the sepolicy work a permanent version would need.
- The pairing record for the soundbar lives in `/data/misc/bluedroid/` (normal Android bond storage) and survives the POC revert.

## Revert performed

Per plan, everything above is temporary: `svc bluetooth disable`, unmount the three bind mounts, `rmmod rtk_btusb`, restore `/sys/module/firmware_class/parameters/path` to `/vendor/etc/firmware/`, `setenforce 1`, restore `persist.sys.bluetooth=false` and `settings bluetooth_on=1`, delete `/data/local/tmp/bt-poc`, reboot, and verify stock state (`bluetooth_manager` absent again, no `/dev/rtkbt_dev`, TV otherwise normal).

## Recommended follow-up (separate plan, not implemented)

Persistence would require: placing `rtk_btusb.ko` + firmware on `/vendor`, an init `.rc` to insmod/bind-mount (or replace) `libbt-vendor.so`, `rtkbt.conf` and firmware at boot, `ueventd` permissions for `/dev/rtkbt_dev` (`0660 bluetooth net_bt_admin`), sepolicy types/rules, and `persist.sys.bluetooth=true` permanently — with reboot/OTA/brick-risk review.
