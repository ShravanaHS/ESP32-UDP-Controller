import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../control_input/control_state.dart';
import 'packet_encoder.dart';
import 'udp_client.dart';

UDPClient getUDPClient() => UDPClientIO();

class UDPClientIO implements UDPClient {
  RawDatagramSocket? _socket;
  Timer? _transmitTimer;
  InternetAddress? _targetAddress;
  int _targetPort = 8888;

  @override
  bool get isConnected => _targetAddress != null && _socket != null;

  @override
  Future<void> connect(String ipAddress, int port) async {
    _targetAddress = InternetAddress(ipAddress);
    _targetPort = port;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      debugPrint('UDP Socket bound to: ${_socket?.address.address}:${_socket?.port}');
    } catch (e) {
      debugPrint('Error binding UDP socket: $e');
    }
  }

  @override
  void startTransmitting(ControlState Function() getState, {int hertz = 100}) {
    if (_transmitTimer != null && _transmitTimer!.isActive) return;

    final duration = Duration(milliseconds: 1000 ~/ hertz);

    _transmitTimer = Timer.periodic(duration, (timer) {
      if (_socket == null || _targetAddress == null) return;

      final currentState = getState();
      final packet = PacketEncoder.encode(currentState);

      _socket?.send(packet, _targetAddress!, _targetPort);
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
    _socket?.close();
    _socket = null;
    _targetAddress = null;
  }
}
