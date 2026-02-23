#!/bin/bash
set -e

CONFIG_DIR="/root/.config/rustberry-poe-monitor"
CONFIG_FILE="$CONFIG_DIR/config.toml"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

echo "Reading configuration from options.json..."

# Extract values using jq
BRIGHTNESS=$(jq -r '.display.brightness' /data/options.json)
SCREEN_TIMEOUT=$(jq -r '.display.screen_timeout' /data/options.json)
ENABLE_PERIODIC_OFF=$(jq -r '.display.enable_periodic_off' /data/options.json)
PERIODIC_ON_DURATION=$(jq -r '.display.periodic_on_duration' /data/options.json)
PERIODIC_OFF_DURATION=$(jq -r '.display.periodic_off_duration' /data/options.json)
REFRESH_INTERVAL_MS=$(jq -r '.display.refresh_interval_ms' /data/options.json)
TEMP_ON=$(jq -r '.fan.temp_on' /data/options.json)
TEMP_OFF=$(jq -r '.fan.temp_off' /data/options.json)

echo "Generating config.toml..."

cat > "$CONFIG_FILE" <<EOF
[display]
brightness = ${BRIGHTNESS}
screen_timeout = ${SCREEN_TIMEOUT}
enable_periodic_off = ${ENABLE_PERIODIC_OFF}
periodic_on_duration = ${PERIODIC_ON_DURATION}
periodic_off_duration = ${PERIODIC_OFF_DURATION}
refresh_interval_ms = ${REFRESH_INTERVAL_MS}

[fan]
temp_on = ${TEMP_ON}
temp_off = ${TEMP_OFF}
EOF

echo "Configuration generated at $CONFIG_FILE"
echo "Starting RustBerry PoE Monitor..."

exec /usr/local/bin/rustberry-poe-monitor
