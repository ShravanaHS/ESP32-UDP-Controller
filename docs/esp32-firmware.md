# ESP32 Firmware Integration Guide

Integrating your custom hardware robotics project with ESP32 Control Studio is incredibly simple. You only need a basic WiFi UDP listener that parses the 8-byte control packet.

## Prerequisites
- An ESP32 or ESP8266 development board.
- Arduino IDE with the ESP32 Core installed.
- Basic knowledge of WiFi setup in Arduino.

## Standard Firmware Setup
The following is the minimal viable Arduino code to receive packets from the Flutter app.

```cpp
#include <WiFi.h>
#include <WiFiUdp.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// The port the Flutter app sends datagrams to
const int udpPort = 4210;

WiFiUDP udp;
byte packetBuffer[8];

void setup() {
  Serial.begin(115200);

  // Connect to WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  
  Serial.println("WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP()); // Enter this IP in the App!

  // Begin listening on UDP port
  udp.begin(udpPort);
  Serial.printf("Listening on UDP port %d\n", udpPort);
  
  // Setup a test LED
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // Check if a packet has been received
  int packetSize = udp.parsePacket();
  
  if (packetSize == 8) { // The App always sends exactly 8 bytes
    udp.read(packetBuffer, 8);
    
    // Validate Header and Checksum
    if (packetBuffer[0] == 0xAA) {
      byte checksum = 0;
      for (int i = 0; i < 7; i++) checksum ^= packetBuffer[i];
      
      if (checksum == packetBuffer[7]) {
        // Validation Passed! Process the commands:
        processCommands(packetBuffer);
      }
    }
  }
}

void processCommands(byte* packet) {
  // Extract Joystick Values (128 is center)
  byte leftX  = packet[1];
  byte leftY  = packet[2];
  byte rightX = packet[3];
  byte rightY = packet[4];

  // Extract Buttons (Bitmask)
  byte buttons = packet[5];
  // Example: Check if Button 'A' (Bit 0) is pressed
  bool btnA = bitRead(buttons, 0);

  // Extract Toggles (Bitmask)
  byte toggles = packet[6];
  // Example: Map Toggle 1 (Bit 0) to onboard LED
  bool toggle1 = bitRead(toggles, 0);
  digitalWrite(LED_BUILTIN, toggle1 ? HIGH : LOW);

  // Debug Print
  Serial.printf("L(X:%d Y:%d) R(X:%d Y:%d) BTN:0x%02X TGL:0x%02X\n", 
                leftX, leftY, rightX, rightY, buttons, toggles);
}
```

## How to Test
1. Upload the code to your ESP32.
2. Open the Arduino Serial Monitor (**115200 baud**).
3. Wait for the `WiFi connected!` message and note the `IP address:`.
4. Open the ESP32 Control Studio app, enter the IP, and tap **Connect**.
5. Move the joysticks and flip toggles. You should see the real-time data streaming in the Serial Monitor, and flipping Toggle 1 should turn the built-in LED on and off!

## Next Steps
Once you have this basic loop running, you can map the `leftY` and `rightY` variables to `ledcWrite()` (PWM) commands to drive motor controllers like the L298N or TB6612FNG.
