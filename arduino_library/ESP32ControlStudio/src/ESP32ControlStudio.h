#ifndef ESP32ControlStudio_h
#define ESP32ControlStudio_h

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>

class ESP32ControlStudio {
  public:
    ESP32ControlStudio(int port = 8888);

    // Initializes WiFi and starts UDP listener
    void begin(const char* ssid, const char* password);
    
    // Call this inside loop() to parse incoming packets
    void update();

    // -- Connection State --
    bool isConnected();
    unsigned long timeSinceLastPacket();

    // -- Data Variables --
    
    // Joysticks (0-255, 128 is center)
    int leftX;
    int leftY;
    int rightX;
    int rightY;

    // Buttons (True when held down)
    bool btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8;

    // Toggle Switches (True when flipped ON)
    bool sw1, sw2, sw3, sw4;

  private:
    int _port;
    WiFiUDP _udp;
    byte _packetBuffer[8];
    unsigned long _lastPacketTime;
    bool _connected;
    
    void processPacket();
    void resetToSafeState();
};

#endif
