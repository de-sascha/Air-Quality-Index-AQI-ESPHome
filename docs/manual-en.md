# User Manual — Air Quality Monitor

**Language:** English · **Sprache:** [Deutsche Version →](manual-de.md)

This manual explains what every reading and control in the Web UI and in Home Assistant means, what it measures, when you'd want to change it, and what happens when you do. It's written for people who want to operate the device without reading the technical datasheets.

If you want to know *how* the device is built or *why* a specific threshold is set the way it is, see the [README](../README.md) for building and the [AQI rationale](aqi-basis.md) for threshold sources.

## Table of contents

1. [Getting started: what does the device measure?](#getting-started-what-does-the-device-measure)
2. [The traffic light system (AQI)](#the-traffic-light-system-aqi)
3. [Calibration — when and why](#calibration--when-and-why)
4. [Readings in detail](#readings-in-detail)
5. [Settings for the SCD41 sensor (CO₂, temperature, humidity)](#settings-for-the-scd41-sensor-co-temperature-humidity)
6. [Settings for the PMS5003 sensor (particulate matter)](#settings-for-the-pms5003-sensor-particulate-matter)
7. [Display settings](#display-settings)
8. [Night mode](#night-mode)
9. [System functions](#system-functions)
10. [Diagnostic values](#diagnostic-values)
11. [Frequently asked questions](#frequently-asked-questions)

---

## Getting started: what does the device measure?

The device measures four things that together give a picture of your indoor air:

| What | Why it matters |
|---|---|
| **CO₂ (carbon dioxide)** | Rises in closed rooms from breathing. Too much CO₂ makes you tired, unfocused, and is the main reason people notice "stuffy" air. Outdoors is about 420 ppm; indoors should stay below 1000 ppm. |
| **PM 1.0, PM 2.5, PM 10 (particulate matter)** | Small particles in the air. The smaller they are, the deeper they penetrate the lungs. Come from cooking, candles, smoking, and from outdoor traffic. |
| **Temperature** | Self-explanatory, but more important than you'd think for the humidity assessment. |
| **Humidity** | Too dry → mucous membranes get irritated, respiratory infections get easier. Too humid → mould risk. Comfort range: 40–60 %. |

Two physical sensors do the work:

- The **SCD41** from Sensirion measures CO₂, temperature, and humidity via infrared absorption. It's a high-quality sensor with ±40 ppm accuracy.
- The **PMS5003** from Plantower measures particulate matter via laser scattering. It has a small fan you can hear quietly running — it pulls room air through the measurement chamber.

All other values in the Web UI are computed from these measured values.

---

## The traffic light system (AQI)

"AQI" stands for **Air Quality Index**. The device computes a class from **0 to 4** for each measurement, independently:

| Class | German | English | Colour |
|---|---|---|---|
| **0** | TOP | TOP | green |
| **1** | GUT | GOOD | blue-green |
| **2** | MITTEL | FAIR | yellow |
| **3** | SCHLECHT | POOR | orange |
| **4** | KRITISCH | CRITICAL | red |

The worst single class determines the **overall verdict** ("AQI Overall Score"). This is deliberately conservative: if one metric is critical, you should act on it, even if the other three look perfect.

Thresholds come from published standards (WHO 2021, Pettenkofer 1858, DIN EN ISO 7730). Details in [aqi-basis.md](aqi-basis.md).

Real-world examples:

- Waking up in a closed bedroom: **CO₂ often 1200–1800 ppm**, class 2–3 → open window.
- Cooking (frying): **PM 2.5 briefly 50–200 µg/m³**, class 4 → hood on, ventilate afterwards.
- Lit a candle: **PM 2.5 immediately 100+ µg/m³**, class 4 → blowing it out produces even more smoke than the burning itself.
- Winter, heating on: **humidity often 25–30 %**, class 2 → hang laundry indoors or add plants.

---

## Calibration — when and why

The SCD41 arrives pre-calibrated from the factory. But there are two situations where you should calibrate yourself:

**1. When the displayed temperature is too high.**

The SCD41 chip sits inside the enclosure next to the ESP32, which warms it slightly. So the sensor typically reads **2–6 °C too warm** compared to actual room air. You correct this with the **Temperature Offset** setting.

**2. When CO₂ readings drift over time.**

CO₂ sensors drift with time. The SCD41 has automatic self-calibration (ASC) which treats the lowest value from the last 7 days as "fresh air = 400 ppm". This only works if your room gets ventilated regularly. If it never does, you can manually calibrate with **Force Recalibration Now**.

For both cases you'll find the right settings in the SCD41 section below. If you're unsure: **the factory setting is fine for normal use.**

---

## Readings in detail

These values are measured and displayed. You can't directly modify them, but they're the basis for every rating.

### CO2

**What it shows:** Carbon dioxide concentration in ppm (parts per million).

**What's normal:**
- Outdoor fresh air: ~420 ppm (as of 2026, rising slowly)
- Indoor well-ventilated: 500–700 ppm
- Normal indoor room air: 700–1000 ppm
- Elevated: 1000–1400 ppm (concentration drops noticeably)
- Bad: 1400–2000 ppm (noticeable tiredness, possible headache)
- Critical: over 2000 ppm

**When to act:** At over 1000 ppm, open a window for 5 minutes, shock-ventilate.

### Room Temperature

**What it shows:** The air temperature measured by the sensor in degrees Celsius, already **corrected** by the Temperature Offset.

Example: if the raw sensor chip reads 30 °C and you've set the offset to 4.0 °C, 26 °C will be displayed.

**When to act:** If the displayed value doesn't match a reference thermometer in the same room, adjust the Temperature Offset (see below).

### Humidity

**What it shows:** Relative humidity in percent.

**What's normal:**
- Comfort range: 40–60 %
- Winter with heating: often only 25–35 % (too dry)
- After a shower in the bathroom: briefly 70–90 % (too humid, but normal — ventilates out)
- Mould-risk zone: continuously above 65–70 %

**When to act:** If continuously below 30 %, use a humidifier or hang laundry indoors; if continuously above 65 %, find the source and ventilate.

### PM 1.0, PM 2.5, PM 10 (particulate mass)

**What it shows:** How much particulate matter is in the air, in micrograms per cubic metre (µg/m³), split by particle size:

- **PM 1.0** — very small particles (up to 1 micrometre). These are the most health-relevant because they penetrate deepest into the lungs. Come primarily from combustion (cooking, candles, smoking, traffic).
- **PM 2.5** — small particles (up to 2.5 micrometres). Includes PM 1.0 and everything up to 2.5 µm. The most important value for the traffic light.
- **PM 10** — coarse dust (up to 10 micrometres). Pollen, disturbed household dust, road aerosols.

**What's normal (indoors, no active event):**
- All three values: under 5 µg/m³, often 0 µg/m³ in clean air.

**What's an alarm signal:**
- PM 2.5 above 15 µg/m³ for longer than briefly → look for source
- PM 2.5 above 37 µg/m³ → turn on air purifier, close windows if the source is outside

**Note on resolution:** The PMS5003 per datasheet cannot distinguish finer than 1 µg/m³, and in the 0–10 µg/m³ range has ±10 µg/m³ tolerance. A "0" reading doesn't guarantee true zero, but "below sensor resolution". That's why the particle counts (next section) also exist.

### Particles > 0.3 / 0.5 / 1.0 / 2.5 / 5.0 / 10 µm (particle counts)

**What it shows:** The **number** of individual particles above the respective size, in "particles per 0.1 litre of air" (pcs/0.1L).

Why important: The mass values above (µg/m³) systematically underestimate small particles, because a single 10 µm particle weighs about as much as **40,000 particles at 0.3 µm**. If we only showed mass, we could miss that lots of fine particles are around.

**Practical example:**

Clean indoor air:
- PM 2.5 = 0 µg/m³ (below resolution)
- Particles > 0.3 µm = **200–500** pcs/0.1L (that's already quite a lot of particles, they're just too light)

Candle at 1 m distance:
- PM 2.5 can jump to 400 µg/m³
- Particles > 0.3 µm can jump to **60,000+** pcs/0.1L

**What's normal:** For the smallest size (> 0.3 µm) a few hundred to a few thousand pcs/0.1L indoors. Numbers drop steeply with larger classes: > 2.5 µm are often 0–5 pcs/0.1L in clean air.

### AQI scores (five values)

All five are derived and not directly editable:

- **AQI CO2 Score** — class 0–4 for the current CO₂ value
- **AQI Humidity Score** — class 0–4 for humidity
- **AQI PM2.5 Score** — class 0–4 for particulate PM 2.5
- **AQI PM10 Score** — class 0–4 for coarse dust PM 10
- **AQI Overall Score** — the worst of the four above

### Air Quality Verdict

**What it shows:** One word — TOP, GOOD, FAIR, POOR, or CRITICAL — corresponding to the AQI Overall class. In German: TOP, GUT, MITTEL, SCHLECHT, KRITISCH. The language follows the Language setting.

### Air Quality Action

**What it shows:** A short action hint based on the worst single measurement. Examples:

- "all good" (when everything is class 0)
- "Open window!" (critical CO₂)
- "Purifier MAX!" (critical particulate)
- "too humid, vent"
- "too dry"

### Dust Action

**What it shows:** A specific hint just for particulate matter, independent of CO₂ or humidity. Examples:

- "all clean"
- "slightly elevated"
- "Source? (cooking?)"
- "Purifier on!"
- "Purifier MAX, shut!" (purifier to max, windows shut)

---

## Settings for the SCD41 sensor (CO₂, temperature, humidity)

These values you can adjust.

### Temperature Offset

**What it does:** Subtracts a fixed value from the raw measured temperature. Formula inside the sensor: `displayed = raw − offset`.

**When to change it:** When your sensor shows a different temperature than a reference thermometer in the same room.

**Which way:**
- Sensor reads **too warm** → **increase** offset (e.g. from 4.0 to 6.5)
- Sensor reads **too cold** → **decrease** offset (e.g. from 4.0 to 2.5)

**Example:** Sensor shows 32 °C, your reference thermometer shows 27 °C. Difference: 5 °C too warm. Old offset (e.g. 4.0) plus 5 = **new offset 9.0 °C**.

**Factory value:** 4.0 °C (Sensirion factory default, works for many enclosures)

**Range:** 0–20 °C in 0.1 °C steps (text-field input, fine values like 9.5 are possible)

**What happens after changing:**
- After about 5 seconds, first new measurement
- After 30–60 seconds, the value truly settles (the sensor averages internally)
- The new offset is stored on the ESP in NVS, so a normal reboot preserves it

**Important to know:** Changes are only stored in ESP memory, not directly in the sensor's own EEPROM. For permanent storage *inside the sensor itself*, press the "Save Offset to Sensor EEPROM" button (see below).

### Altitude (m)

**What it does:** CO₂ measurement is pressure-dependent. At higher altitudes the air is thinner, so the sensor systematically reads too low. Telling it your altitude lets it compensate internally.

**When to change it:** Once, after initial setup, when you know how many metres above sea level you live (Google "altitude" plus your city).

**Rough effect:**
- Sea level (0 m): no correction needed
- 500 m altitude: without correction, readings are ~1.5 % too low
- 1000 m: ~3 % too low
- 2000 m (mountain cabin): ~6 % too low

**Factory value:** 0 m

**Range:** 0–3000 m

**Example:** If you live in Denver (~1600 m), set the value to 1600.

### Reference CO2 (ppm) — reference value for manual calibration

**What it does:** Stores the CO₂ value against which the sensor should re-anchor itself the next time you press "Force Recalibration Now".

**When to change it:** Only if you're doing a manual CO₂ calibration — that is, taking the device outside (or to a well-ventilated location) and telling the sensor "there's 420 ppm here right now, adjust your zero point accordingly".

**Factory value:** 420 ppm — the global fresh-air value (as of 2026; more like 430 in urban areas, 410 in rural).

**If you're unsure:** Leave it at 420. For 99 % of calibration situations, that's the right value.

### Auto Calibration (ASC)

**What it does:** When ASC is on, the sensor searches for the **lowest** CO₂ value seen in the last 7 days and assumes: "That must have been fresh air → 400 ppm." Then it corrects itself internally.

**When to leave it on:** In most apartments that are ventilated regularly (at least once a week). The sensor stays accurate over months without you doing anything.

**When to turn it off:**
- A room that never gets ventilated (e.g. server room, closed office over a long weekend)
- A room with permanently elevated CO₂ (e.g. a greenhouse)

If ASC is on in such a room, the sensor will eventually think its lowest value (e.g. 800 ppm) is fresh air and rescale it down to 400. After that the sensor reads **permanently 400 ppm too low**. In that case, turn ASC off and calibrate manually once.

**Factory value:** On.

### Save Offset to Sensor EEPROM (button)

**What it does:** Saves the current Temperature Offset setting permanently **inside the sensor chip itself** (in its EEPROM). Without this action, the offset is only saved on the ESP.

**When to press it:** When you're confident the current offset is right, and you want it kept inside the sensor even after a firmware reflash (which could wipe the ESP memory).

**Don't press often:** The sensor EEPROM tolerates only about 2000 write cycles per the manufacturer. One deliberate press per calibration session is exactly right. Not on every small change.

### Force Recalibration Now (button)

**What it does:** Triggers a manual calibration. The sensor assumes: "The current raw value corresponds to the value in the Reference CO2 field." Internal zero-point shift accordingly.

**The right procedure:**
1. Take the device outside (shady, away from busy roads, away from people — including your own exhaling self, min. 2 m distance)
2. Wait. The sensor needs **at least 3 minutes** for readings to stabilise
3. Make sure "Reference CO2" is set to a sensible value (420 ppm is standard)
4. Press "Force Recalibration Now"
5. Wait a few minutes. The CO₂ value should approach your reference value

**Possible mistake:** If the sensor hasn't been running for at least 3 minutes before you press, it ignores the calibration. No error, just no effect.

### Reset Sensor Calibration (button)

**What it does:** Resets **all** SCD41 calibration settings to factory state:
- Temperature Offset → 4.0 °C
- Altitude → 0 m
- ASC → on
- Reference CO2 → 420 ppm
- Internal chip calibration history → cleared

The sensor is then indistinguishable from a freshly unboxed one.

**When to press it:** If you've messed up something during calibration and don't remember what, or if you're giving the device to someone else and want to give them a clean starting point.

**What is NOT deleted:** Wi-Fi settings, display settings, night-mode times. If you really want everything reset, press "Factory Reset" in the System group.

---

## Settings for the PMS5003 sensor (particulate matter)

### PMS5003 Active (switch)

**What it does:** Turns the particulate sensor on or off. Off means: the fan inside the sensor stops and the laser measurement pauses. The sensor then only draws about 2 mA of current instead of ~100 mA.

**When to change it:** Rarely. Might make sense if you want quiet for a few minutes (quiet fan noise). For daily use: leave on.

**Factory value:** On.

### PMS5003 Restart (button)

**What it does:** Restarts the sensor (briefly off, then on again). Can help if readings hang or become implausible after a long time.

**Important:** After the restart, the sensor needs about **30 seconds warmup** before readings are stable.

---

## Display settings

### Display Brightness

**What it does:** Regulates OLED display brightness from 0 to 100 percent. 0 means: display is on but completely black.

**Factory value:** 50 % (pleasant for most rooms, not too bright in the dark)

**When you'd change it:** Up to 100 % for very bright environments (direct sunlight), down to 20–30 % for bedside areas.

### Display Rotation

**What it does:** Rotates the display in 90° steps (0°, 90°, 180°, 270°). This lets you mount the display in your enclosure in any orientation.

**Factory value:** 0° (default).

### Display Power (switch)

**What it does:** Turns the display completely off (panel driver disabled, not just black pixels). Saves about 15 mA and prevents OLED burn-in.

**Factory value:** On.

**When to turn it off:** If you use the device only as an HA sensor and don't want to look at the display.

### Display Refresh (button)

**What it does:** Forces an immediate redraw of the display. Not normally needed — only for testing when something looks odd.

---

## Night mode

Blanks the display in a configurable time window while the sensors keep measuring. Handy for bedrooms.

### Night Mode Enabled (switch)

**What it does:** Activates or deactivates the time-controlled display shut-off.

**Factory value:** Off. Activate if you don't want to see the device glow at night.

### Night Mode Start / Night Mode End (time fields)

**What it does:** Defines the time window during which night mode is active. The window may wrap over midnight (e.g. start 22:00, end 07:00).

**Suggestion:** 22:00 – 07:00 for a normal bedroom.

**If start = end:** Night mode never activates.

**What happens during this time:** Display is completely off. Sensors keep running, Home Assistant history stays continuous.

---

## Language

### Language (selection)

**What it does:** Switches the language of all display texts — both on the OLED and in the assessment texts in Home Assistant and Web UI.

**Options:** English, Deutsch

**What's affected:**
- Words like "GOOD" / "FAIR" / "POOR" / "CRITICAL" ↔ "GUT" / "MITTEL" / "SCHLECHT" / "KRITISCH"
- Action hints like "Open window!" ↔ "Fenster auf!"
- Dust hints like "dust-free" ↔ "staubfrei"
- Date formats on the display (EN: 2026-07-07 vs. DE: 07.07.2026)

**What is NOT affected:**
- The names of the settings themselves (stay English, so Home Assistant automations don't break)
- Values like CO₂ or temperature (those are numbers, not language)

**Factory value:** English.

---

## System functions

### Restart (button)

**What it does:** Restarts the device. All settings are preserved (Wi-Fi, calibration, night mode).

**When to press it:** If something hangs or a sensor value stops updating.

### Restart (Safe Mode)

**What it does:** Boots the device in a special mode that loads only basic functions (Wi-Fi and web server). All sensors and the display stay off.

**When to press it:** If, after a firmware update, the device no longer starts properly. In safe mode you can upload a different firmware image.

### WiFi Reconnect

**What it does:** Restarts the Wi-Fi connection. Often useful after a router change or router restart.

### Factory Reset

**What it does:** Deletes **all** user-made settings. The device is then like factory-new:
- Wi-Fi credentials gone → next time QR-code onboarding again
- All calibration values to factory
- Display settings to default
- Night-mode times to default
- Language to English

**When to press it:** If you're giving the device away or setting it up completely fresh.

**Warning:** This produces no "are you sure" dialog. One click suffices.

---

## Diagnostic values

These values help troubleshooting but are uninteresting in daily use.

- **IP Address** — The network address of the device. Needed to open the Web UI.
- **SSID** — The name of the Wi-Fi the device is currently on.
- **MAC** — The unique hardware address of the device (interesting only if you want to whitelist it in the router).
- **WiFi RSSI** — Wi-Fi signal strength in dBm. −50 is very good, −70 medium, −85 borderline, below −90 the connection drops.
- **Uptime** / **Uptime (human)** — How long the device has been running without restart.
- **ESPHome Version** — Firmware version.
- **Boot Reason** — Why the device last restarted (Software = normal restart, Brownout = brief power interruption, Panic = a firmware error).
- **CPU Temperature** — Internal chip temperature of the ESP32, not the room temperature.
- **Free Heap** / **Max Heap Block** — Free working memory in bytes. Interesting only for firmware development.

Plus log-control buttons:
- **Log INFO (Default)** — normal log verbosity
- **Log DEBUG On** — more detail for troubleshooting
- **Log VERBOSE On** — very much detail, activate only briefly

---

## Frequently asked questions

**The sensor shows 0 µg/m³ particulate. Is it broken?**

Probably not. The PMS5003 has 1 µg/m³ resolution and ±10 µg/m³ tolerance in the low range. In clean indoor air, "0" is a normal and correct reading. Sanity check: the particle counts (Particles > 0.3 µm) should still show a value in the range of a few hundred. If those are also 0 → check the sensor.

**I've changed the Temperature Offset but the temperature doesn't change.**

Wait 60 seconds. The sensor needs several measurement cycles after any offset change to deliver a stable new value.

**Why is the Room Temperature so high, when the room feels cool?**

The sensor sits in the enclosure, the ESP32 next to it produces waste heat. The sensor therefore typically reads 2–6 °C too warm. The Temperature Offset corrects this. Factory value is 4.0 °C, which fits many enclosures. If your enclosure is especially small/tight, you may need 6–9 °C.

**My CO₂ values don't drop overnight even though I'm alone.**

Possible you closed your bedroom door — then CO₂ from your breathing accumulates. Overnight values of 1200–1800 ppm are normal. Not dangerous, but the reason you notice "stuffy air" in the morning.

**After a Factory Reset my values are still there.**

You probably haven't reflashed the device with the new firmware — you only pressed the button. After a Factory Reset the device must reconnect to Wi-Fi (via QR code), and **only then** do the new factory settings apply.

**Can I use the device in my car?**

In principle yes, but the PMS5003 doesn't like vibrations and the operating temperature window is limited (−10 to +60 °C). Don't leave it in direct sunlight on the dashboard.

---

*This manual is maintained together with the project. If something is unclear or missing, [please open an issue on GitHub](https://github.com/de-sascha/Air-Quality-Index-AQI-ESPHome/issues).*

*[Deutsche Version →](manual-de.md)*
