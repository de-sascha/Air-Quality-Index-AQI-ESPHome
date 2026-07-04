# CLAUDE.md — Working guide for Claude Code in this repository

This file is loaded automatically by Claude Code at the start of every
session. It tells Claude how this project works and what conventions to
follow. Human contributors should read [CONTRIBUTING.md](CONTRIBUTING.md)
instead — it says roughly the same, but for humans.

## What this project is

An ESPHome-based indoor air-quality monitor. Hardware: Seeed XIAO
ESP32-C6, Sensirion SCD41, Plantower PMS5003, AZ-Delivery SH1106 OLED.
Runs a traffic-light AQI display and integrates natively with Home
Assistant. See [README.md](README.md) for the user-facing description
and [docs/hardware/wiring.md](docs/hardware/wiring.md) for pinout and
sensor detail.

## Read these before you touch anything

1. [README.md](README.md) — what the project does, bill of materials,
   flashing walkthrough, AQI thresholds.
2. [docs/hardware/wiring.md](docs/hardware/wiring.md) — pin table, bus
   diagram, list of well-known pitfalls (SH1106 vs SSD1306,
   PMS5003 5 V, UART cross-wiring, strapping pins, SCD41 self-heating).
3. [CONTRIBUTING.md](CONTRIBUTING.md) — the branch model
   (main / dev / feature branches) and the local development loop.
4. This file.

Do not skip step 1–3. The rest of this document only makes sense once
you have that context.

## Branch model — always work on `dev`

- `main` is stable. It always matches the firmware shipped under
  `firmware/binary/`. Do NOT commit to `main` directly.
- `dev` is where the maintainer edits YAML and tests on live hardware.
  Land your changes here.
- Larger changes get their own `feat/<name>` or `fix/<name>` branch off
  `dev` and come back via pull request.

If you are asked to make a change and you are on `main`, switch:

```bash
git checkout dev
git pull
```

## The one source-of-truth file

`firmware/source/air-quality-monitor.yaml`.

It is the distribution build. It references **no secrets**, has **no
hardcoded Wi-Fi**, and expects Home Assistant to generate the API
encryption key on first pairing. Personal data lives on the ESP's NVS
(non-volatile storage), never in this repo.

If you are ever about to add `!secret ...` to this YAML, stop and ask
the human. There is almost always a better answer.

## The maintainer's live device

The maintainer runs a production device that this repository controls.
Assume it is reachable at the IP the human tells you. Never hardcode
private IP addresses into commits, comments, or README examples — use
placeholders like `<device-ip>` or `10.20.50.x` if you have to write
one out.

To flash the maintainer's device over the air:

```bash
source /tmp/aq_venv/bin/activate     # or wherever esphome is installed
esphome run firmware/source/air-quality-monitor.yaml --device <ip>
```

`esphome run` compiles and uploads in one step. Compile alone: `esphome
compile <yaml>`. Just upload a pre-built binary: `esphome upload
<yaml> --device <ip>` (fails if there is no build cache yet).

The first compile on a fresh checkout downloads the ESP-IDF toolchain
(~ 1 GB) and takes 10–20 minutes. Subsequent compiles finish in about
a minute.

## Verifying a change on live hardware

The device has the official ESPHome web UI on port 80 and the native
API on port 6053. Two ways to verify a change worked:

1. Open `http://<device-ip>/` in a browser — every entity is a card,
   there is a live log stream at the bottom.
2. Programmatically, use `aioesphomeapi`. The Public-YAML build ships
   without an encryption key, so the connection needs `password=""`
   and NO `noise_psk`:

   ```python
   from aioesphomeapi import APIClient
   client = APIClient(address="<ip>", port=6053, password="")
   await client.connect(login=True)
   info = await client.device_info()
   entities, _ = await client.list_entities_services()
   ```

Never make a substantive change without at least a live device_info()
call to prove it boots.

## Release process — after merging dev into main

```bash
git checkout main
git merge --no-ff dev
./scripts/rebuild-firmware.sh    # regenerates firmware/binary/ + SHA256SUMS
git add firmware/binary
git commit -m "chore(firmware): rebuild for <topic>"
git push
```

Tag a release when meaningful:

```bash
git tag -a v0.2.0 -m "<one-line summary>"
git push --tags
```

Never leave `firmware/binary/` out of sync with `firmware/source/`.
If the source has changed on `main`, the shipped binary must match.

## Things that would break users if you touch them

- **AP fallback SSID and password**: `AirQuality` / `12345678`. This is
  documented in README.md, in the display, and in setup guides.
  Changing them silently would strand every existing device on first
  boot.
- **Default GPIO pins** (see [docs/hardware/wiring.md](docs/hardware/wiring.md)):
  people build hardware from this documentation. A pin change orphans
  every device already in the wild.
- **AQI thresholds** (README.md → AQI thresholds table). They come
  from published standards (Pettenkofer, WHO 2021, DIN EN ISO 7730).
  If someone insists on changing them, insist on a citation.
- **The `platform: ssd1306_i2c` with `model: "SH1106 128x64"` line.**
  A well-meaning refactor to `platform: sh1106_i2c` is technically
  equivalent in current ESPHome versions but has bitten users in
  earlier versions. Leave it alone.

## Things Claude should always do

- Read files with the `Read` tool before editing them, even if you
  think you remember the content — YAML lambdas are sensitive.
- Run `esphome config firmware/source/air-quality-monitor.yaml` after
  any YAML edit to catch schema errors before compiling.
- Before proposing a firmware rebuild, check with `git status` that
  the working tree is clean, and confirm which branch you are on.
- When in doubt about a hardware detail, look at the datasheet PDFs
  under `docs/datasheets/`. Do not guess pin numbers.

## Things Claude should never do

- Commit to `main` directly. Always `dev` or a feature branch.
- Add secrets, API keys, private IPs, home SSIDs, or MAC addresses
  to any committed file. The repository is public.
- Add a `!secret` reference to `air-quality-monitor.yaml`. It would
  break the "no secrets needed" property of the distribution build.
- Force-push to `main` or `dev` without explicit human approval.
- Delete files under `firmware/binary/` unless replacing them via
  `scripts/rebuild-firmware.sh`.

## Working on documentation only?

Docs live in `README.md`, `CONTRIBUTING.md`, `docs/`, and this file.
Doc changes go on `dev` too, get merged into `main`, but do NOT
trigger a firmware rebuild (`firmware/binary/` stays untouched).

## Session opener the maintainer typically uses

If a session starts with something like "wir arbeiten im AirQuality-Repo,
was liegt an?", the expected response is:

1. Confirm current branch (`git branch --show-current`) and clean tree
   (`git status`).
2. Check reachability of the live device if the human names an IP.
3. Wait for the actual task before touching anything.

Do not proactively rewrite files or "improve" things until the human
asks. This is a stable published project — surprise changes are worse
than no changes.
