#include <ESP32ControlStudio.h>

ESP32ControlStudio controlApp;

const char *ssid = "YOUR_WIFI_SSID";
const char *password = "YOUR_WIFI_PASSWORD";

// Motor Driver Pins (L298N / TB6612)
const int PWM_FWD_PIN = 25;
const int PWM_BWD_PIN = 26;

// PWM Channels
const int CH_FWD = 0;
const int CH_BWD = 1;

void setup() {
  Serial.begin(115200);

  // Setup PWM
  ledcSetup(CH_FWD, 5000, 8);
  ledcSetup(CH_BWD, 5000, 8);
  ledcAttachPin(PWM_FWD_PIN, CH_FWD);
  ledcAttachPin(PWM_BWD_PIN, CH_BWD);

  controlApp.begin(ssid, password);
}

void loop() {
  controlApp.update();

  if (controlApp.isConnected() &&
      controlApp.sw1) { // Require ARM SYSTEM (sw1) to be ON

    // Map Joystick (0-255) to Speed (-255 to 255)
    int speed = map(controlApp.leftY, 0, 255, -255, 255);

    // Deadband
    if (abs(speed) < 25)
      speed = 0;

    // Drive
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
  } else {
    // Failsafe or Disarmed
    ledcWrite(CH_FWD, 0);
    ledcWrite(CH_BWD, 0);
  }
}
