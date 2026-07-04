# Changelog

## v0.2.0 — 2026-07-04 — ESPHome-native rewrite (breaking)

**This release changes the distribution model. Existing binary flashes
will not migrate automatically — the recipe is now to build from
source with your own encryption keys.**

### Breaking

- **No more pre-compiled firmware.** `firmware/binary/` has been
  removed together with `scripts/rebuild-firmware.sh`. Every builder
  compiles the firmware locally with `esphome run`.
- **Local `secrets.yaml` is now required.** The distribution YAML now
  references four `!secret` values (`api_encryption_key`,
  `ota_password`, `web_username`, `web_password`) that each builder
  must generate themselves. Template in
  `firmware/source/secrets.yaml.example`.
- **Home Assistant now requires the API encryption key.** During
  device pairing HA prompts for the same value that was set in
  `secrets.yaml → api_encryption_key`.
- **Web UI is now basic-auth protected** with `web_username` /
  `web_password` from `secrets.yaml`.
- **OTA updates are now password-protected** with `ota_password` from
  `secrets.yaml`.

### Rationale

Matches ESPHome's own
[Security Best Practices](https://esphome.io/guides/security_best_practices)
guide (unique keys per device, never reuse, never commit). The old
"no secrets needed" model was pleasant for first-time flashing but
did not survive contact with modern Home Assistant, which refuses to
downgrade encryption for a device it has seen encrypted before.

### Added

- Onboarding QR-code page on the OLED display when the device is not
  connected to a Wi-Fi. Shows the fallback-AP SSID and password with a
  WPA-QR that phones scan for one-tap join.
- `Language` select entity in Home Assistant / Web UI. Switches all
  display texts and Home-Assistant state text_sensors (verdict,
  action, dust action, boot reason) between English and German.
- `scripts/live-log.sh` helper — one-liner to stream device logs to
  `/tmp/aq-YYYYMMDD-HHMMSS.log` while mirroring to the terminal.
- Compile-time log level raised to `VERBOSE` with a runtime default of
  `INFO`, so the `Log DEBUG On` / `Log VERBOSE On` buttons in the Web
  UI now actually work (they were previously no-ops emitting warnings).

### Fixed

- Setup page no longer appears once per 24-second display rotation.
  The rotator now explicitly cycles through the four data pages when
  Wi-Fi is up and pins the setup page only when Wi-Fi is down.

## v0.1.0 — initial public release

- ESPHome-based indoor air-quality monitor for XIAO ESP32-C6
- SCD41 CO₂/T/rH + PMS5003 PM1.0/2.5/10 + SH1106 128×64 OLED
- 5-level AQI (TOP/GUT/MITTEL/SCHLECHT/KRITISCH) with per-metric
  status marks and plain-language recommendations
- Home Assistant integration via native ESPHome API
- Web UI on port 80 with live values, buttons, and log stream
