#!/bin/sh
set -eu

XRAY_BIN="${XRAY_BIN:-/usr/local/share/xray/xray}"
CONFIG="${XRAY_CONFIG:-/etc/xray/config.json}"
ASSET_DIR="${XRAY_LOCATION_ASSET:-/usr/local/share/xray}"

if [ ! -x "$XRAY_BIN" ]; then
  echo "xray binary not found: $XRAY_BIN" >&2
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "config file not found: $CONFIG" >&2
  exit 1
fi

export XRAY_LOCATION_ASSET="$ASSET_DIR"

echo "validating config: $CONFIG"
"$XRAY_BIN" run -test -c "$CONFIG"

echo "starting xray"
exec "$XRAY_BIN" run -c "$CONFIG"
