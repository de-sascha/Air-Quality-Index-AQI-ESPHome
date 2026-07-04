# AirQuality

An open, self-hostable indoor air-quality monitor built on the Seeed XIAO
ESP32-C6, running standard [ESPHome](https://esphome.io/). Measures **CO₂,
temperature, humidity and fine dust (PM1.0 / PM2.5 / PM10)**, translates the
raw numbers into a plain-language traffic-light verdict on a small OLED
display, and integrates natively with **Home Assistant**.

The design goal is that any hobbyist can rebuild the device from off-the-shelf
parts, flash the pre-compiled firmware and be up and running in under an
hour — without ever entering an API key or copying a secret.

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Firmware](https://img.shields.io/badge/firmware-ESPHome%202026.6.4-brightgreen) ![Board](https://img.shields.io/badge/board-XIAO%20ESP32--C6-orange)

---

## What the device does

- **Measures four indoor-air metrics** with two proven sensors:
  - **CO₂** via a Sensirion **SCD41** NDIR sensor (± 40 ppm accuracy)
  - **PM1.0 / PM2.5 / PM10** via a Plantower **PMS5003** laser scattering sensor
  - **Temperature + relative humidity** as a side benefit of the SCD41
- **Rates the air quality on a 5-level scale** (`TOP` / `GUT` / `MITTEL` /
  `SCHLECHT` / `KRITISCH`) using published thresholds:
  - CO₂: Pettenkofer + WHO
  - PM2.5 / PM10: WHO 2021, 24 h mean
  - Humidity: comfort + mould-risk range
- **Recommends actions in plain language** — the display doesn't just show
  numbers, it says *"open the window", "turn air purifier on", "too dry"*
  etc. depending on which metric is the worst.
- **Rotates 4 display pages** every 6 seconds:
  1. **Overall traffic light** — bold verdict word + 5-segment bar + advice
  2. **Climate detail** — CO₂ / Temp / Humidity with per-row status marks
  3. **Particulate matter detail** — PM1.0 / PM2.5 / PM10 with own advice
  4. **System status** — clock, IP, SSID, RSSI
- **Ships an official ESPHome Web UI** on port 80 — every entity is a
  clickable card, log stream is live-streamed to the browser, firmware
  OTA upload is a drag-and-drop form.
- **Integrates with Home Assistant out of the box** via native ESPHome
  API (no Zigbee bridge, no cloud, no MQTT broker required). Home
  Assistant discovers the device automatically over mDNS.
- **Onboards like a commercial device** — first boot opens the Wi-Fi AP
  `AirQuality`, a captive portal walks the owner through picking their
  home Wi-Fi. No serial console, no hard-coded credentials.

## What it looks like

Display page 1, when the air is fine:

```
┌─────────────────────────────────┐
│ LUFTQUALITAET                   │
│ ─────────────────────────────── │
│                                 │
│                                 │
│              GUT                │
│                                 │
│ █ ▁ ▁ ▁ ▁                       │
│            alles gut            │
└─────────────────────────────────┘
```

Display page 1, when CO₂ exceeds 2000 ppm:

```
┌─────────────────────────────────┐
│ LUFTQUALITAET                   │
│ ─────────────────────────────── │
│ ███████████████████████████████ │
│ ██                           ██ │
│ ██        KRITISCH           ██ │
│ ███████████████████████████████ │
│ █ █ █ █ █                       │
│         Fenster auf!            │
└─────────────────────────────────┘
```

The inverted block grows with severity — a critical state literally fills
half the display, so a glance across the room is enough to know something
is wrong.

## Bill of materials

Rough prices are hobby-quantity from AliExpress / Amazon in mid-2026.

| # | Part | Rough price | Notes |
|---|------|------------|-------|
| 1 | Seeed Studio **XIAO ESP32-C6** | ~ € 8 | Look for "XIAO ESP32-C6", not C3. The C6 has the required Wi-Fi 6 and native USB-Serial-JTAG |
| 2 | Sensirion **SCD41** module (with 4-pin header) | ~ € 15 | Purple or black PCB, 13.4 × 21.6 mm. Address is fixed at `0x62` |
| 3 | Plantower **PMS5003** with break-out board "1.25T to 2.54 P2" and cable | ~ € 15 | The break-out is essential — the raw PMS5003 has a 1.25 mm JST that most hobbyists cannot solder |
| 4 | AZ-Delivery 1.3" I²C OLED, **SH1106** controller | ~ € 6 | Read the seller notes carefully. Many 1.3" OLEDs use SSD1306 which needs a different driver. The 0.96" OLEDs are usually SSD1306; the 1.3" ones are usually SH1106 |
| 5 | Jumper wires (female/female) and a small breadboard | ~ € 3 | For the prototype |
| 6 | USB-C cable and 5 V / ≥ 500 mA USB power supply | ~ € 5 | Any decent phone charger works |
| — | **Total** | **~ € 50** | |

All four data-carrying parts (1 – 4) have their manufacturer datasheets
archived under [`docs/datasheets/`](docs/datasheets/).

## Wiring at a glance

```
XIAO ESP32-C6            SCD41           OLED SH1106       PMS5003 (break-out)
────────────             ─────           ───────────       ───────────────────
3V3   ────────────┬──►  VDD    ────────► VCC
                  │
GND   ────────────┼──►  GND    ────────► GND        ─────► GND
                  │
D4 / GPIO22 (SDA) └──►  SDA    ────────► SDA
D5 / GPIO23 (SCL) ────► SCL    ────────► SCL

5V    ─────────────────────────────────────────────────► VCC
D0 / GPIO0 (RX)   ◄─────────────────────────────────── TXD
D1 / GPIO1 (TX)   ─────────────────────────────────► RXD
D3 / GPIO21 (SET) ─────────────────────────────────► SET
```

The detailed pin table, ASCII bus diagram and a list of common
pitfalls are in [`docs/hardware/wiring.md`](docs/hardware/wiring.md).

## Getting started

### 1. Flash the firmware (first time, over USB)

Precompiled firmware for the Seeed XIAO ESP32-C6 lives under
[`firmware/binary/`](firmware/binary/). The file you need for a fresh
device is **`firmware.factory.bin`** — it contains the bootloader,
partition table and application in one image.

```bash
# One-time: install esptool
pip install esptool

# Connect the XIAO over USB-C, then:
cd firmware/binary
esptool.py --chip esp32c6 --port /dev/tty.usbmodem<TAB> \
  --baud 460800 write_flash 0x0 firmware.factory.bin
```

Port names by operating system:

| OS      | Port pattern             |
|---------|--------------------------|
| macOS   | `/dev/tty.usbmodem*`     |
| Linux   | `/dev/ttyACM0`           |
| Windows | `COM3`, `COM4`, …        |

**Integrity check** (optional but recommended):

```bash
shasum -a 256 -c SHA256SUMS.txt
```

All lines should say `OK`.

### 2. Configure Wi-Fi (from your phone)

After the flash completes the device starts a Wi-Fi access point:

- **SSID:** `AirQuality`
- **Password:** `12345678`

1. Join the `AirQuality` network from your phone.
2. Modern iOS and Android open the captive portal automatically. If not,
   browse to `http://192.168.4.1` manually.
3. The portal shows a list of Wi-Fi networks in range — pick yours.
4. Enter the Wi-Fi password of your home network. Save.
5. The device connects to your Wi-Fi and the `AirQuality` AP disappears.

### 3. Add the device to Home Assistant (optional)

If you run Home Assistant on the same network:

1. Open Home Assistant → **Settings** → **Devices & Services**.
2. Home Assistant discovers the device automatically over mDNS and
   shows a card: **"Air Quality Monitor discovered"** → click **Add**.
3. HA generates and stores an API encryption key by itself; no key to
   copy anywhere. All 35+ entities appear immediately.

If auto-discovery does not fire:

- **Add Integration** → **ESPHome** → enter the IP of the device.

### 4. Open the on-device Web UI (optional)

The device serves the official ESPHome web frontend on port 80:

```
http://<ip-of-the-device>/
```

You get:

- **Live values** for every sensor as a card
- **Switches** (currently: `PMS5003 Active`)
- **Buttons**: `Restart`, `Restart (Safe Mode)`, `WiFi Reconnect`,
  `Display Refresh`, `PMS5003 Restart`, `Factory Reset`, and log-level
  switches (`Log INFO / DEBUG / VERBOSE`)
- **Live log stream** at the bottom of the page — very handy for
  spotting problems
- **OTA form** for uploading a new `firmware.ota.bin`

## Recovering a device

If the device ends up on a Wi-Fi you no longer have access to (e.g.
you moved the device to a friend's house or you changed your Wi-Fi
password), there are three ways back to the initial state:

- **From the Web UI:** open `http://<device-ip>/` → **Factory Reset**
  → device reboots into the `AirQuality` AP.
- **From Home Assistant:** press `button.factory_reset` on the device's
  entity page.
- **Over USB:** re-flash `firmware.factory.bin` following step 1.

## Building the firmware yourself

You only need this if you want to change the YAML config, upgrade to a
newer ESPHome release, or verify the binary from source.

Prerequisites: Python 3.10+.

```bash
# Set up an isolated Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install esphome

# Compile from source (produces firmware.factory.bin under .esphome/build/)
esphome compile firmware/source/air-quality-monitor.yaml

# Flash directly over USB
esphome upload firmware/source/air-quality-monitor.yaml
```

The first compile downloads the ESP-IDF toolchain (~ 1 GB) and takes
10–20 minutes. Subsequent compiles are cached and complete in about a
minute.

## Repository layout

```
AirQuality/
├── README.md                          — this file
├── LICENSE                            — MIT
├── .gitignore
├── firmware/
│   ├── source/
│   │   └── air-quality-monitor.yaml   — the single ESPHome config
│   └── binary/
│       ├── bootloader.bin
│       ├── partitions.bin
│       ├── ota_data_initial.bin
│       ├── firmware.bin
│       ├── firmware.factory.bin       — the one to flash on first setup
│       ├── firmware.ota.bin           — the one to upload via Web UI
│       └── SHA256SUMS.txt
└── docs/
    ├── hardware/
    │   └── wiring.md                  — pinouts + bus diagram + pitfalls
    └── datasheets/
        ├── xiao-esp32-c6.pdf
        ├── doit-esp32-c6-devkitc-1.pdf
        ├── scd40-scd41-modul.pdf
        └── pms5003-mit-breakout.pdf
```

## AQI thresholds

The traffic-light categorization uses these breakpoints (also documented
inline in the YAML):

| Metric | 0 = TOP    | 1 = GUT      | 2 = MITTEL   | 3 = SCHLECHT | 4 = KRITISCH |
|--------|-----------|--------------|--------------|--------------|--------------|
| **CO₂ (ppm)** | < 800 | 800 – 1000 | 1000 – 1400 | 1400 – 2000 | ≥ 2000 |
| **PM2.5 (µg/m³, 24 h avg)** | < 10 | 10 – 15 | 15 – 25 | 25 – 37 | ≥ 37 |
| **PM10 (µg/m³, 24 h avg)** | < 20 | 20 – 45 | 45 – 75 | 75 – 150 | ≥ 150 |
| **Rel. humidity (%)** | 40 – 60 | 30 – 65 | 25 – 70 | 20 – 75 | outside |

- CO₂: **Pettenkofer** (1858, still the reference for indoor air) and
  **WHO** guideline values.
- PM: **WHO 2021 Air Quality Guidelines**, 24 h mean interim target 4.
- Humidity: **comfort range** (DIN EN ISO 7730) and **mould-risk zone**.

The **overall score** is the worst of the four category scores.
Temperature is intentionally **not scored** because the SCD41 sits inside
the enclosure and picks up a few degrees of self-heating from the ESP —
any temperature threshold would misfire.

## Roadmap / contributions welcome

- Prebuilt enclosure STL for 3D printing
- Prebuilt firmware for the DOIT ESP32-C6-DevKitC-1 variant (larger,
  breadboard-friendly, has 16 MB flash)
- Localized display labels (currently German)
- Optional battery operation with deep-sleep cycles
- Home Assistant Blueprint for a "ventilate the room" automation
- Support for additional sensors (VOC, ambient light)

Pull requests are welcome. Please keep contributions strictly
free of personal data (no home network SSIDs, no IP addresses of
private networks, no personally identifiable information).

## Credits

- [ESPHome](https://esphome.io) — the entire framework that makes this
  buildable in a weekend.
- [Home Assistant](https://home-assistant.io) — the target integration.
- The **Seeed Studio**, **Sensirion**, **Plantower** and **AZ-Delivery**
  engineering teams for the hardware and their datasheets.
- The **OpenDTU** project for popularising the captive-portal onboarding
  pattern this build follows.

## License

MIT. See [LICENSE](LICENSE).
