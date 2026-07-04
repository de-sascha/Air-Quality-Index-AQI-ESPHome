# Hardware notes

Short reference notes for the four data-carrying components. Every
note lists the **essentials for building this project** (pinout,
bus, supply, timing gotchas) with links to the **authoritative
manufacturer datasheets**. Nothing here replaces the datasheet —
these files exist so you don't have to open a 20-page PDF just to
remember an I²C address or which pin is SET on a Plantower breakout.

The four upstream product pages archived (until v0.2.0) under
`docs/datasheets/*.pdf` were AliExpress listings with mixed marketing
and technical content. They were dropped in favour of these notes
plus links to the real Sensirion / Espressif / Plantower / Seeed
sources.

| Component | Note | Manufacturer datasheet |
|---|---|---|
| Seeed XIAO ESP32-C6 | [xiao-esp32-c6.md](xiao-esp32-c6.md) | [Seeed Wiki](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/) |
| Sensirion SCD41 | [sensirion-scd41.md](sensirion-scd41.md) | [Sensirion SCD4x datasheet (PDF)](https://sensirion.com/media/documents/48C4B7FB/64C134E7/Sensirion_SCD4x_Datasheet.pdf) |
| Plantower PMS5003 | [plantower-pms5003.md](plantower-pms5003.md) | [Plantower PMS5003 manual (PDF)](https://download.kamami.pl/p564359-PMS5003%20series%20data%20manua_English_V2.6.pdf) |
| DOIT ESP32-C6-DevKitC-1 | [doit-esp32-c6-devkitc-1.md](doit-esp32-c6-devkitc-1.md) | [Espressif ESP32-C6-DevKitC-1 docs](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/hw-reference/esp32c6/user-guide-devkitc-1.html) |

Wiring for this specific build lives in
[`../wiring.md`](../wiring.md) — that file is the authoritative
source for what connects to what.
