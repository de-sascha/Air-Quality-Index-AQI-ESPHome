# Hardware Wiring — Air Quality Monitor

Detailed wiring reference for the XIAO ESP32-C6 build. All pin numbers use
the on-board silkscreen (D0…D10) plus the underlying GPIO number that the
YAML config references.

The full ESPHome YAML is [`firmware/source/air-quality-monitor.yaml`](../../firmware/source/air-quality-monitor.yaml).

## Part list

| # | Part | Role | Interface | Supply |
|---|------|------|-----------|--------|
| 1 | Seeed Studio XIAO ESP32-C6 | Micro-controller | USB-C | 5 V (USB) / 3.3 V (on-board LDO) |
| 2 | Sensirion SCD41 module | CO₂ + temperature + humidity | I²C (`0x62`) | 3.3 V |
| 3 | Plantower PMS5003 with "1.25T-to-2.54" break-out board | Particulate matter PM1.0 / PM2.5 / PM10 | UART (3.3 V TTL) | **5 V**, 120 mA peak |
| 4 | AZ-Delivery 1.3" OLED (SH1106 controller) | 128 × 64 monochrome display | I²C (`0x3C`) | 3.3 V |
| 5 | Jumper wires, breadboard, USB-C cable | — | — | — |

Component notes and links to the authoritative datasheets live under [`docs/hardware/notes/`](notes/).

## XIAO ESP32-C6 pinout (front row, 14 pads)

The silkscreen labels the pads with functional aliases, but the ESPHome YAML
uses GPIO numbers. This table maps them:

| Silkscreen | GPIO | Default function | Used in this build for |
|------------|------|------------------|------------------------|
| D0 / A0    | GPIO0  | GPIO / ADC     | UART RX ← PMS5003 TXD |
| D1 / A1    | GPIO1  | GPIO / ADC     | UART TX → PMS5003 RXD |
| D2 / A2    | GPIO2  | GPIO / ADC     | (unused) |
| D3         | GPIO21 | GPIO           | PMS5003 SET (sleep control) |
| D4         | GPIO22 | I²C SDA        | I²C SDA → SCD41 + OLED |
| D5         | GPIO23 | I²C SCL        | I²C SCL → SCD41 + OLED |
| D6         | GPIO16 | UART TX default | (unused, see note below) |
| D7         | GPIO17 | UART RX default | (unused, see note below) |
| D8         | GPIO19 | SPI SCK        | (unused) |
| D9         | GPIO20 | SPI MISO       | (unused) |
| D10        | GPIO18 | SPI MOSI       | (unused) |
| 3V3        | —      | 3.3 V regulated output | SCD41 VDD, OLED VCC |
| GND        | —      | Ground         | Common ground for all sensors |
| 5V         | —      | USB-Vin passthrough | **PMS5003 VCC** |

> **Silkscreen "D0" is GPIO0, not GPIO2.** Some older Seeed marketing pages
> show a slightly different mapping; the working GPIO for D0 is 0. If your
> PMS5003 stays silent after boot, this is very likely the reason.

> **The default UART pins are D6 (GPIO16, TX) / D7 (GPIO17, RX).** This build
> uses D0 / D1 instead because they are physically closer to the sensor
> position in the enclosure. Both are valid; ESPHome accepts any GPIO for
> a `uart:` component.

## Bus architecture

```
                       ┌──────────────────────────────────────────┐
                       │              XIAO ESP32-C6               │
                       │                                          │
   ┌───USB-C 5 V──────►│ 5V                                       │
   │                   │                                          │
   │           ┌───────┤ 3V3 ─────┬──────► SCD41  VDD             │
   │           │       │          └──────► OLED   VCC             │
   │           │       │                                          │
   │           │  ┌────┤ D4/GPIO22 (SDA) ──┬───► SCD41 SDA        │
   │           │  │    │                   └───► OLED  SDA        │
   │           │  │    │                                          │
   │           │  │  ┌─┤ D5/GPIO23 (SCL) ──┬───► SCD41 SCL        │
   │           │  │  │ │                   └───► OLED  SCL        │
   │           │  │  │ │                                          │
   │           │  │  │ │ D1/GPIO1  (TX)   ─────► PMS5003 RXD      │
   │           │  │  │ │ D0/GPIO0  (RX)   ◄───── PMS5003 TXD      │
   │           │  │  │ │ D3/GPIO21 (SET)  ─────► PMS5003 SET      │
   │           │  │  │ │                                          │
   │           │  │  │ │ GND ─────────────┬───► SCD41 GND         │
   │           │  │  │ │                  ├───► OLED  GND         │
   │           │  │  │ │                  └───► PMS5003 GND       │
   │           │  │  │ └──────────────────────────────────────────┘
   │           │  │  │
   └───────────┼──┼──┼───────────────────► PMS5003 VCC (5 V!)
               │  │  │
      3V3 tied off ─┴─ (Both SCD41 and OLED modules have on-board
                       10 kΩ pull-up resistors on SDA/SCL. Two in
                       parallel is fine. A third slave would need
                       one set disabled to keep the bus in spec.)
```

## Sensor pinouts in detail

### SCD41 module (four-pin header, purple PCB variant shown)

```
 GND  VDD  SCL  SDA
  │    │    │    │
  └────┴────┴────┴──►  cable to XIAO
```

| Pin | XIAO pin | Note |
|-----|----------|------|
| GND | GND | Common ground |
| VDD | 3V3 | Datasheet allows 2.4 – 5.5 V; 3.3 V is chosen so the level matches the OLED for a clean shared bus |
| SCL | D5 / GPIO23 | I²C clock |
| SDA | D4 / GPIO22 | I²C data |

I²C address is fixed at `0x62` and cannot be changed.

### PMS5003 + "1.25T-to-2.54 P2" break-out board

The PMS5003 exposes an 8-pin 1.25 mm JST connector. The break-out board
adapts it to 2.54 mm pin header. Pinout on the break-out (top row of
labels, matching the photo on the AliExpress listing):

```
 VCC  GND  SET  RXD  TXD  RST  NC  NC
  │    │    │    │    │    │
  5V  GND  D3   D1   D0   —
```

| Pin | XIAO pin | Note |
|-----|----------|------|
| VCC | 5V | Sensor requires 5 V for fan + laser; do NOT connect to 3V3 |
| GND | GND | Common ground with the XIAO — the UART won't work without a shared reference |
| SET | D3 / GPIO21 | HIGH = active, LOW = sleep (~200 µA, fan off) |
| RXD | D1 / GPIO1 (ESP TX) | The sensor's RX is the ESP's TX; wires cross over |
| TXD | D0 / GPIO0 (ESP RX) | The sensor's TX is the ESP's RX |
| RST | leave open | Active-low hardware reset, not used here |
| NC  | leave open | — |
| NC  | leave open | — |

The PMS5003 draws about 100 mA during normal operation and up to
120 mA when the fan spins up. Powering it from a XIAO 5V pad that gets
its supply from a marginal USB port sometimes causes brown-outs — use
a decent USB port or supply the sensor from a dedicated 5 V rail if in
doubt.

### AZ-Delivery 1.3" OLED (SH1106 controller)

```
 GND  VCC  SCL  SDA
```

| Pin | XIAO pin | Note |
|-----|----------|------|
| GND | GND | |
| VCC | 3V3 | Module has an on-board LDO but works fine at 3.3 V |
| SCL | D5 / GPIO23 | Shares the bus with SCD41 |
| SDA | D4 / GPIO22 | Shares the bus with SCD41 |

I²C address is `0x3C` (some early revisions use `0x3D` — adjust in the
YAML if applicable).

> **Critical:** the controller is **SH1106**, **not SSD1306**. The pixel
> layouts differ by 2 columns. Selecting the wrong platform in ESPHome
> produces an image shifted by 2 pixels with the leftmost / rightmost
> columns garbled. The YAML uses `platform: ssd1306_i2c` with the
> explicit `model: "SH1106 128x64"` — that combination correctly loads
> the SH1106 driver.

## Common pitfalls

1. **Wrong UART pins.** D0 = GPIO0 on the XIAO ESP32-C6; using GPIO2
   silently receives zero bytes.
2. **PMS5003 on 3.3 V.** The fan needs 5 V. Under-volting the sensor
   produces intermittent data or none at all.
3. **Crossed vs. straight UART.** RX/TX must cross. Sensor RX ↔ ESP TX,
   Sensor TX ↔ ESP RX. Straight-through wiring gets you nothing.
4. **Missing shared ground when powering the PMS5003 from an external
   5 V rail.** UART is a single-ended signal, without a common ground
   reference the ESP sees noise, not data.
5. **SH1106 configured as SSD1306.** See note above.
6. **I²C pull-ups.** Both the SCD41 module and the AZ-Delivery OLED
   include on-board pull-ups. Two in parallel is fine. If you add a
   third I²C slave that also has pull-ups, disable one set.
7. **ESP32-C6 strapping pins.** Avoid GPIO 4, 5, 8, 9, 15 for external
   inputs — wrong levels at boot can drop the chip into the bootloader.
8. **SCD41 automatic self-calibration.** By default the sensor assumes
   it sees ~400 ppm fresh air at least once per week and re-references
   accordingly. In permanently closed rooms this misbehaves — disable
   ASC in that case and manually calibrate at fresh air annually.
