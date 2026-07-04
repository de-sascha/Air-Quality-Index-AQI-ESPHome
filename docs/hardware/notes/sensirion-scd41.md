# Sensirion SCD41

**Manufacturer documentation:**
- [sensirion-scd4x.pdf](../datasheets/sensirion-scd4x.pdf) — archived
  local copy of the official Sensirion SCD4x datasheet
- [Sensirion SCD4x datasheet on sensirion.com](https://sensirion.com/media/documents/48C4B7FB/64C134E7/Sensirion_SCD4x_Datasheet.pdf)
  (source of the local copy)
- [Sensirion SCD41 product page](https://sensirion.com/products/catalog/SCD41)

Datasheet is authoritative for accuracy, timing, and register-level
communication. When any value below contradicts the datasheet,
believe the datasheet.

---

## Role in this project

Measures **CO₂**, **temperature**, and **relative humidity** using
photoacoustic NDIR sensing. Provides three of the four AQI inputs
(CO₂ score, humidity score, comfort-range checks).

## Bus

- **I²C**, fixed address **0x62** (not changeable)
- Standard-mode / Fast-mode compatible; this project runs the I²C
  bus at 400 kHz alongside the SH1106 OLED at 0x3C.

## Pinout of the SCD41 module (the small break-out board sold on
AliExpress under the "AITEXM ROBOT" or similar brand):

| Pin | Meaning |
|-----|---------|
| VDD | Positive supply |
| GND | Ground |
| SCL | I²C clock |
| SDA | I²C data |

Only four pins — no interrupt, no ready-signal on this break-out.
Polling over I²C is used.

## Electrical

- Supply voltage: **2.4 – 5.5 V** (the SCD40/41 datasheet gives
  3.3 V as typical). This project powers it from the XIAO's 3V3 pad.
- Communication level: 3.3 V logic
- Board size: ~13.4 × 21.6 mm

## Measurement characteristics

- CO₂ measurement range: **400 – 5000 ppm** (SCD41; the older SCD40
  spans only 400 – 2000 ppm)
- CO₂ accuracy: **±(40 ppm + 5 % of reading)** for the SCD41
- Includes on-chip temperature + humidity compensation
- Datasheet target for low-power operation: `< 0.4 mA average @ 5 V,
  one measurement every 5 minutes`

## Timing gotchas

- **Warmup:** the first stable reading after power-on takes roughly
  5 seconds in periodic-measurement mode; ESPHome logs a couple of
  "no measurement available yet" hints during that window — normal.
- **Self-heating:** the SCD41 warms itself and its immediate
  surroundings by a couple of °C, especially inside a closed
  enclosure. This is why the display DOES show the temperature but
  the AQI logic **does NOT** score it — any threshold on the raw
  temperature would misfire from self-heating. See
  `firmware/source/air-quality-monitor.yaml` for the comment
  explaining the deliberate exclusion.
- **Automatic self-calibration (ASC):** the SCD41 uses the lowest
  CO₂ value it has seen in a rolling window as a fresh-air baseline
  (~400 ppm). If the device runs for weeks without ever being in
  fresh air, readings drift. Airing the room daily is the mitigation.

## SCD40 vs SCD41 (from the AliExpress spec table on the product
listing this project's parts came from)

| | SCD40 | SCD41 |
|--|-------|-------|
| CO₂ measurement accuracy | ±(50 ppm + 5 % MV) | ±(40 ppm + 5 % MV) |
| Typical relative humidity accuracy | 6 %RH | 6 %RH |

The SCD41 is the recommended part for this project.
