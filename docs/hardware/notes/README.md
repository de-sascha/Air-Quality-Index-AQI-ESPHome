# Hardware notes

Short reference notes for the four data-carrying components. Every
note lists the **essentials for building this project** (pinout,
bus, supply, timing gotchas) with links to the **authoritative
manufacturer datasheets** — both an archived local copy under
`docs/datasheets/` and the original web source. Nothing here
replaces the datasheet; these files exist so you don't have to
open a 27-page PDF just to remember an I²C address or which pin is
SET on a Plantower breakout.

The four upstream product pages archived until v0.2.0 under
`docs/datasheets/*.pdf` were AliExpress listings with mixed marketing
and technical content. They were replaced by the real manufacturer
datasheets alongside these notes.

| Component | Note | Local datasheet | Web source |
|---|---|---|---|
| Seeed XIAO ESP32-C6 | [xiao-esp32-c6.md](xiao-esp32-c6.md) | *(HTML-only, no PDF)* | [Seeed Wiki](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/) |
| Espressif ESP32-C6 SoC | *(referenced from the XIAO and DevKitC notes)* | [espressif-esp32-c6-datasheet.pdf](../datasheets/espressif-esp32-c6-datasheet.pdf) | [Espressif product page](https://www.espressif.com/en/products/socs/esp32-c6) |
| Sensirion SCD41 | [sensirion-scd41.md](sensirion-scd41.md) | [sensirion-scd4x.pdf](../datasheets/sensirion-scd4x.pdf) | [Sensirion product page](https://sensirion.com/products/catalog/SCD41) |
| Plantower PMS5003 | [plantower-pms5003.md](plantower-pms5003.md) | [plantower-pms5003.pdf](../datasheets/plantower-pms5003.pdf) | [Adafruit product page](https://www.adafruit.com/product/3686) |
| DOIT ESP32-C6-DevKitC-1 | [doit-esp32-c6-devkitc-1.md](doit-esp32-c6-devkitc-1.md) | *(uses the Espressif SoC PDF above)* | [Espressif DevKitC-1 user guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c6/esp32-c6-devkitc-1/user_guide.html) |

Wiring for this specific build lives in
[`../wiring.md`](../wiring.md) — that file is the authoritative
source for what connects to what.

## About the archived PDFs

- **`sensirion-scd4x.pdf`** — official Sensirion SCD4x datasheet,
  fetched directly from `sensirion.com`. Sensirion permits
  redistribution of datasheets for reference use.
- **`espressif-esp32-c6-datasheet.pdf`** — official Espressif
  ESP32-C6 chip datasheet, fetched directly from `espressif.com`.
- **`plantower-pms5003.pdf`** — the Plantower PMS5003 V2.3 manual as
  hosted on Adafruit's product-file CDN. Plantower does not publish
  the manual on their own website; Adafruit's copy is the most
  reliable public source and has been the reference used by many
  open-source PM-sensor projects.
