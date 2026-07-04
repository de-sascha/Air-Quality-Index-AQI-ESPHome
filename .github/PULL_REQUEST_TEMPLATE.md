# Pull Request

## What does this change do?

<!-- One short paragraph. What problem does this solve or what feature
does it add? -->

## Type of change

<!-- Delete the lines that do not apply. -->

- Bug fix (non-breaking change that fixes an issue)
- New feature (non-breaking change that adds functionality)
- Breaking change (fix or feature that would cause existing installs
  to behave differently — e.g. GPIO pin change, AP credential change,
  AQI threshold change)
- Documentation only
- Firmware binary rebuild

## Checklist

- [ ] I am targeting `dev`, not `main` (unless this is a firmware rebuild)
- [ ] I ran `esphome config firmware/source/air-quality-monitor.yaml`
      locally and it succeeded
- [ ] For YAML changes: I flashed the firmware on real hardware and
      the device boots
- [ ] I did not add any secrets, private IPs, home SSIDs or
      personally identifiable information
- [ ] I updated the documentation if user-visible behaviour changed
      (README, wiring doc, CONTRIBUTING)
- [ ] If I changed pin assignments, I updated `docs/hardware/wiring.md`

## Hardware tested on

<!-- If you tested the change on a device, say which one. -->

- [ ] Seeed XIAO ESP32-C6
- [ ] Other: <specify>
- [ ] Not tested on hardware (documentation / CI-only change)

## Additional notes

<!-- Anything else the reviewer should know? -->
