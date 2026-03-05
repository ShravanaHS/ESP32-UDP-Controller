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
graph TD
    subgraph "Flutter Application (GCS)"
        UI[<b>UI Layer</b><br/>Screens & Widgets]
        Logic[<b>Core Logic</b><br/>Providers & State Management]
        Net[<b>Network Layer</b><br/>TCP/UDP Client/Server]
    end

    subgraph "Hardware"
        ESP[<b>ESP32 Firmware</b><br/>Packet Parser & GPIO Control]
        Actuators[<b>LEDs, Motors</b>]
    end

    %% Data Flow
    UI <--> Logic
    Logic <--> Net
    Net -- "TCP (Control) / UDP (Telemetry)" --> ESP
    ESP --> Actuators
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
    ESP32->>GPIO: Drive LEDs,Motors
    
    Note over ESP32,Flutter App: Telemetry Update (Every 500ms)
    ESP32-)Router: Send Telemetry (Battery, Temp)
    Router-)Flutter App: Forward to Listening Port (4211)
    Flutter App->>User: Update UI Dashboards
```

## App State Architecture

Inside the Flutter application, state is managed entirely through the `Provider` package to prevent unnecessary UI rebuilds.

```mermaid
flowchart LR
    subgraph "User Input (UI Layer)"
        Widget1[JoystickWidget]
        Widget2[ToggleSwitchWidget]
    end

    subgraph "State Management (Logic Layer)"
        Provider[<b>ControllerState Provider</b>]
    end

    subgraph "Output (Network Layer)"
        UDPService[UDP/TCP Service]
        UI[Dashboard UI Rebuild]
    end

    %% Flow Connections
    Widget1 -->|updateJoystick| Provider
    Widget2 -->|updateToggle| Provider
    
    Provider -->|notifyListeners| UI
    Provider -->|Stream/Timer| UDPService
    UDPService -->|Binary Packet| ESP32((ESP32))
```

This ensures that UI components like buttons and joysticks only interact with the unified state, which acts as the single source of truth for generating the outgoing datagrams.
