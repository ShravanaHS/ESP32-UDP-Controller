import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'device.dart';

class DiscoveryService extends ChangeNotifier {
  static const int broadcastPort = 8887; // Discovery port
  RawDatagramSocket? _broadcastSocket;
  Timer? _discoveryTimer;

  final Map<String, ESP32Device> _discoveredDevices = {};

  List<ESP32Device> get devices => _discoveredDevices.values.toList();

  Future<void> startDiscovery() async {
    try {
      _broadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, broadcastPort);
      _broadcastSocket?.broadcastEnabled = true;

      _broadcastSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _broadcastSocket?.receive();
          if (datagram != null) {
            _handleDiscoveryResponse(datagram);
          }
        }
      });

      // Send a broadcast ping every 3 seconds
      _discoveryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _sendBroadcastPing();
      });

      // Initial ping
      _sendBroadcastPing();
    } catch (e) {
      debugPrint('Error starting discovery: $e');
    }
  }

  void _sendBroadcastPing() {
    if (_broadcastSocket == null) return;
    
    // We send a simple JSON string to discover ESP32s
    final pingMsg = utf8.encode('{"cmd":"discover"}');
    
    try {
      _broadcastSocket!.send(pingMsg, InternetAddress('255.255.255.255'), broadcastPort);
    } catch (e) {
      debugPrint('Broadcast send error: $e');
    }

    _cleanupStaleDevices();
  }

  void _handleDiscoveryResponse(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      // Expected ESP32 Response: {"id":"ESP32_1", "name":"Control Studio Drone"}
      final jsonMsg = jsonDecode(message);
      
      if (jsonMsg['id'] != null) {
        final id = jsonMsg['id'];
        
        final device = ESP32Device(
          id: id,
          name: jsonMsg['name'] ?? 'Unknown ESP32',
          ipAddress: datagram.address.address,
          lastSeen: DateTime.now(),
        );

        _discoveredDevices[id] = device;
        notifyListeners();
      }
    } catch (e) {
      // Ignore non-JSON or invalid packets received on the port
      // print('Invalid discovery packet: $e');
    }
  }

  void _cleanupStaleDevices() {
    bool changed = false;
    _discoveredDevices.removeWhere((id, device) {
      if (!device.isOnline) {
        changed = true;
        return true; // remove
      }
      return false; // keep
    });

    if (changed) {
      notifyListeners();
    }
  }

  void stopDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
  }
}
