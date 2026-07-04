# Plantower PMS5003 (with 1.25T-to-2.54 mm break-out board)

**Manufacturer documentation:**
- [plantower-pms5003.pdf](../datasheets/plantower-pms5003.pdf) —
  archived local copy of the Plantower PMS5003 V2.3 manual
- [Adafruit product page for the PMS5003](https://www.adafruit.com/product/3686)
  (source of the local copy — Plantower does not publish the manual
  on their own website, Adafruit hosts the copy on their CDN and
  it has become the de-facto public reference)
- [Plantower product listing](https://www.plantower.com/en/products_33/74.html)

Datasheet is authoritative for the UART frame format, timing, and
electrical characteristics. When any value below contradicts the
datasheet, believe the datasheet.

---

## Role in this project

Measures particulate matter concentrations for **PM1.0**, **PM2.5**,
and **PM10** using laser scattering. Provides two of the four AQI
inputs (PM2.5 score, PM10 score).

## Sensor unit

- Metallic blue enclosure, roughly 50 × 38 × 21 mm
- Weight ~55 g
- Contains a laser diode, photodiode, fan, and CPU
- Native connector: 1.25 mm-pitch JST — awkward to hand-solder,
  which is why this project uses a break-out board (see below)
- Concentration ranges reported: `0.3–1.0`, `1.0–2.5`, `2.5–10 µm`
  particle bins

## Break-out board

The one this project uses is silk-screened **`1.25T to 2.54 P2`**
and translates the 8-pin JST into a friendlier 8-pin 2.54 mm header.
Pinout on the 2.54 mm side (P1), reading left-to-right with the
label side up:

| Pin | Silkscreen | Meaning |
|-----|-----------|---------|
| 1 | VCC | +5 V supply |
| 2 | GND | Ground |
| 3 | SET | Sleep/wake — HIGH = active, LOW = sleep |
| 4 | RXD | UART receive (into the sensor) |
| 5 | TXD | UART transmit (out of the sensor) |
| 6 | RST | Hardware reset (active LOW) |
| 7 | NC | Not connected |
| 8 | NC | Not connected |

## Electrical

- Supply voltage: **5 V DC**, NOT 3.3 V. Powering it from 3.3 V will
  either work weakly or not at all.
- Maximum operating current: **~120 mA** (from the AliExpress
  listing; the Plantower manual quotes similar values)
- Logic level on TXD/RXD/SET: **3.3 V** — safe to connect directly
  to the ESP32-C6's 3.3 V GPIOs.

## Wiring in this project

| Break-out pin | Goes to XIAO ESP32-C6 |
|---------------|----------------------|
| VCC (5 V) | 5V pad |
| GND | GND pad |
| SET | D3 / GPIO21 |
| RXD | D1 / GPIO1 (UART TX from the XIAO's perspective) |
| TXD | D0 / GPIO0 (UART RX from the XIAO's perspective) |
| RST | not connected |

**Cross-wired convention:** the sensor's RXD receives what the MCU
transmits, so `RXD ↔ TX` and `TXD ↔ RX`. Getting this backwards is
the most common wiring mistake — the fan spins but no data ever
arrives.

## Timing and behaviour

- **Cold-start warmup:** after power-up or after coming out of sleep
  (SET pin pulled HIGH), the first stable frame takes about **30
  seconds**. Before that, ESPHome logs a few "invalid frame" /
  "checksum mismatch" warnings — normal and expected.
- **Frame rate:** the sensor pushes a new frame every ~1 second in
  active mode.
- **Sleep current:** when SET is LOW, the fan and laser turn off.
  Draw drops to about 2 mA.

## UART parameters

- Baud rate: **9600**
- 8N1 (8 data bits, no parity, 1 stop bit)
- Frame length: 32 bytes, starts with the header `0x42 0x4D` (`BM`),
  ends with a 16-bit checksum

The ESPHome `pmsx003` component (with `type: PMSX003`) handles all
frame parsing — no lambda code needed for the sensor itself.
