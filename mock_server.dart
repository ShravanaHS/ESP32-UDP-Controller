import 'dart:io';
import 'dart:convert';
import 'dart:async';

void main() async {
  const int PORT_DISCOVERY = 8887;
  const int PORT_CONTROL = 8888;
  const int PORT_TELEMETRY = 8889;

  InternetAddress? appAddress;

  // 1. Discovery Listener
  RawDatagramSocket.bind(InternetAddress.anyIPv4, PORT_DISCOVERY).then((socket) {
    print('[Discovery] Listening on port $PORT_DISCOVERY');
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          final req = utf8.decode(datagram.data);
          print('[Discovery] Received from ${datagram.address.address}: $req');
          appAddress = datagram.address;

          final response = utf8.encode('{"id": "ESP_TEST_1", "name": "Mock Drone ESP32"}');
          socket.send(response, datagram.address, datagram.port);
        }
      }
    });
  });

  // 2. Control Listener
  RawDatagramSocket.bind(InternetAddress.anyIPv4, PORT_CONTROL).then((socket) {
    print('[Control] Listening for packets on port $PORT_CONTROL');
    int packetCount = 0;
    
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null && datagram.data.length == 8) {
          final d = datagram.data;
          packetCount++;
          // Throttle prints so we don't flood stdout
          if (packetCount % 50 == 0) {
            print('[Control] From ${datagram.address.address} -> J1(${d[1]},${d[2]}) J2(${d[3]},${d[4]}) Btns:${d[5]} Tgls:${d[6]}');
          }
        }
      }
    });
  });

  // 3. Telemetry Sender
  double voltage = 12.0;
  double temp = 30.0;

  print('[Telemetry] Sender ready. Waiting for discovery ping...');
  
  // Create a socket for sending telemetry
  RawDatagramSocket telemetrySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

  Timer.periodic(Duration(milliseconds: 500), (timer) {
    if (appAddress != null) {
      voltage = (voltage - 0.05).clamp(10.5, 12.6); // slight drip
      final payload = utf8.encode('{"v": ${voltage.toStringAsFixed(1)}, "t": $temp}');
      telemetrySocket.send(payload, appAddress!, PORT_TELEMETRY);
    }
  });
}
