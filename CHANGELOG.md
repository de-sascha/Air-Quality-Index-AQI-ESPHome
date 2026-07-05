# Changelog

Versions are calendar-based: `vYYYY.MM.PATCH`. The year and month
match when the release was cut; `PATCH` increments within the same
month. Example: `v2026.07.0` is the first release of July 2026,
`v2026.07.1` would be a follow-up patch in the same month.
`v2026.07.0` is the earliest tag in the repository.

## Unreleased

### Added

- **Temperature calibration.** The SCD41 sits inside the enclosure and
  reads 2–6 °C above the real air temperature depending on case
  design and self-heating. Three new entities let the user correct
  this from the Web UI / Home Assistant without a rebuild:
  - `Temperature Offset` (number, 0–20 °C, step 0.1, default 4.0) —
    the value is written into the SCD41's on-chip offset register
    (`set_temperature_offset`, command 0x241D) so the correction
    happens on the sensor itself, not in software on top. Higher
    offset → lower reported temperature. Persists in NVS on the ESP,
    so a reboot preserves the setting even without an EEPROM save.
  - `Save Offset to Sensor EEPROM` (button) — calls the SCD41's
    `persist_settings` (0x3615) so the offset survives a full power
    cycle even without our firmware. Rate-limited by convention:
    the SCD41 EEPROM tolerates only ~2000 write cycles, so this is
    a deliberate button, not an on-every-slider-change action.
  - `Reset Offset to Factory (4 °C)` (button) — restores the
    Sensirion factory calibration in both places (NVS and sensor
    EEPROM), leaving the sensor indistinguishable from a freshly
    unboxed part.
- **Display controls.** Four new Home-Assistant / Web-UI entities to
  tune the OLED without a rebuild:
  - `Display Brightness` (number, 0–100 %, default 100) — slider that
    drives the SH1106 contrast register. Persists in NVS.
  - `Display Rotation` (select, `0` / `90` / `180` / `270`, default
    `0`) — rotates the framebuffer in 90° steps so the display can
    be mounted in any orientation inside a 3D-printed enclosure.
    Persists in NVS.
  - `Display Power` (switch, default on) — hard on/off. When off the
    SH1106 driver is disabled via `turn_off()` (lower current, no
    burn-in), not just blanked in software. Persists in NVS.
- **Night mode.** Blanks the display during a configurable window
  while leaving CO₂ and particulate sensors running (so Home
  Assistant history stays continuous).
  - `Night Mode Enabled` (switch, default on) — master gate.
  - `Night Mode Start` / `Night Mode End` (datetime, defaults
    `22:00` / `07:00`) — time pickers, wraparound across midnight is
    supported (the default 22 → 07 case). Zero-length window (start
    == end) is treated as always-off.
  All four entities persist in NVS.

### Internal

- New `apply_display_settings` script centralises all display state
  transitions (contrast, rotation, power gate). Called from
  `on_boot` (late, priority `-100`), from every display entity's
  `on_value`/`on_turn_*`, and from the night-mode interval — so
  there is exactly one code path that touches the display.
- New `apply_temperature_offset` and `persist_scd41_settings`
  scripts wrap the SCD4x command sequence
  (`stop_periodic_measurement` → command → `start_periodic_measurement`).
  The sensor is only writable in idle state; the delays match the
  Sensirion datasheet (500 ms after stop, 800 ms after persist).
- `on_boot` (priority `-100`) now also re-pushes the offset into the
  sensor after a 3 s settle, so a power cycle without an EEPROM save
  still ends up with the user's calibration.
- Second `on_boot` handler at priority `-100` applies the persisted
  display state after NVS restore, so the very first rendered frame
  honours the user's saved brightness / rotation / power state.
- 60 s interval evaluates the night-mode window against SNTP time.
  Falls back to "daytime" whenever SNTP is unsynced so a fresh
  device never boots into a dark display.

## v2026.07.1 — 2026-07-04 — Housekeeping

### Removed

- The pre-scheme `v0.2.0` tag has been deleted from local and remote.
  The calendar-based scheme starts at `v2026.07.0`; there is no
  earlier tag to compare against. The changelog entry that
  accompanied `v0.2.0` is preserved below under *Historical* — the
  changes it describes are the current baseline.

## v2026.07.0 — 2026-07-04 — Documentation polish

Documentation-only release. No firmware changes, no need to reflash.

### Added

- **Three photos of a running device** in the README section
  *What it looks like* — one per data page (overview / climate /
  particulates), shown alongside the existing ASCII mockups.
- **`Enclosure` section** in the README documenting the AirGradient
  DIY Pro (PCB v3.7) case as an interim solution, with an honest
  fit caveat and a call for a purpose-built case designed for the
  XIAO ESP32-C6 + SCD41 + PMS5003 + SH1106 layout.
- **`docs/images/`** directory holding the display photos (source
  files only; not consumed by the firmware build).

### Fixed

- README display photos rendered rotated 90° on github.com because
  the original JPEGs relied on an EXIF `Orientation` tag that
  GitHub's image proxy strips. Photos are now re-encoded with the
  rotation baked into the pixel data, EXIF removed. A `?v=2`
  cache-bust suffix on the image URLs forces the camo proxy to
  fetch the new bytes.

---

## Historical (pre-scheme)

These entries predate the calendar-based versioning. They were never
tagged in git and are kept here as project history — the state they
describe is the current baseline, not something you can check out.

### ESPHome-native rewrite — 2026-07-04 (originally labelled `v0.2.0`)

This changeset moved the project from pre-compiled binaries to a
source-only distribution model. Existing binary flashes did not
migrate automatically — the recipe became "build from source with
your own encryption keys".

**Breaking**

- **No more pre-compiled firmware.** `firmware/binary/` was removed
  together with `scripts/rebuild-firmware.sh`. Every builder compiles
  the firmware locally with `esphome run`.
- **Local `secrets.yaml` is now required.** The distribution YAML
  references four `!secret` values (`api_encryption_key`,
  `ota_password`, `web_username`, `web_password`) that each builder
  generates themselves. Template in
  `firmware/source/secrets.yaml.example`.
- **Home Assistant requires the API encryption key.** During device
  pairing HA prompts for the same value set in
  `secrets.yaml → api_encryption_key`.
- **Web UI is basic-auth protected** with `web_username` /
  `web_password` from `secrets.yaml`.
- **OTA updates are password-protected** with `ota_password` from
  `secrets.yaml`.

**Rationale.** Matches ESPHome's own
[Security Best Practices](https://esphome.io/guides/security_best_practices)
guide (unique keys per device, never reuse, never commit). The old
"no secrets needed" model was pleasant for first-time flashing but
did not survive contact with modern Home Assistant, which refuses to
downgrade encryption for a device it has seen encrypted before.

**Added**

- Onboarding QR-code page on the OLED display when the device is not
  connected to a Wi-Fi. Shows the fallback-AP SSID and password with
  a WPA-QR that phones scan for one-tap join.
- `Language` select entity in Home Assistant / Web UI. Switches all
  display texts and Home-Assistant state text_sensors (verdict,
  action, dust action, boot reason) between English and German.
- `scripts/live-log.sh` helper — one-liner to stream device logs to
  `/tmp/aq-YYYYMMDD-HHMMSS.log` while mirroring to the terminal.
- Compile-time log level raised to `VERBOSE` with a runtime default
  of `INFO`, so the `Log DEBUG On` / `Log VERBOSE On` buttons in the
  Web UI now actually work (they were previously no-ops emitting
  warnings).

**Fixed**

- Setup page no longer appears once per 24-second display rotation.
  The rotator now explicitly cycles through the four data pages when
  Wi-Fi is up and pins the setup page only when Wi-Fi is down.

### Initial public release (originally labelled `v0.1.0`)

- ESPHome-based indoor air-quality monitor for XIAO ESP32-C6
- SCD41 CO₂/T/rH + PMS5003 PM1.0/2.5/10 + SH1106 128×64 OLED
- 5-level AQI (TOP/GUT/MITTEL/SCHLECHT/KRITISCH) with per-metric
  status marks and plain-language recommendations
- Home Assistant integration via native ESPHome API
- Web UI on port 80 with live values, buttons, and log stream
