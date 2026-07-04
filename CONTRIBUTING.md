# Contributing to AirQuality

Thanks for considering a contribution! This document explains how the
project is developed and how you can join in.

## Branch model

- **`main`** — stable, always in a state you would recommend to a newcomer.
  Every commit on `main` should ideally correspond to a firmware build
  under `firmware/binary/` that has been verified on real hardware.
- **`dev`** — the working branch for the maintainer. Experiments,
  half-finished features and firmware rebuilds land here first.
- **Feature branches** — for larger changes, please branch off `dev`
  with a name like `feat/deep-sleep-mode` or `fix/pms5003-warmup`,
  then open a pull request into `dev`.

Once a batch of changes on `dev` has been verified on hardware, the
maintainer merges `dev` into `main` and publishes new firmware binaries.

## Development loop for the maintainer

If you are the maintainer of your own device and want to change the
firmware, this is the recommended cycle:

```bash
# 1. Get onto dev
git checkout dev
git pull

# 2. Edit the YAML (or docs)
vim firmware/source/air-quality-monitor.yaml

# 3. Compile locally to catch syntax errors
esphome compile firmware/source/air-quality-monitor.yaml

# 4. Flash to your live device over the air
esphome upload firmware/source/air-quality-monitor.yaml --device <ip>

# 5. Watch it work. If the change is a keeper:
git commit -am "feat: something"
git push
```

Because the YAML in this repository does not reference any `!secret`,
you do not need a `secrets.yaml` file. Your personal Wi-Fi credentials
and Home Assistant encryption key live on the ESP itself (in NVS),
not in the repository. As long as you flash over the air, they survive.

## Development loop for contributors

If you do not own the maintainer's hardware but want to propose a
change:

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/<you>/AirQuality
cd AirQuality
git checkout -b feat/<short-description> dev

# Change what you want to change
esphome compile firmware/source/air-quality-monitor.yaml   # sanity check

git commit -am "feat: describe your change"
git push -u origin feat/<short-description>

# Open a pull request against `dev`
```

## What NOT to contribute

- **No credentials.** Do not add Wi-Fi passwords, API keys, OTA
  passwords, personal IP addresses, MAC addresses, home SSIDs or
  any personally identifiable information. The `.gitignore` already
  excludes `secrets.yaml`, but please be careful with pasted logs
  or screenshots.
- **No proprietary firmware or datasheets.** Only manufacturer-published,
  freely redistributable material.
- **No breaking changes without discussion.** Renaming the display
  labels, changing default GPIO pins or changing the AQI thresholds all
  affect people who already flashed the previous release — please open
  an issue first to talk about it.

## Verifying binaries before you flash them

Every commit on `main` that touches `firmware/binary/` also updates
`SHA256SUMS.txt`. Before you flash a downloaded binary:

```bash
cd firmware/binary
shasum -a 256 -c SHA256SUMS.txt
```

All lines should show `OK`.

## Releasing a new firmware build

When the maintainer merges `dev` into `main`:

```bash
git checkout main
git merge --no-ff dev

# Rebuild firmware from the merged main
esphome compile firmware/source/air-quality-monitor.yaml

# Copy the six binaries + regenerate SHA256SUMS
BUILD=.esphome/build/air-quality-monitor/.pioenvs/air-quality-monitor
cp $BUILD/{bootloader,firmware,firmware.factory,firmware.ota,ota_data_initial}.bin \
   firmware/binary/
find .esphome/build -name "partitions.bin" -exec cp {} firmware/binary/ \;
cd firmware/binary && shasum -a 256 *.bin > SHA256SUMS.txt

git add firmware/binary
git commit -m "chore(firmware): rebuild for X.Y.Z"
git push
```

Tag the commit for a proper release:

```bash
git tag -a v0.2.0 -m "0.2.0 — <one-line summary>"
git push --tags
```

## Discussion

If you want to talk about a change before writing code, please open a
GitHub issue. Small talk, ideas and questions are all welcome.
