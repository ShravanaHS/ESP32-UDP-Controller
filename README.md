<div align="center">
  <img src="https://via.placeholder.com/150/000000/FFFFFF/?text=ESP32" alt="Logo" width="150" height="150" />
  
  # ESP32 Control Studio

  A professional, ultra-low latency robotics controller built with Flutter and ESP32.

  [![GitHub release](https://img.shields.io/github/v/release/shravanahs/ESP32-UDP-Controller?style=flat-square)](https://github.com/shravanahs/ESP32-UDP-Controller/releases/latest)
  [![Platform](https://img.shields.io/badge/platform-Android-green.svg?style=flat-square)](#)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](#)
  
</div>

## Project Overview
ESP32 Control Studio is a real-time, cross-platform robotics controller designed to communicate with ESP32 or any UDP-enabled hardware. Designed for ultra-low latency, the system allows users to control robots, drones, or embedded vehicles using a customizable dual-joystick dashboard featuring live telemetry feedback.

### [📥 Download the APK](https://drive.google.com/file/d/1xwh1oCDihZ8jxyN_Y7pKCLaXx3liQVi9/view?usp=sharing) 


---

## 🔥 Features
- **Dual Analog Joysticks:** Precise control mapped cleanly to 0-255 byte values.
- **Ultra-Low Latency UDP:** Fire-and-forget control loop at 50Hz for immediate hardware response.
- **Action Buttons & Toggles:** Configurable switches sent via an efficient bitmask payload.
- **Real-Time Telemetry:** Bi-directional loop allows the ESP32 to stream battery voltage and sensor data back to the dashboard.
- **Cross-Platform Foundation:** Built on Flutter, ready to compile for Android, iOS, or Web.

---

## ⚡ Quick Start

### 1. Hardware Setup (ESP32)
1. Read the [ESP32 Firmware Guide](docs/esp32-firmware.md) to upload the minimal UDP receiver code to your board.
2. Ensure your ESP32 is powered on and connected to the same local WiFi network as your phone.

### 2. Mobile App Setup
1. Install the APK linked above.
2. Open **ESP32 Control Studio**.
3. On the Connection Screen, enter the local IP address printed by your ESP32 (e.g., `192.168.1.100`).
4. Tap **Connect** to open the Dashboard and start controlling!

---

## 📚 Full Documentation

The project includes an extensive array of developer documentation. Dive in to understand the system architecture or learn how to extend it.

- 📖 **[The Development Journey](docs/journey.md)** – *Ideation, tech selection, and problem-solving.*
- 🏛️ **[System Architecture](docs/architecture.md)** – *Mermaid diagrams, app workflows, and data flow.*
- 📱 **[App Usage Guide](docs/app-usage.md)** – *How to navigate the dashboard UI and features.*
- ⚙️ **[ESP32 Firmware Guide](docs/esp32-firmware.md)** – *Connect motors, parse packets, and send telemetry.*
- 📡 **[UDP Protocol Spec](docs/protocol.md)** – *Detailed breakdown of the 8-byte control datagrams.*

---

## 📸 Screenshots

*Note: Add real images inside the `assets/screenshots/` folder.*

| Connection | Dashboard |
|:---:|:---:|
| <img src="assets/screenshots/connection_screen.png" width="250"> | <img src="assets/screenshots/dashboard.png" width="250"> |
| **Telemetry View** | **Controller In Action** |
| <img src="assets/screenshots/telemetry_panel.png" width="250"> | <img src="assets/screenshots/controller_ui.png" width="250"> |

---

<div align="center">
  <sub>Built with ❤️ by Shravana HS.</sub>
</div>
