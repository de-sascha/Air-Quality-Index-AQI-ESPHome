# Changelog

Versions are calendar-based: `vYYYY.MM.PATCH`. The year and month
match when the release was cut; `PATCH` increments within the same
month. Example: `v2026.07.0` is the first release of July 2026,
`v2026.07.1` would be a follow-up patch in the same month.
`v2026.07.0` is the earliest tag in the repository.

## Unreleased

### Added

- **PMS5003 particle-count bins.** Six new sensor entities in the
  "Sensor (PMS5003)" group: `Particles > 0.3 µm`, `> 0.5 µm`,
  `> 1.0 µm`, `> 2.5 µm`, `> 5.0 µm`, `> 10 µm`. Unit is "particles
  per 0.1 L of air" as defined in the Plantower manual (Data7..Data12
  in the 32-byte UART frame). The two smallest bins are the most
  health-relevant — sub-µm particles are alveoli-penetrating and are
  under-represented by the µg/m³ mass concentrations that the AQI
  score already uses. No extra bus traffic; the sensor sends these
  values in the same frame we were already parsing.
- **SCD41 Automatic Self-Calibration (ASC) toggle.** New `Auto
  Calibration (ASC)` switch in the "Sensor (SCD41)" group, default
  ON (Sensirion factory default). ASC anchors the sensor's zero
  point against the lowest CO₂ value seen in a rolling ~7-day
  window on the assumption that value corresponds to 400 ppm fresh
  air. Users in rooms that never see fresh air (rarely-ventilated
  bedrooms, weekend-empty offices) should turn ASC OFF — else the
  algorithm re-anchors against an elevated baseline and permanently
  under-reads. Setting persists in NVS on the ESP and is re-pushed
  into the sensor on every boot; also written to sensor EEPROM
  whenever "Save Offset to Sensor EEPROM" is clicked.
  ESPHome command: `set_automatic_self_calibration_enabled` (0x2416)
  per SCD4x datasheet Section 3.7.2.
- **SCD41 Forced Recalibration.** New `Reference CO2 (ppm)` number
  entity (range 400..1000, default 420 = 2026 global outdoor
  baseline) and `Force Recalibration Now` button. Datasheet-correct
  sequence: stop periodic measurement → wait 500 ms →
  `perform_forced_recalibration` (0x362F) with the reference value
  as a u16 → wait 400 ms → restart periodic measurement. Per SCD4x
  datasheet Section 3.7.1, the sensor must have been running in
  periodic mode for at least 3 minutes in a homogeneous CO₂
  environment before this succeeds; otherwise the sensor returns
  0xFFFF (failure). Typical use: take device outside, wait 3-5 min,
  click the button. Complements ASC and is the correct fix when ASC
  cannot see fresh air.
- **SCD41 altitude compensation.** New `Altitude (m)` number entity
  (range 0..3000, step 10, default 0). NDIR CO₂ measurement is
  pressure-dependent — at 1000 m altitude the uncompensated value
  under-reads by ~3 %. The value is pushed into the sensor via
  `set_sensor_altitude` (0x2427) as a u16 in metres per SCD4x
  datasheet Section 3.6.3. Persists in NVS, re-pushed on every boot,
  and cleared by the new "Reset Sensor Calibration" button below.
- **Reset Sensor Calibration** button (SCD41 group). Issues
  `perform_factory_reset` (0x3632, ~1200 ms per datasheet Section
  3.9.2) which wipes the SCD41's on-chip EEPROM entirely, then
  resets our four ESP-side calibration entities to Sensirion
  defaults (temperature offset 4.0 °C, altitude 0 m, ASC on,
  reference CO₂ 420 ppm) and re-pushes them into the blanked
  sensor. After this button, the SCD41 is indistinguishable from a
  freshly unboxed part. Wi-Fi credentials, night mode, and display
  settings are NOT touched — use "Factory Reset" in the System
  group for a full wipe.

### Internal

- New `apply_sensor_altitude` and `apply_asc_setting` scripts follow
  the same stop → command → restart pattern as
  `apply_temperature_offset`. All datasheet-mandated delays
  (500 ms after stop, 400 ms after FRC, 1200 ms after factory
  reset) are honoured explicitly.
- The `on_boot` (priority -100) handler now re-pushes altitude and
  ASC into the sensor after the 10 s settle window, in addition to
  the existing temperature-offset push, so a power cycle without
  an EEPROM save still ends up in the user-configured state.
- All command codes, timings, and encodings are verified against
  the Sensirion SCD4x datasheet
  (`docs/datasheets/sensirion-scd4x.pdf`, Sections 3.6.3, 3.7.1,
  3.7.2, 3.9.2). Particle-count entity names are verified against
  the ESPHome `pmsx003` component (`pm_0_3um`, `pm_0_5um`,
  `pm_1_0um`, `pm_2_5um`, `pm_5_0um`, `pm_10_0um`), and their
  semantics ("particles > diameter per 0.1 L air") against the
  Plantower PMS5003 manual.

## v2026.07.3 — 2026-07-06 — Web-UI Auth Required switch removed

Bugfix release. Reflash recommended for users on v2026.07.2. No
pin-out or AQI-threshold changes; no `secrets.yaml` schema change.

### Removed

- **`Web UI Auth Required` runtime switch.** Removed the entity added
  in v2026.07.2. The intent had been to let users disable Basic-Auth
  on the Web UI at runtime for quicker LAN access, but the
  implementation had a boot-order race (the priority-800 `on_boot`
  handler reading the template switch's state before ESPHome had
  restored it from NVS), and every attempted fix ran into further
  issues (globals not persisted synchronously enough for a
  fast-follow reboot; `App.safe_reboot()` firing inside the default
  `safe_mode` `boot_is_good_after` window and triggering an OTA
  rollback that silently reverted the fix). Since ESPHome does not
  provide a first-class way to toggle Web-UI auth at runtime, we
  drop the feature and stay on the standard: Basic-Auth is always
  on, credentials come from `secrets.yaml` as before.
  ([#1](https://github.com/de-sascha/AirQuality/issues/1))

  **Home-Assistant impact:** the entity `switch.web_ui_auth_required`
  is gone. Any automation that toggled it should be removed.

## v2026.07.2 — 2026-07-06 — Display, offset, Web-UI groups, boot-loop fix

Runtime feature release. Reflash required. No pin-out or AQI-threshold
changes; no `secrets.yaml` schema change.

### Added

- **Temperature calibration.** The SCD41 sits inside the enclosure and
  reads 2–6 °C above the real air temperature depending on case
  design and self-heating. Three new entities let the user correct
  this from the Web UI / Home Assistant without a rebuild:
  - `Temperature Offset` (number, 0–10 °C, step 0.1, default 4.0) —
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
- **Web UI card groups.** The frontpage now splits into thematic
  boxes instead of one flat list:
  - `Sensor (SCD41)` — Room Temperature, CO₂, Humidity, Temperature
    Offset, Save/Reset buttons, AQI scores.
  - `Sensor (PMS5003)` — PM 1.0 / 2.5 / 10, PMS5003 Active + Restart
    controls, Dust Action, AQI scores.
  - `Display` — Brightness, Rotation, Power, Night Mode + Start/End
    time pickers, Display Refresh, Language, Air Quality Verdict /
    Action.
  - `System` — Restart, Restart Safe Mode, WiFi Reconnect, Web UI Auth
    Required, Factory Reset.
  - `Diagnostics` — IP, MAC, RSSI, Uptime, ESPHome Version, Boot
    Reason, CPU Temperature, Heap stats, log-level buttons.
  Every entity now carries a `web_server.sorting_group_id` and
  `sorting_weight`.
- **`Web UI Auth Required`** switch (System group, default on).
  Toggles whether `http://<device>/` requires basic-auth on the next
  boot. Flip triggers a 3 s countdown + `App.safe_reboot()`. Guarded
  by a `boot_settled` global so the reboot action only fires on real
  user toggles, never during the setup-time state-restore.
- **Node-Web-UI resilience** on boot. All display touches and SCD41
  command sequences (offset apply, EEPROM persist) are guarded by
  `boot_settled`, which flips true 10 s into boot after all
  components have completed setup. Prevents a Store-access-fault
  crash observed when `apply_display_settings` ran too early.

### Changed

- **SCD41 `Temperature` renamed to `Room Temperature`.** Reflects
  that the value is already offset-corrected by the sensor's internal
  register (see the `Temperature Offset` slider). `entity_id` in
  Home Assistant changes accordingly.
- **`Temperature Offset` range is 0–10 °C.** 20 °C offset is not
  physically plausible in any real enclosure; 0–10 °C covers even
  extreme self-heating scenarios and prevents slip-of-the-finger
  nonsense values.
- **`Night Mode Enabled` switch now reacts immediately.** Extracted
  the window-evaluation logic into a re-usable `reevaluate_night_mode`
  script that is called from the switch's on_turn_on/off, from both
  `Night Mode Start` / `End` on_value handlers, AND from the 60 s
  heartbeat interval. Previously a Web-UI toggle waited up to a full
  minute before taking effect.

### Fixed

- **Boot loop on the `Web UI Auth Required` switch.** ESPHome's
  template switches call `turn_on()`/`turn_off()` during setup to
  apply their restore_mode-derived state, which triggers
  `on_turn_on`/`on_turn_off`. Without a guard, the switch's reboot
  action fired on every boot → infinite loop, silently rolled back
  via ESP32 OTA slot-swap. The `boot_settled` global (flipped 10 s
  into boot) gates the reboot trigger so only real user toggles fire.

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
