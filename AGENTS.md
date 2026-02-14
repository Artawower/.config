# System Configuration Notes

## Environment: Asahi Linux (Fedora) + Niri compositor, MacBook Pro (Apple Silicon)

### Shell: xonsh (from Nix store)
- Config: `~/.config/xonsh/rc.xsh` sources modular files from `~/.config/xonsh/`
- PATH setup: `~/.config/xonsh/paths.xsh`

### Nix + Fedora coexistence
- Home Manager manages Nix packages (`~/.config/home-manager/home.nix`, flake-based, `nixos-23.05`)
- `hm-session-vars.sh` is sourced in `rc.xsh` — it sets env vars like `LD_LIBRARY_PATH`, `CPATH`, `LIBCLANG_PATH`
- **Problem**: Nix's `LD_LIBRARY_PATH` breaks Fedora system binaries (e.g. `libz` version mismatch in binutils)
- **Fix applied** in `rc.xsh`: `del $LD_LIBRARY_PATH` on Linux after sourcing hm-session-vars. Nix binaries use RPATH, don't need it.
- **PATH priority**: Fedora `/usr/bin` before Nix `~/.nix-profile/bin` (configured in `paths.xsh`)
- GPU/Mesa/kernel must come from Fedora (Asahi drivers not in Nix)

### Touchpad: trackpad-is-too-damn-big (titdb)
- **What**: Palm rejection / edge activation limiter for Apple trackpad, mimics macOS behavior
- **Why**: Default libinput palm detection insufficient; taps trigger during typing, edges too sensitive
- **Source**: https://github.com/tascvh/trackpad-is-too-damn-big
- **Build deps**: `sudo dnf install cmake gcc gcc-c++ libevdev-devel`
- **Built from**: `~/tmp/trackpad-is-too-damn-big/build/trackpad-is-too-damn-big/`
- **Installed to**: `/usr/local/bin/titdb`
- **Device**: `/dev/input/by-path/platform-39b10c000.spi-cs-0-event-mouse` (Apple SPI Trackpad, event0)
- **Systemd**: `/etc/systemd/system/titdb.service` — `sudo systemctl enable --now titdb.service`
- **Rebuild**: `cd ~/tmp/trackpad-is-too-damn-big/build/trackpad-is-too-damn-big/build && cmake .. && make`

### Other touchpad tuning (not yet applied)
- `libinput-config` — scroll speed factor (`/etc/libinput.conf`, `scroll-factor=0.5`)
- Niri touchpad config in `~/.config/niri/config.kdl`: `dwt` (disable while typing), `accel-speed`, `accel-profile`
