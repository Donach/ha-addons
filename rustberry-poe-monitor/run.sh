#!/bin/bash
set -e

export HOME=/root
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

# Check for I2C devices
I2C_DEVICES=$(ls /dev/i2c-* 2>/dev/null || true)
if [ -z "$I2C_DEVICES" ]; then
    echo "ERROR: No I2C devices found (/dev/i2c-*)!"
    echo "I2C must be enabled on your Raspberry Pi."
    echo "In Home Assistant: Settings > System > Hardware > (three dots) > Configure > Enable I2C"
    echo "A reboot is required after enabling I2C."
    exit 1
fi

echo "Found I2C devices: $I2C_DEVICES"

if [ ! -e /dev/i2c-1 ]; then
    echo "WARNING: /dev/i2c-1 not found, but other I2C buses exist: $I2C_DEVICES"
    echo "The RustBerry binary expects /dev/i2c-1. Creating symlink from first available bus..."
    FIRST_BUS=$(echo "$I2C_DEVICES" | head -n1)
    ln -sf "$FIRST_BUS" /dev/i2c-1
    echo "Linked $FIRST_BUS -> /dev/i2c-1"
fi

echo "Starting RustBerry PoE Monitor..."

exec /usr/local/bin/rustberry-poe-monitor
