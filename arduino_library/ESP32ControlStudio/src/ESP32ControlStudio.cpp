#include "ESP32ControlStudio.h"

ESP32ControlStudio::ESP32ControlStudio(int port) {
  _port = port;
  _lastPacketTime = 0;
  _connected = false;
  resetToSafeState();
}

void ESP32ControlStudio::begin(const char *ssid, const char *password) {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  _udp.begin(_port);
  Serial.printf("ESP32 Control Studio Listening on UDP port %d\n", _port);
}

void ESP32ControlStudio::update() {
  int packetSize = _udp.parsePacket();

  if (packetSize == 8) {
    _udp.read(_packetBuffer, 8);
    processPacket();
  }

  // Safety Timeout (1000ms)
  if (_connected && millis() - _lastPacketTime > 1000) {
    Serial.println("Warning: Connection Lost! System Disarmed.");
    _connected = false;
    resetToSafeState();
  }
}

void ESP32ControlStudio::processPacket() {
  // Validate Header (0xAA)
  if (_packetBuffer[0] != 0xAA)
    return;

  // Validate Checksum
  byte checksum = 0;
  for (int i = 0; i < 7; i++) {
    checksum ^= _packetBuffer[i];
  }

  if (checksum != _packetBuffer[7])
    return;

  // Validation Passed!
  _lastPacketTime = millis();

  if (!_connected) {
    _connected = true;
    Serial.println("Status: App Connected & Streaming!");
  }

  // 1. Extract Joystick Values (0 to 255. 128 is center)
  leftX = _packetBuffer[1];
  leftY = _packetBuffer[2];
  rightX = _packetBuffer[3];
  rightY = _packetBuffer[4];

  // 2. Extract Buttons (Bitmask - Byte 5)
  byte buttons = _packetBuffer[5];
  btn1 = bitRead(buttons, 0);
  btn2 = bitRead(buttons, 1);
  btn3 = bitRead(buttons, 2);
  btn4 = bitRead(buttons, 3);
  btn5 = bitRead(buttons, 4);
  btn6 = bitRead(buttons, 5);
  btn7 = bitRead(buttons, 6);
  btn8 = bitRead(buttons, 7);

  // 3. Extract Toggles (Bitmask - Byte 6)
  byte toggles = _packetBuffer[6];
  sw1 = bitRead(toggles, 0);
  sw2 = bitRead(toggles, 1);
  sw3 = bitRead(toggles, 2);
  sw4 = bitRead(toggles, 3);
}

void ESP32ControlStudio::resetToSafeState() {
  leftX = 128;
  leftY = 128;
  rightX = 128;
  rightY = 128;
  btn1 = false;
  btn2 = false;
  btn3 = false;
  btn4 = false;
  btn5 = false;
  btn6 = false;
  btn7 = false;
  btn8 = false;
  // Note: We might allow toggles to hold state across dropped packets,
  // but it's safer to zero them out too if connection is lost.
  sw1 = false;
  sw2 = false;
  sw3 = false;
  sw4 = false;
}

bool ESP32ControlStudio::isConnected() { return _connected; }

unsigned long ESP32ControlStudio::timeSinceLastPacket() {
  return millis() - _lastPacketTime;
}
