import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'telemetry_state.dart';

class TelemetryService extends ChangeNotifier {
  static const int telemetryPort = 8889; // Port ESP32 sends data to
  
  RawDatagramSocket? _socket;
  TelemetryState _state = TelemetryState();
  Timer? _timeoutTimer;
  DateTime _lastPacketTime = DateTime.fromMillisecondsSinceEpoch(0);

  TelemetryState get state => _state;

  Future<void> startListening() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, telemetryPort);

      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket?.receive();
          if (datagram != null) {
            _handleTelemetryPacket(datagram);
          }
        }
      });

      // Check connection timeout every second
      _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _checkConnectionTimeout();
      });

    } catch (e) {
      debugPrint('Error starting telemetry listener: $e');
    }
  }

  void _handleTelemetryPacket(Datagram datagram) {
    try {
      // Expected ESP32 JSON: {"v": 11.5, "t": 45.2}
      final message = utf8.decode(datagram.data);
      final jsonMsg = jsonDecode(message);

      double voltage = _state.batteryVoltage;
      if (jsonMsg['v'] != null) {
        voltage = (jsonMsg['v'] as num).toDouble();
      }

      double temp = _state.temperature;
      if (jsonMsg['t'] != null) {
        temp = (jsonMsg['t'] as num).toDouble();
      }

      final now = DateTime.now();
      
      // Calculate a rough "ping" based on when we last heard from them
      // (A real ping requires round-trip sequence numbers, but for telemetry 
      // frequency, this shows delay since last packet)
      int delayMs = now.difference(_lastPacketTime).inMilliseconds;
      if (_lastPacketTime.year == 1970) delayMs = 0; // First packet
      
      _lastPacketTime = now;

      _state = _state.copyWith(
        batteryVoltage: voltage,
        temperature: temp,
        ping: delayMs,
        isConnected: true,
      );

      notifyListeners();
    } catch (_) {
      // Ignore invalid packets
    }
  }

  void _checkConnectionTimeout() {
    if (!_state.isConnected) return;

    // If we haven't received telemetry in 2 seconds, assume disconnected
    if (DateTime.now().difference(_lastPacketTime).inSeconds > 2) {
      _state = _state.copyWith(isConnected: false, ping: 0);
      notifyListeners();
    }
  }

  void stopListening() {
    _timeoutTimer?.cancel();
    _socket?.close();
    _socket = null;
    _state = _state.copyWith(isConnected: false);
    notifyListeners();
  }
}
