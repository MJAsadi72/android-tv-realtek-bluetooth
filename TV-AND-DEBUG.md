# TV identity and enabling Debug settings

## This TV (verified 2026-10-26)

Values shown under **Setting → About** (`Device Info`) and matching system properties:

| Field (About UI) | Value |
|---|---|
| Device Model | `GTV-50MU724S` |
| DDR Info | `1.5GB DDR3 16GB eMMC` |
| Android Version | `9` |
| Version | `V3.2.0` |
| Last Updated Date | `16/11/2021` |

| Property | Value |
|---|---|
| `ro.product.device` / board | `m7332_gplus` |
| `ro.build.type` | `userdebug` |
| `ro.build.version.release` / SDK | `9` / `28` |
| `ro.build.display.id` | `m7332_gplus-userdebug 9 PPR2.180905.006.A1 202111161817 releasekey-keys` |
| `ro.build.fingerprint` | `MediaTek/m7332_eu/m7332_eu:9/PPR2.180905.006.A1/chenjx11161816:userdebug/releasekey-keys` |
| `kgzn.ver.android` | `202111161819.9ff4847` |
| `kgzn.ota.model` | `TV9632_DVB` |
| `kgzn.board.type` | `M4F1` |
| Kernel | `4.9.118+` `#107` `Tue Nov 16 17:21:47 CST 2021` armv7l |
| Settings app | `com.kgzn.setting` |

Product branding on this unit is **Gplus** (`kgzn.ota.customer=gplus`); SoC platform is MediaTek **m7332**.

## Enable Debug settings (remote)

On this KGZN / Gplus firmware, the hidden debug menu is unlocked from **About**, not from the usual Android “Build number” row.

1. Open **Setting**.
2. Open **About** (Device Info).
3. Focus **Device Model** (shows `GTV-50MU724S`).
4. Press **OK** on that row repeatedly until the debug UI appears.

That opens the vendor debug helper inside Settings:

- Activity: `com.kgzn.setting/com.kgzn.debughelper.ui.acty.HomeActivity`
- Related: logcat / float-info services under `com.kgzn.debughelper.*`

Use this menu for factory/debug tools (ADB-related options, logs, board tests, etc.). Exact entries vary by firmware build; unlock method is always: **About → Device Model → repeated OK**.

### Open About or Debug via ADB

```bash
# About / Device Info
adb shell am start -n com.kgzn.setting/.view.about.AboutActivity

# Debug helper home (only useful after it has been unlocked at least once on some builds)
adb shell am start -n com.kgzn.setting/com.kgzn.debughelper.ui.acty.HomeActivity
```

## Related Settings paths

| Goal | Path |
|---|---|
| Bluetooth (after Realtek stack is installed) | **Setting → Other → Bluetooth** |
| Device / software version | **Setting → About** |
| Debug / factory tools | **Setting → About → Device Model** (press OK repeatedly) |
