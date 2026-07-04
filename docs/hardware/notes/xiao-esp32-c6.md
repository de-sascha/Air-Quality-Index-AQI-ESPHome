# Seeed Studio XIAO ESP32-C6

**Manufacturer documentation:**
[Seeed Studio Wiki — XIAO ESP32-C6 Getting Started](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/)

That page is the authoritative source for pinout, electrical
characteristics, current draw, and revision history. When any value
below contradicts the Seeed wiki, believe the wiki.

---

## Role in this project

Main microcontroller. Hosts the ESPHome firmware, drives the I²C bus
(SCD41 + OLED), receives PMS5003 UART frames, hosts the Wi-Fi and
Home Assistant API.

## Chip

- SoC: Espressif **ESP32-C6** (RISC-V)
- Cores: HP core up to 160 MHz, LP core up to 20 MHz
- Memory: 512 KB SRAM, 4 MB flash
- Radios: Wi-Fi 6 (2.4 GHz), Bluetooth 5.0 LE, IEEE 802.15.4
  (Zigbee / Thread), Bluetooth Mesh
- USB-C connector with native USB-Serial-JTAG (no CH340 needed)

## Power

- 5 V input via USB-C
- 3.3 V regulated output on the `3V3` pad — used by this project to
  power the SCD41 and the SH1106 OLED
- Separate 5 V pad — used to power the PMS5003 (which needs 5 V)
- Optional BAT pad for a single-cell Li-ion (not used here)

## Pin mapping (silkscreen ↔ GPIO)

| Silkscreen | GPIO | Used in this project for |
|------------|------|--------------------------|
| D0 | GPIO0 | UART RX from PMS5003 |
| D1 | GPIO1 | UART TX to PMS5003 |
| D2 | GPIO2 | (unused) |
| D3 | GPIO21 | PMS5003 SET pin (sleep/wake) |
| D4 | GPIO22 | I²C SDA |
| D5 | GPIO23 | I²C SCL |
| D6 | GPIO16 | (unused, default UART TX) |
| D7 | GPIO17 | (unused, default UART RX) |
| D8 | GPIO19 | (unused, SPI SCK) |
| D9 | GPIO20 | (unused, SPI MISO) |
| D10 | GPIO18 | (unused, SPI MOSI) |

Silkscreen `D0` on the XIAO maps to **GPIO0**, NOT GPIO2 as
occasional older reference material suggests. An earlier revision of
this project wired the PMS5003 to GPIO2 and received zero bytes.

## Gotchas verified during this project

- **USB-Serial-JTAG is native.** No CH340/CP2102 driver install
  needed on macOS or Linux. On some Windows setups a generic driver
  is auto-installed on first plug.
- **BOOT button = GPIO9** (strapping pin). Do not repurpose GPIO9.
- **The onboard 3V3 regulator can source the SCD41 + SH1106 OLED
  simultaneously** (both are I²C low-power devices). The PMS5003 has
  its own 5 V supply and must NOT be powered from 3V3.
- The XIAO's UART pins (`D6`/`D7` = GPIO16/GPIO17) are unused in this
  build — the PMS5003 UART sits on GPIO0/GPIO1 instead, freeing the
  default UART for USB-Serial-JTAG logging.
