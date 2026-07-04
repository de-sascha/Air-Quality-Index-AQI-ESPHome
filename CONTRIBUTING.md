# Contributing to AirQuality

Thanks for considering a contribution! This document explains how the
project is developed and how you can join in.

## Branch model

- **`main`** — stable, always in a state you would recommend to a newcomer.
- **`dev`** — the working branch for the maintainer. Experiments and
  half-finished features land here first.
- **Feature branches** — for larger changes, please branch off `dev`
  with a name like `feat/deep-sleep-mode` or `fix/pms5003-warmup`,
  then open a pull request into `dev`.

Once a batch of changes on `dev` has been verified on hardware, the
maintainer merges `dev` into `main` and tags a release.

## First-time setup for anyone building this device

Before you can flash or contribute, install ESPHome and create your
own `secrets.yaml`:

```bash
git clone https://github.com/de-sascha/AirQuality
cd AirQuality

python3 -m venv .venv
source .venv/bin/activate
pip install esphome

cp firmware/source/secrets.yaml.example firmware/source/secrets.yaml
# Then edit firmware/source/secrets.yaml and follow the instructions
# inside — generate a fresh API encryption key, pick strong passwords.
```

`firmware/source/secrets.yaml` is git-ignored and MUST never be
committed. Verify with `git status` after saving.

## Development loop for the maintainer

```bash
# 1. Get onto dev
git checkout dev
git pull

# 2. Edit the YAML (or docs)
vim firmware/source/air-quality-monitor.yaml

# 3. Sanity-check the config
esphome config firmware/source/air-quality-monitor.yaml

# 4. Flash to the live device over the air
esphome run firmware/source/air-quality-monitor.yaml --device <ip>

# 5. Watch it work. If the change is a keeper:
git commit -am "feat: something"
git push
```

Wi-Fi credentials are stored on the ESP in NVS after the first
captive-portal onboarding — they survive OTA updates.

## Development loop for contributors

If you do not own the maintainer's hardware but want to propose a
change:

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/<you>/AirQuality
cd AirQuality
git checkout -b feat/<short-description> dev

# Follow the "First-time setup" above to create your own secrets.yaml
# and confirm the YAML compiles for you before you push.

esphome config firmware/source/air-quality-monitor.yaml   # sanity check
esphome compile firmware/source/air-quality-monitor.yaml  # full build

git commit -am "feat: describe your change"
git push -u origin feat/<short-description>

# Open a pull request against `dev`.
```

If you cannot flash on hardware you own, please note that in the PR —
the maintainer will run it on the reference device before merging.

## What NOT to contribute

- **No credentials.** Do not add Wi-Fi passwords, API keys, OTA
  passwords, personal IP addresses, MAC addresses, home SSIDs or
  any personally identifiable information. The `.gitignore` already
  excludes `secrets.yaml`, but please be careful with pasted logs
  or screenshots.
- **No pre-compiled binaries.** The repo is source-only. Every builder
  compiles the firmware locally against their own `secrets.yaml` —
  a shared binary would either leak someone's keys or embed dummy
  keys that provide no protection.
- **No proprietary firmware or datasheets.** Only manufacturer-published,
  freely redistributable material.
- **No breaking changes without discussion.** Renaming the display
  labels, changing default GPIO pins or changing the AQI thresholds all
  affect people who already flashed the previous release — please open
  an issue first to talk about it.

## Releasing

When the maintainer merges `dev` into `main`:

```bash
git checkout main
git merge --no-ff dev
git push

# Tag when meaningful — versions are calendar-based
git tag -a vYYYY.MM.PATCH -m "YYYY.MM.PATCH — <one-line summary>"
git push --tags
```

Version format is `vYYYY.MM.PATCH`: year + month of the release,
plus a `PATCH` counter that starts at `0` and increments within the
same month. So `v2026.07.0` is the first release of July 2026, a
follow-up patch in the same month is `v2026.07.1`, and the first
release of the next month is `v2026.08.0`. Historic tags predating
this scheme (currently only `v0.2.0`) are left untouched.

Update `CHANGELOG.md` with notable changes, especially anything that
would require existing builders to regenerate secrets or re-pair with
Home Assistant.

## Discussion

If you want to talk about a change before writing code, please open a
GitHub issue. Small talk, ideas and questions are all welcome.
