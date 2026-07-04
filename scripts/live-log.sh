#!/usr/bin/env bash
# =====================================================================
# Stream live logs from a running device into a timestamped file
# =====================================================================
# What this does:
#   Opens the ESPHome native-API log stream against a device on the
#   network and both prints every line to your terminal AND writes a
#   copy to a timestamped file under /tmp. Terminal-Scrollback lets
#   you read history live; the file gives you something to grep,
#   share or attach to a bug report after the session.
#
# When to run:
#   - Debugging weird behaviour on the live device
#   - Watching what happens when you toggle a switch / press a button
#     in the Web UI or in Home Assistant
#   - Capturing DEBUG or VERBOSE output — the two log-level buttons on
#     the device raise the runtime level only; the extra lines
#     stream out through THIS channel, not through the Web UI's
#     small in-page log widget
#
# Usage:
#   ./scripts/live-log.sh <device-ip-or-mdns-name>
#
# Examples:
#   ./scripts/live-log.sh air-quality-monitor.local
#   ./scripts/live-log.sh 192.0.2.42
#
# Prerequisites:
#   `esphome` on PATH — usually a Python venv the way you built the
#   firmware. If you use encryption on your api: block, the API key
#   is picked up automatically from your firmware/source/secrets.yaml.
#
# Stop the stream with Ctrl+C. The captured file stays on disk.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
YAML="$REPO_ROOT/firmware/source/air-quality-monitor.yaml"

if [ $# -lt 1 ]; then
  echo "usage: $0 <device-ip-or-mdns-name>" >&2
  echo "  example: $0 air-quality-monitor.local" >&2
  exit 2
fi

DEVICE="$1"
LOGFILE="/tmp/aq-$(date +%Y%m%d-%H%M%S).log"

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

echo "==> Streaming logs from $DEVICE"
echo "==> Writing to $LOGFILE"
echo "==> Press Ctrl+C to stop"
echo

# `tee` mirrors the stream to stdout AND the file. `exec` replaces the
# shell so Ctrl+C reaches esphome / tee cleanly and the file is closed.
exec esphome logs "$YAML" --device "$DEVICE" 2>&1 | tee "$LOGFILE"
