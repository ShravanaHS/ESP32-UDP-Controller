import 'dart:async';
import '../control_input/control_state.dart';

// Use a conditional import instead of dart:html alias tricks.
import 'udp_client_stub.dart'
    if (dart.library.io) 'udp_client_io.dart'
    if (dart.library.html) 'udp_client_web.dart';

abstract class UDPClient {
  factory UDPClient() => getUDPClient();

  bool get isConnected;
  Future<void> connect(String ipAddress, int port);
  void startTransmitting(ControlState Function() getState, {int hertz = 100});
  void stopTransmitting();
  void disconnect();
}
