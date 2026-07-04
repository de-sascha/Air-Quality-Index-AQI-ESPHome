# DOIT ESP32-C6-DevKitC-1 (N4 / N8 / N16 variants)

**Manufacturer documentation:**
- [Espressif ESP32-C6-DevKitC-1 user guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/hw-reference/esp32c6/user-guide-devkitc-1.html)
- [ESP32-C6 datasheet (PDF)](https://www.espressif.com/sites/default/files/documentation/esp32-c6_datasheet_en.pdf)

The Espressif user guide is authoritative for pin layout, power
routing, and download-mode timing. When any value below contradicts
Espressif's page, believe Espressif's page.

---

## Role in this project

**Alternative main board** — not the primary hardware. Listed on the
project roadmap as "prebuilt firmware for the DOIT ESP32-C6-DevKitC-1
variant". The variant is attractive because:

- Larger footprint, breadboard-friendly (2.54 mm pin headers already
  soldered)
- More flash: **N4 = 4 MB, N8 = 8 MB, N16 = 16 MB**
- Two USB-C connectors (one via the CH340 USART-to-USB bridge, one
  native to the ESP32-C6)
- A user-controllable WS2812 RGB LED (GPIO 8 on many DOIT revisions)

At the time of writing, this project's firmware targets only the
Seeed XIAO ESP32-C6. Porting to the DevKitC-1 is a matter of:

1. Adjusting the `esp32.board:` value (likely to `esp32-c6-devkitc-1`
   which is already the case in this project — confirm against
   Espressif's board list).
2. Re-mapping the GPIOs used for I²C and UART, because the DevKitC-1
   exposes different pins on its headers than the XIAO does.
3. Verifying that GPIO 8 (WS2812) does not clash with anything.

## Chip and memory

- SoC: **Espressif ESP32-C6** (same as XIAO), single or dual RISC-V
  cores, HP up to 160 MHz + LP up to 20 MHz
- Radios: Wi-Fi 6, Bluetooth 5.0 LE, IEEE 802.15.4 — identical to
  XIAO from ESPHome's point of view
- Flash options via the product SKU suffix: **N4** (4 MB), **N8**
  (8 MB), **N16** (16 MB)

## Onboard components (visible on the AliExpress QSZNTEC clone)

- ESP32-C6 module labelled `MODEL: ESPC6-32 N4` (or N8/N16)
- WS2812 addressable RGB LED
- **CH340** USART-to-USB bridge on one of the two USB-C connectors
- Second USB-C: native ESP32-C6 USB-Serial-JTAG
- Two buttons: `RST` and `BOOT`
- Two indicator LEDs: `TX` and `RX` for the CH340 side

## Two USB-C connectors — which one for what

- **CH340 USB-C** — legacy path. Serial output goes through a CH340
  chip. Compatible with older flashing tools, needs the CH340 driver
  on Windows.
- **MCU USB-C** — direct connection to the ESP32-C6's built-in
  USB-Serial-JTAG. No driver install, works with `esphome upload`
  out of the box. **This is the preferred connector**.

The AliExpress product page notes: "*Only Type-C to Type-C or Type-C
to Type-A cables that carry data will work. Charge-only cables (as
often shipped with phone chargers) will not connect.*"

## Board size

Roughly **58 × 25.5 mm** (2287 × 1000 mil per the product spec
sheet).

## Not implemented yet

This project ships **no firmware variant** for the DevKitC-1. If you
build it on this hardware and want to contribute, please:

1. Copy `firmware/source/air-quality-monitor.yaml` to a variant file.
2. Adjust the pin numbers to match the DevKitC-1 header layout.
3. Verify against Espressif's user guide, not against product-page
   marketing.
4. Open a pull request against `dev`.
