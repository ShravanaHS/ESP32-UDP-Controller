# ESP32 Firmware Integration Guide

Integrating your custom hardware robotics project with ESP32 Control Studio is incredibly simple. All you need is a basic WiFi UDP listener that parses the 8-byte control packet stream sent by the Flutter app.

## Prerequisites
- An ESP32 or ESP8266 development board.
- Arduino IDE with the ESP32 Core installed.
- Basic knowledge of WiFi setup in Arduino.

## Standard Firmware Setup
The following is the **complete, robust Arduino code** required to receive control packets from the Flutter app. This script continuously listens on UDP port `8888` (default), validates the 8-byte telemetry packet using a Checksum, and automatically updates global state variables (`leftX`, `btn1`, `sw1`, etc.) that you can use anywhere in your code.

```cpp
#include <WiFi.h>
#include <WiFiUdp.h>

// --- WiFi Configuration ---
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// --- UDP Configuration ---
// The control app sends datagrams to this port (Default is 8888)
const int udpPort = 8888; 
WiFiUDP udp;
byte packetBuffer[8];

// --- Global Control Variables ---
// Joysticks map from 0 to 255 (128 is center dead-zone)
int leftX = 128, leftY = 128;
int rightX = 128, rightY = 128;

// Buttons (True when physically pressed down in the app)
bool btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8;

// Toggle Switches (True when flipped ON in the app)
// sw1 is usually the "ARM SYSTEM" slide toggle.
bool sw1, sw2, sw3, sw4;

// Connection Watchdog
unsigned long lastPacketTime = 0;
bool isConnected = false;

void setup() {
  Serial.begin(115200);

  // 1. Connect to WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  
  // 2. Print IP Address
  Serial.println("WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP()); // ENTER THIS IP IN THE APP!

  // 3. Begin listening on UDP port
  udp.begin(udpPort);
  Serial.printf("Listening on UDP port %d\n", udpPort);
  
  // Optional: Setup a test LED
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // Read any newly arrived packets from the App
  receiveUDP();

  // Safety Feature: Stop everything if connection is lost (> 1000ms)
  if (millis() - lastPacketTime > 1000) {
    if (isConnected) {
      Serial.println("Warning: Connection Lost! System Disarmed.");
      isConnected = false;
      // Reset Joysticks and Buttons to safe defaults
      leftX = 128; leftY = 128; rightX = 128; rightY = 128;
      btn1 = btn2 = btn3 = btn4 = btn5 = btn6 = btn7 = btn8 = false;
    }
  }

  // ==== YOUR CUSTOM ROBOT LOGIC GOES HERE ====
  
  // Example: Map Toggle Switch 1 to onboard LED
  digitalWrite(LED_BUILTIN, sw1 ? HIGH : LOW);
  
  // ===========================================
}

void receiveUDP() {
  int packetSize = udp.parsePacket();
  
  if (packetSize == 8) { // The App always sends exactly 8 bytes
    udp.read(packetBuffer, 8);
    
    // Validate Header (0xAA) and Checksum
    if (packetBuffer[0] == 0xAA) {
      byte checksum = 0;
      for (int i = 0; i < 7; i++) checksum ^= packetBuffer[i];
      
      if (checksum == packetBuffer[7]) {
        // Validation Passed! Process the commands
        lastPacketTime = millis();
        if (!isConnected) {
          isConnected = true;
          Serial.println("Status: App Connected & Streaming!");
        }

        // 1. Extract Joystick Values (0 to 255. 128 is center)
        leftX  = packetBuffer[1];
        leftY  = packetBuffer[2];
        rightX = packetBuffer[3];
        rightY = packetBuffer[4];

        // 2. Extract Buttons (Bitmask - Byte 5)
        byte buttons = packetBuffer[5];
        btn1 = bitRead(buttons, 0);
        btn2 = bitRead(buttons, 1);
        btn3 = bitRead(buttons, 2);
        btn4 = bitRead(buttons, 3);
        btn5 = bitRead(buttons, 4);
        btn6 = bitRead(buttons, 5);
        btn7 = bitRead(buttons, 6);
        btn8 = bitRead(buttons, 7);

        // 3. Extract Toggles (Bitmask - Byte 6)
        byte toggles = packetBuffer[6];
        sw1 = bitRead(toggles, 0); // "ARM SYSTEM" Switch
        sw2 = bitRead(toggles, 1);
        sw3 = bitRead(toggles, 2);
        sw4 = bitRead(toggles, 3);
      }
    }
  }
}
```

## How to Test
1. Upload the code to your ESP32.
2. Open the Arduino Serial Monitor (**115200 baud**).
3. Wait for the `WiFi connected!` message and note the `IP address:`.
4. Open the **ESP32 Control Studio app**. Tap the Connect icon, enter the IP address (leave Port as `8888`), and tap **Connect**.
5. Once connected, flip **ARM SYSTEM (sw1)**. The Built-in blue LED on your ESP32 will turn ON!
6. Slide it back, and it will turn OFF. 

---

## Code Examples

### Example 1: Controlling a Laser or Horn with a Button
A push button (like `btn1` to `btn8`) holds the state `true` as long as it is physically pressed down in the app. It instantly returns to `false` when released. 

```cpp
// Connect an LED/Laser/Buzzer to GPIO 4
const int LASER_PIN = 4;

void setup() {
  pinMode(LASER_PIN, OUTPUT);
  // ... Include WiFi & UDP Setup from Above ...
}

void loop() {
  receiveUDP(); // Updates all variables seamlessly
  
  // As long as the user holds Button 1 in the app, the pin outputs 3.3V (HIGH)
  if (btn1) {
    digitalWrite(LASER_PIN, HIGH);
  } else {
    digitalWrite(LASER_PIN, LOW); // Released! Output is 0V
  }
}
```

### Example 2: Controlling a Headlight with a Toggle Switch
A toggle switch (like `sw2`) acts as a physical flip switch in the app. You slide it ON (`true`), it stays ON. You slide it OFF (`false`), it stays OFF. 

```cpp
// Connect a headlight relay to GPIO 5
const int HEADLIGHT_PIN = 5;

void setup() {
  pinMode(HEADLIGHT_PIN, OUTPUT);
  // ... Include WiFi & UDP Setup from Above ...
}

void loop() {
  receiveUDP(); 
  
  // The ESP32 pin physically reflects exactly what the switch in the app says.
  if (sw2) {
    digitalWrite(HEADLIGHT_PIN, HIGH);
  } else {
    digitalWrite(HEADLIGHT_PIN, LOW);
  }
}
```

### Example 3: Driving a DC Motor using the Left Joystick
This code maps the `leftY` joystick telemetry data (`0` to `255`, where `128` sits exactly in the middle) to standard motor PWM bounds (`-255` to `+255`).

We introduce a **deadband** because imperfect thumbs might let the joystick spring back to `126` or `130` (instead of perfectly `128`). The deadband ignores slight stick movements near the center to prevent humming/twitching.

```cpp
// Motor Driver Pins (Compatible with L298N, TB6612FNG, or MX1508)
const int PWM_FWD_PIN = 25; 
const int PWM_BWD_PIN = 26; 

// PWM Configuration for ESP32
const int PWM_FREQ = 5000;
const int PWM_RES = 8; // 8-bit resolution (0-255)
const int CH_FWD = 0;
const int CH_BWD = 1;

void setup() {
  // Attach the ESP32 PWM hardware channels to the physical pins
  ledcSetup(CH_FWD, PWM_FREQ, PWM_RES);
  ledcSetup(CH_BWD, PWM_FREQ, PWM_RES);
  ledcAttachPin(PWM_FWD_PIN, CH_FWD);
  ledcAttachPin(PWM_BWD_PIN, CH_BWD);
  
  // ... Include WiFi & UDP Setup from Above ...
}

void loop() {
  receiveUDP(); 
  
  // 1. Grab the Joystick Left Y-axis (0 to 255. Center is 128)
  // We map it to Motor Speed bounds: -255 (Reverse) to +255 (Forward)
  int speed = map(leftY, 0, 255, -255, 255);
  
  // 2. Apply a deadband (ignore slight stick movements near center)
  if (abs(speed) < 25) {
    speed = 0;
  }
  
  // 3. Drive the Motor Direction based on the sign (+ / -) of the speed
  if (speed > 0) {
    // Stick is Pushed UP: Go FORWARD
    ledcWrite(CH_FWD, speed);
    ledcWrite(CH_BWD, 0); 
  } 
  else if (speed < 0) {
    // Stick is Pulled DOWN: Go BACKWARD 
    // We invert the negative number back to positive (0-255) for PWM
    ledcWrite(CH_FWD, 0);
    ledcWrite(CH_BWD, -speed); 
  } 
  else {
    // DEAD CENTER: STOP 
    ledcWrite(CH_FWD, 0);
    ledcWrite(CH_BWD, 0);
  }
}
```
