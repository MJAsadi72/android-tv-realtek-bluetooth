# Native Bluetooth on MediaTek Android TV (Realtek USB)

Enable native Android Bluetooth (Settings UI, pairing, A2DP) on a MediaTek `m7332_gplus` / similar Android 9 TV box using a **Realtek RTL8761B** USB dongle (`0bda:8771`), instead of the stock MediaTek Bluetooth stack.

**Verified:** Bluetooth ON, Settings page opens, Redmi TV Soundbar paired, A2DP playing — including a permanent `/vendor` install that survives reboot under SELinux Enforcing.

## Quick map

| Path | What |
|---|---|
| [`REPORT.md`](REPORT.md) | Full POC report: artifacts, SHA-256, runtime steps, gotchas |
| [`permanent/`](permanent/) | Permanent install notes, `init.rtkbt.rc`, restore-to-stock |
| [`staging/`](staging/) | Working `rtk_btusb.ko`, firmware, `libbt-vendor.so`, `rtkbt.conf` |
| [`rtk_driver/`](rtk_driver/) | Patched driver sources + Makefile used for the build |
| [`rtk_btusb/`](rtk_btusb/) | Upstream-ish driver sources before/alongside local patches |
| [`baseline/`](baseline/) | Phase-0 captures + verification dump |

## Requirements

- TV: Android 9 `userdebug` (or equivalent with `adb root` + remountable `/vendor`)
- Dongle: Realtek USB Bluetooth `0bda:8771` (RTL8761B)
- Host: ADB to the TV; optional cross-build of `rtk_btusb.ko` for kernel `4.9.118+` armv7

## Temporary POC

See [`REPORT.md`](REPORT.md) for the exact push / bind-mount / `insmod` sequence.

## Permanent install

See [`permanent/PERMANENT.md`](permanent/PERMANENT.md). To undo: [`permanent/RESTORE-STOCK.md`](permanent/RESTORE-STOCK.md).

Settings path on this firmware: **Setting → Other → Bluetooth**.

## License / sources

- Kernel driver based on Realtek `rtk_btusb` (e.g. hanwckf/linux-rk3328 tree), with local USB ID / project-id patches for RTL8761B.
- `libbt-vendor.so` and firmware from [Realtek-OpenSource/android_hardware_realtek](https://github.com/Realtek-OpenSource/android_hardware_realtek) (Android 9.0 RTKBT release).
- Do **not** redistribute stock MediaTek TV blobs; those are intentionally omitted from this repo.
