#!/usr/bin/env bash
# =====================================================================
# Rebuild the shipped firmware binaries after a change to the YAML
# =====================================================================
# What this does:
#   1. Runs `esphome compile` on firmware/source/air-quality-monitor.yaml
#   2. Copies the six output binaries into firmware/binary/
#   3. Regenerates SHA256SUMS.txt for verification
#
# When to run:
#   Every time you merge a change to firmware/source/*.yaml into `main`,
#   right before you push. Ensures that firmware/binary/ always matches
#   the source at the current HEAD.
#
# Prerequisites:
#   - Python 3.10+
#   - esphome installed in an accessible Python environment
#     (e.g. `pipx install esphome` or a virtualenv you have already
#     activated). The script will remind you if `esphome` is not on PATH.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
YAML="$REPO_ROOT/firmware/source/air-quality-monitor.yaml"
BINDIR="$REPO_ROOT/firmware/binary"

# Sanity check: esphome available?
if ! command -v esphome >/dev/null 2>&1; then
  echo "error: 'esphome' is not on PATH." >&2
  echo "  install with:  pip install esphome" >&2
  echo "  or activate the venv where it lives before running this script." >&2
  exit 1
fi

# Sanity check: YAML present?
if [ ! -f "$YAML" ]; then
  echo "error: could not find $YAML" >&2
  exit 1
fi

echo "==> Compiling $YAML"
esphome compile "$YAML"

# Locate the build output. ESPHome puts it under .esphome/build/<name>/.pioenvs/<name>/
BUILD_ROOT="$REPO_ROOT/firmware/source/.esphome/build/air-quality-monitor/.pioenvs/air-quality-monitor"
if [ ! -d "$BUILD_ROOT" ]; then
  # Fallback: the build sometimes lands at a different depth depending on
  # ESPHome version. Locate any firmware.factory.bin under .esphome/build/
  BUILD_ROOT="$(find "$REPO_ROOT/firmware/source/.esphome/build" -name "firmware.factory.bin" -printf '%h\n' 2>/dev/null | head -1 || true)"
fi

if [ -z "${BUILD_ROOT:-}" ] || [ ! -d "$BUILD_ROOT" ]; then
  echo "error: could not find the ESPHome build output directory" >&2
  echo "  looked under $REPO_ROOT/firmware/source/.esphome/build/" >&2
  exit 1
fi

echo "==> Build output found at $BUILD_ROOT"

# Copy the standard binaries
mkdir -p "$BINDIR"
for f in bootloader.bin firmware.bin firmware.factory.bin firmware.ota.bin ota_data_initial.bin; do
  if [ -f "$BUILD_ROOT/$f" ]; then
    cp "$BUILD_ROOT/$f" "$BINDIR/"
    echo "    copied $f"
  else
    echo "    warning: $f not found in build output" >&2
  fi
done

# partitions.bin lives one directory further in for ESP-IDF builds
PARTITIONS=$(find "$REPO_ROOT/firmware/source/.esphome/build" -name "partitions.bin" -print 2>/dev/null | head -1 || true)
if [ -n "$PARTITIONS" ] && [ -f "$PARTITIONS" ]; then
  cp "$PARTITIONS" "$BINDIR/"
  echo "    copied partitions.bin"
fi

# Regenerate SHA256SUMS.txt
echo "==> Regenerating SHA256SUMS.txt"
(cd "$BINDIR" && shasum -a 256 *.bin > SHA256SUMS.txt)
cat "$BINDIR/SHA256SUMS.txt"

echo
echo "==> Done. Now review + commit:"
echo "    git add firmware/binary"
echo "    git commit -m 'chore(firmware): rebuild binaries'"
