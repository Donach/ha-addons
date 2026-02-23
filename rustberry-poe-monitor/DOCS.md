# RustBerry PoE Monitor Add-on

This add-on runs the [RustBerry-PoE-Monitor](https://github.com/jackra1n/RustBerry-PoE-Monitor) to control the display and fan of the Raspberry Pi Waveshare PoE HAT (B).

## Prerequisites

### Enable I2C

The add-on requires I2C to be enabled on your Raspberry Pi to communicate with the OLED display and fan controller.

If you are using Home Assistant OS, install the [HassOS I2C Configurator](https://community.home-assistant.io/t/add-on-hassos-i2c-configurator/264167) add-on to enable I2C. After running it, reboot your device and verify that `/dev/i2c-1` is available before starting this add-on.

## Installation

1.  Add this repository to your Home Assistant Add-on Store.
2.  Install the "RustBerry PoE Monitor" add-on.
3.  Start the add-on.

## Configuration

The add-on can be configured via the "Configuration" tab.

### Display

*   **brightness**: OLED brightness level (0-4). Default: 2.
*   **screen_timeout**: Time in seconds before the screen dims (0 to disable). Default: 300.
*   **enable_periodic_off**: Enable periodic display on/off cycle to prevent burn-in. Default: false.
*   **periodic_on_duration**: Duration (seconds) the display stays ON. Default: 10.
*   **periodic_off_duration**: Duration (seconds) the display stays OFF. Default: 20.
*   **refresh_interval_ms**: Refresh interval in milliseconds. Default: 1000.

### Fan

*   **temp_on**: Temperature (Celsius) at which the fan turns on. Default: 60.0.
*   **temp_off**: Temperature (Celsius) at which the fan turns off. Default: 50.0.

## Support

If you encounter issues, please check the add-on logs.
For issues related to the underlying tool, visit the [RustBerry-PoE-Monitor repository](https://github.com/jackra1n/RustBerry-PoE-Monitor).
