#!/usr/bin/env bash
# Compile Traeger ESPHome config (uv + Python 3.12, per esphome skill).
# Build artifacts go to ESPHOME_BUILD_PATH to avoid PlatformIO whitespace path errors.
# PLATFORMIO_BUILD_CACHE_DIR shares compiled objects across ESPHome projects.
set -euo pipefail
export PYTHONUNBUFFERED=1
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" == "Darwin" && -z "${UV_PYTHON:-}" && -x /opt/homebrew/bin/python3.12 ]]; then
  export UV_PYTHON=/opt/homebrew/bin/python3.12
fi

export ESPHOME_BUILD_PATH="${ESPHOME_BUILD_PATH:-$HOME/ESPHome_Projects/traeger-esphome-build}"
export PLATFORMIO_BUILD_CACHE_DIR="${PLATFORMIO_BUILD_CACHE_DIR:-$HOME/.cache/platformio-esphome}"
mkdir -p "$ESPHOME_BUILD_PATH" "$PLATFORMIO_BUILD_CACHE_DIR"

exec uv run esphome "$@" 1Traeger-S3.yaml
