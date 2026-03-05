// ignore_for_file: avoid_print, unused_local_variable
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

void main() async {
  final port = 8888;
  final telemetryPort = 8889;
  
  // Listen for control packets
  final controlSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
  print('Mock ESP32 Control Server listening on port $port');

  // Listen for broadcast discovery packets
  final discoverySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
  print('Mock ESP32 Discovery Server listening. (simulated on same port for now, or just send on start)');
  
  // Create socket for sending telemetry
  final telemetrySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  
  controlSocket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? dg = controlSocket.receive();
      if (dg != null) {
        if (dg.data.length == 8) {
          // print('Received control packet from ${dg.address.address}:${dg.port}');
          // Could parse it to log values
        } else if (String.fromCharCodes(dg.data).startsWith('DISCOVER_ESP32')) {
          print('Discovery request from ${dg.address.address}:${dg.port}');
          // Send back a discovery response
          controlSocket.send("ESP32_CONTROL_STUDIO".codeUnits, dg.address, dg.port);
        }
      }
    }
  });

  // Start sending simulated telemetry
  double voltage = 11.5;
  int current = 500;
  int rssi = -60;
  int ping = 10;
  
  Timer.periodic(Duration(milliseconds: 500), (timer) {
    // Generate some mock data
    voltage += (DateTime.now().millisecond % 10 - 5) / 100;
    if (voltage > 12.6) voltage = 12.6;
    if (voltage < 10.0) voltage = 10.0;
    
    rssi += (DateTime.now().millisecond % 5 - 2);
    if (rssi > -40) rssi = -40;
    if (rssi < -90) rssi = -90;

    // Encode TelemetryPacket
    final byteData = ByteData(16);
    byteData.setFloat32(0, voltage, Endian.little);
    // ...
    // To simplify, we will just send random bytes or the expected format
    // Expected:
    // float batteryVoltage (0)
    // float currentDraw (4)
    // int32 rssi (8)
    // int32 ping (12)
    
    byteData.setFloat32(4, 1.2 /* 1.2A */, Endian.little);
    byteData.setInt32(8, rssi, Endian.little);
    byteData.setInt32(12, ping, Endian.little);

    // Assuming the app is running locally, we broadcast to loopback
    // Or normally we'd send to the address that sent the discovery, but broadcast is easiest
    try {
      telemetrySocket.send(byteData.buffer.asUint8List(), InternetAddress('127.0.0.1'), telemetryPort);
    } catch (e) {
      // ignore
    }
  });
}
