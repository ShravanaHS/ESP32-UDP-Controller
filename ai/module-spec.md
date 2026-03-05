# Module Specification

ESP32 Control Studio

This document defines the responsibilities of each major module in the system.

Clear module definitions prevent feature overlap and maintain modular architecture.

---

# Device Manager

The Device Manager is responsible for handling ESP32 devices.

Responsibilities:

• discover devices on the network
• maintain device list
• connect and disconnect devices
• store device information

---

# Network Manager

The Network Manager handles communication between the app and ESP32.

Responsibilities:

• send control packets
• receive telemetry packets
• perform device discovery
• manage UDP connections

---

# Joystick Widget

The Joystick Widget provides user input for directional control.

Responsibilities:

• capture joystick position
• normalize joystick values
• send joystick data to the network layer

---

# Button Controller

The Button Controller manages push button inputs.

Responsibilities:

• detect button press events
• update button state bits
• update control packet data

---

# Toggle Controller

The Toggle Controller manages toggle switch inputs.

Responsibilities:

• maintain toggle states
• update control packet toggle bits

---

# Telemetry Engine

The Telemetry Engine processes telemetry data received from ESP32.

Responsibilities:

• parse telemetry packets
• update telemetry dashboard
• maintain sensor data history

---

# Layout Builder

The Layout Builder allows users to create custom control dashboards.

Responsibilities:

• add widgets dynamically
• save layout configuration
• load saved layouts

---

# GPIO Controller (Firmware)

This module runs on the ESP32 firmware.

Responsibilities:

• parse control packets
• update GPIO outputs
• control motors, LEDs, or servos

---

# Packet Parser (Firmware)

The Packet Parser decodes incoming control packets.

Responsibilities:

• validate packet structure
• verify checksum
• extract control values

---

# Telemetry Manager (Firmware)

This module generates telemetry packets.

Responsibilities:

• collect sensor data
• encode telemetry packets
• transmit telemetry to the app

---

# Module Design Principle

Each module must:

• have a single responsibility
• remain independent from other modules
• communicate through well-defined interfaces

This ensures the system remains maintainable and scalable.

---

End of Module Specification
