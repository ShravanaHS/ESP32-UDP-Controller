# App Usage Guide

Welcome to ESP32 Control Studio! This guide explains how to install the app, connect it to your ESP32 device, and use the telemetry-rich dual joystick dashboard.

## 1. Installation
Currently, the app is distributed as an APK file for Android devices.
- Download the final release APK from the GitHub.
- Locate the downloaded `app-release.apk` on your phone.
- Tap to install. You may need to enable "Install Unknown Apps" in your security settings.

## 2. Connecting to Your ESP32
Control Studio communicates via **UDP** over your local WiFi network. This ensures ultra-low latency.

1. Power on your ESP32 board and ensure it is connected to the same WiFi Router/Hotspot as your phone.
2. Open the ESP32 Control Studio app.

![Connection Screen](https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/connection_screen.jpg)

3. On the **Connection Screen**, enter the local IP address of your ESP32 (e.g., `192.168.1.100`).
   > You can upload the sample code to esp32 with your wifi credentials and on serial monitor you will get ip address. 
5. Tap **Connect**. The app will validate the IP format and immediately open the dashboard.

## 3. The Control Dashboard
The main dashboard is a custom-designed, landscape-oriented interface tailored for two-hand operation.

![Dashboard Overview](https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/control_panel_active.jpg)

### Dual Joysticks
The dashboard features two analog joysticks.
- **Left Joystick:** Typically mapped to Throttle (Y-axis) and Yaw (X-axis).
- **Right Joystick:** Typically mapped to Pitch (Y-axis) and Roll (X-axis).
- The joysticks output a 0-255 byte value. `128` is absolute dead-center.

![Controller UI Example](https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/control_panel_idle.jpg)

### Control Buttons & Toggles
- **Action Buttons (A, B, X, Y):** Send continuous bitmask states when held down. These are ideal for momentary actions like firing a laser, flashing a light, or honking a horn.
- **Toggle Switches (1, 2, 3, 4):** Latching switches that hold state. Perfect for arming/disarming motors, turning on headlights, or changing driving modes.

## 4. Telemetry Display
The top bar provides essential telemetry data:
- **Connection Status:** Shows active network status.
- **Latency / Ping:** Displays the UDP round-trip time.

![Telemetry Panel](https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/spiderman.gif)

*Note: Telemetry data requires your ESP32 firmware to actively transmit data back to the phone on the predefined return port.*
