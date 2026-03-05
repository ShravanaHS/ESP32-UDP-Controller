import 'dart:async';
import 'package:flutter/foundation.dart';
import '../control_input/control_state.dart';
import 'udp_client.dart';

UDPClient getUDPClient() => UDPClientWeb();

class UDPClientWeb implements UDPClient {
  Timer? _transmitTimer;
  String? _targetAddress;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect(String ipAddress, int port) async {
    _targetAddress = ipAddress;
    _connected = true;
    debugPrint('Web UDP Mock: Connected to $ipAddress:$port');
  }

  @override
  void startTransmitting(ControlState Function() getState, {int hertz = 100}) {
    if (_transmitTimer != null && _transmitTimer!.isActive) return;

    final duration = Duration(milliseconds: 1000 ~/ hertz);

    _transmitTimer = Timer.periodic(duration, (timer) {
      if (!_connected || _targetAddress == null) return;

      getState(); // Evaluated but unused in mock to keep signature

      // Print occasionally to avoid web console spam
      if (DateTime.now().millisecond < 20) {
        // debugPrint('Web UDP Mock: Transmitting 8 bytes...');
      }
    });
  }

  @override
  void stopTransmitting() {
    _transmitTimer?.cancel();
    _transmitTimer = null;
  }

  @override
  void disconnect() {
    stopTransmitting();
    _connected = false;
    _targetAddress = null;
  }
}
