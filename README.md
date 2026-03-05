<div align="center">
  <img src="https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/consol.png" alt="Logo" width="250" height="250" />
  
  # ESP32 Control Studio

  A Scalable ultra-low latency robotics controller built for ESP32.

<p align="center">
  <a href="https://github.com/shravanahs/ESP32-UDP-Controller">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/ESP32-E63946?style=for-the-badge&logo=espressif&logoColor=white" />
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Flutter-00F2FF?style=for-the-badge&logo=flutter&logoColor=black" />
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/Antigravity-FF00FF?style=for-the-badge&logo=airplay&logoColor=white" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android&logoColor=white" />
</p>
</div>

## Project Overview
ESP32 Control Studio is a real-time, cross-platform robotics controller designed to communicate with ESP32. Designed for ultra-low latency, the system allows users to control robots, drones, or embedded vehicles using a customizable dual-joystick dashboard featuring live telemetry feedback.


### [Download the APK](https://drive.google.com/file/d/1xwh1oCDihZ8jxyN_Y7pKCLaXx3liQVi9/view?usp=sharing) 
### [Spider-Man Theme Based APK](https://drive.google.com/file/d/1nE-RjGA328SlFRj-h8YOPr_3yFCCJF95/view?usp=sharing) 
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
1. Install the [APK linked](https://drive.google.com/file/d/1xwh1oCDihZ8jxyN_Y7pKCLaXx3liQVi9/view?usp=sharing).
2. Open **ESP32 Control Studio**.
3. On the Connection Screen, enter the local IP address printed by your ESP32 (Check through Serial Monitor e.g. `192.168.1.100`).
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
<p align="center">
  <img src="https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/spiderman.gif">
  <br>
  <em>ESP32 UDP Controller Demo</em>
</p>
<div align="center">
<img src="https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/connection_screen.jpg"> 
Connection Screen
<img src="https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/control_panel_active.jpg">
Control Panel
<img src="https://github.com/ShravanaHS/ESP32-UDP-Controller/blob/main/docs/screenshots/control_panel_idle.jpg">
Control Panel

</div>

---
