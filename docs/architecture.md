# System Architecture

The ESP32 Control Studio is designed with a clear separation of concerns, ensuring high performance, low latency, and easy integration. 

## System Overview

The system consists of the mobile application (Flutter) acting as the transmitter, the local WiFi network acting as the transport layer, and the ESP32 microcontroller acting as the receiver and actuator.

```mermaid
flowchart TD
    subgraph Mobile Device
        UI[Flutter Dashboard UI]
        STATE[State Management Provider]
        NET[UDP Network Layer]
        UI <-->|User Input & Telemetry| STATE
        STATE -->|Extracts State| NET
    end

    subgraph Network
        WIFI((WiFi Router))
    end

    subgraph Hardware
        ESP[ESP32 UDP Listener]
        LOGIC[Firmware Logic]
        ACT[Motors & Servos]
        SENS[Sensors]
    end

    NET -- 8-Byte Control Packet --> WIFI
    WIFI -- UDP Port 4210 --> ESP
    ESP --> LOGIC
    LOGIC --> ACT
    SENS --> LOGIC
    LOGIC -- Telemetry Packet --> WIFI
    WIFI -- UDP Port 4211 --> NET
```

## Layered Architecture

The application itself is structured into distinct layers to promote maintainability:

```mermaid
architecture-beta
    group app(Cloud)[Flutter Application]
    
    service ui(Server)[UI Layer: Screens & Widgets] in app
    service core(Database)[Core Logic: Providers & State] in app
    service net(Disk)[Network Layer: UDP Client/Server] in app
    
    ui:R --> L:core
    core:R --> L:net
```

*(Note: Mermaid architecture diagrams offer a structural view. The layers translate to `/screens`, `/providers`, and `/services` inside the Flutter codebase.)*

## Network Packet Flow

The system uses a highly optimized packet flow. Due to the nature of UDP, packets are sent asynchronously without waiting for handshakes. 

```mermaid
sequenceDiagram
    participant User
    participant Flutter App
    participant Router
    participant ESP32
    
    User->>Flutter App: Moves Left Joystick
    Flutter App->>Flutter App: Encode 8-byte packet
    Flutter App-)Router: Send UDP Datagram (Port 4210)
    Router-)ESP32: Forward Datagram
    ESP32->>ESP32: udp.parsePacket()
    ESP32->>ESP32: Validate Header & Checksum
    ESP32->>ESP32: Extract X/Y values
    ESP32->>Motors: Update PWM (Drive Motors)
    
    Note over ESP32,Flutter App: Telemetry Update (Every 500ms)
    ESP32-)Router: Send Telemetry (Battery, Temp)
    Router-)Flutter App: Forward to Listening Port (4211)
    Flutter App->>User: Update UI Dashboards
```

## App State Architecture

Inside the Flutter application, state is managed entirely through the `Provider` package to prevent unnecessary UI rebuilds.

```mermaid
flowchart LR
    Widget1[JoystickWidget] -->|updateJoystick()| Provider[ControllerState Provider]
    Widget2[ToggleSwitchWidget] -->|updateToggle()| Provider
    
    Provider -->|notifyListeners()| UI[DashboardScreen]
    Provider -->|Timer Loop| UDPService[UDP Service]
    UDPService -->|Sends Data| Network
```

This ensures that UI components like buttons and joysticks only interact with the unified state, which acts as the single source of truth for generating the outgoing datagrams.
