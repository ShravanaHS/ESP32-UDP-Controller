# ESP32 Firmware Integration Guide

Integrating your custom hardware robotics project with ESP32 Control Studio is incredibly simple using the official **ESP32ControlStudio** Arduino Library. It completely abstracts away WiFi UDP sockets, bit-shifting, and packet checksum errors so you can focus purely on building your robot.

## Prerequisites
- An ESP32 or ESP8266 development board.
- Arduino IDE with the ESP32 Core installed.
- Install the `ESP32ControlStudio` library (included in this repository under `arduino_library/ESP32ControlStudio`).

## Standard Firmware Setup
The following is the minimal robust Arduino code required to receive control packets from the Flutter app using the library. 

```cpp
#include <ESP32ControlStudio.h>

// Create an instance of the control studio
ESP32ControlStudio controlApp;

// WiFi Credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

void setup() {
  Serial.begin(115200);

  // Connect to WiFi and Listen on default port 8888
  controlApp.begin(ssid, password);
  
  // Setup a test LED
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // Call update() as fast as possible to process incoming UDP packets
  controlApp.update();

  // Safety Feature: Only act if the connection is live
  if (controlApp.isConnected()) {
    
    // Example: Map Toggle Switch 1 to onboard LED
    digitalWrite(LED_BUILTIN, controlApp.sw1 ? HIGH : LOW);
    
  } else {
    // Failsafe: Turn off motors/lasers if connection drops
    digitalWrite(LED_BUILTIN, LOW);
  }
}
```

## How to Test
1. Upload the code to your ESP32.
2. Open the Arduino Serial Monitor (**115200 baud**).
3. Wait for the `WiFi connected!` message and note the `IP address:`.
4. Open the **ESP32 Control Studio app**. Tap the Connect icon, enter the IP address (leave Port as `8888`), and tap **Connect**.
5. Once connected, flip **ARM SYSTEM (sw1)**. The Built-in blue LED on your ESP32 will turn ON!

---

## Code Examples

### Example 1: Controlling a Laser or Horn with a Button
A push button (like `btn1` to `btn8`) holds the state `true` as long as it is physically pressed down in the app. It instantly returns to `false` when released. 

```cpp
const int LASER_PIN = 4;

void setupLaser() {
  pinMode(LASER_PIN, OUTPUT);
}

void updateLaser() {
  // btn1 is true as long as you hold it down in the App
  if (controlApp.btn1) {
    digitalWrite(LASER_PIN, HIGH);
  } else {
    digitalWrite(LASER_PIN, LOW); // Released! Output is 0V
  }
}
// (Call setupLaser() in setup() and updateLaser() in loop() AFTER controlApp.update())
```

### Example 2: Driving a DC Motor using the Left Joystick
This code maps the `leftY` joystick telemetry data (`0` to `255`, where `128` sits exactly in the middle) to standard motor PWM bounds (`-255` to `+255`).

```cpp
const int PWM_FWD_PIN = 25; 
const int PWM_BWD_PIN = 26; 
const int CH_FWD = 0;
const int CH_BWD = 1;

void setupMotors() {
  ledcSetup(CH_FWD, 5000, 8);
  ledcSetup(CH_BWD, 5000, 8);
  ledcAttachPin(PWM_FWD_PIN, CH_FWD);
  ledcAttachPin(PWM_BWD_PIN, CH_BWD);
}

void updateMotors() {
  // 1. Grab the Joystick Left Y-axis (0 to 255. Center is 128)
  int speed = map(controlApp.leftY, 0, 255, -255, 255);
  
  // 2. Apply a deadband (ignore slight stick movements near center)
  if (abs(speed) < 25) speed = 0;
  
  // 3. Drive the Motor 
  if (speed > 0) {
    ledcWrite(CH_FWD, speed);
    ledcWrite(CH_BWD, 0); 
  } else if (speed < 0) {
    ledcWrite(CH_FWD, 0);
    ledcWrite(CH_BWD, -speed); 
  } else {
    ledcWrite(CH_FWD, 0);
    ledcWrite(CH_BWD, 0);
  }
}
// (Call setupMotors() in setup() and updateMotors() in loop() AFTER controlApp.update())
```
