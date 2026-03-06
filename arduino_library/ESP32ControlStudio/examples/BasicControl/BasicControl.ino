#include <ESP32ControlStudio.h>

// Create an instance of the control studio
ESP32ControlStudio controlApp;

// WiFi Credentials
const char *ssid = "YOUR_WIFI_SSID";
const char *password = "YOUR_WIFI_PASSWORD";

// Hardware Pins
const int LED_PIN = 2; // Built-in LED on most ESP32s
const int LASER_PIN = 4;

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(LASER_PIN, OUTPUT);

  // Connect to WiFi and Start Listening on port 8888
  controlApp.begin(ssid, password);
}

void loop() {
  // Call update() as fast as possible to process incoming UDP packets
  controlApp.update();

  if (controlApp.isConnected()) {

    // Example 1: Use joystick to print values
    // leftY maps from 0 to 255. Center is 128.
    if (controlApp.leftY > 150) {
      Serial.println("Moving Forward!");
    }

    // Example 2: Use a Toggle Switch for an LED
    if (controlApp.sw1) {
      digitalWrite(LED_PIN, HIGH);
    } else {
      digitalWrite(LED_PIN, LOW);
    }

    // Example 3: Use a Push Button for a Laser
    // btn1 is true as long as you hold it down in the App
    if (controlApp.btn1) {
      digitalWrite(LASER_PIN, HIGH);
    } else {
      digitalWrite(LASER_PIN, LOW);
    }

  } else {
    // Failsafe: Turn things off if connection drops
    digitalWrite(LED_PIN, LOW);
    digitalWrite(LASER_PIN, LOW);
  }
}
