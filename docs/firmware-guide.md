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

### Example 4: Controlling an LED/Laser with a Push Button (Momentary)
A push button (like `btnX`) holds the state `true` as long as it is physically pressed down in the app. It instantly returns to `false` when released. This makes it perfect for a horn, a laser, or a temporary speed boost.

```cpp
// Connect an LED to GPIO 4
const int LASER_PIN = 4;

void setup() {
  pinMode(LASER_PIN, OUTPUT);
  setupControlStudio(); // Sets up WiFi & UDP
}

void loop() {
  updateControlStudioData(); // Updates all button states
  
  // As long as the user holds Button X in the app, the pin outputs 3.3V (HIGH)
  if (btnX) {
    digitalWrite(LASER_PIN, HIGH);
  } else {
    digitalWrite(LASER_PIN, LOW); // Released! Output is 0V
  }
}
```

### Example 5: Controlling a Headlight with a Toggle Switch
A toggle switch (like `sw1`) acts as a physical flip switch in the app. You tap it once, it stays ON (`true`). You tap it again, it stays OFF (`false`). This is best for state changes like headlights, auto-pilot mode, or enabling a sensor.

```cpp
// Connect a headlight LED or Relay to GPIO 5
const int HEADLIGHT_PIN = 5;

void setup() {
  pinMode(HEADLIGHT_PIN, OUTPUT);
  setupControlStudio();
}

void loop() {
  updateControlStudioData(); // Updates all switch states
  
  // Let the ESP32 pin physically reflect exactly what the switch in the app says.
  // Switch 1 ON = HEADLIGHT_PIN HIGH. Switch 1 OFF = HEADLIGHT_PIN LOW.
  if (sw1) {
    digitalWrite(HEADLIGHT_PIN, HIGH);
  } else {
    digitalWrite(HEADLIGHT_PIN, LOW);
  }
}
```

### Example 6: Driving a DC Motor using the Left Joystick
This requires mapping the joystick data (`0` to `200`) to standard motor PWM bounds (`-255` to `+255`). 
Since `100` means the joystick is dead-centered, a "deadband" is used. This prevents the motor from humming or twitching if the joystick springs back to `99` instead of perfectly `100`.

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
  
  setupControlStudio();
}

void loop() {
  updateControlStudioData(); // Grab latest joystick telemetry
  
  // Grab the Joystick 1 Y-axis (0-200). 100 sits exactly in the middle.
  // We map it to Motor Speed (-255 to +255)
  int speed = map(j1y, 0, 200, -255, 255);
  
  // Apply a deadband (ignore slight stick movements near center)
  if (abs(speed) < 25) {
    speed = 0;
  }
  
  // Drive the Motor Direction based on the sign (+ / -) of the speed
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

