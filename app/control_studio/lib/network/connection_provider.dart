import 'package:flutter/foundation.dart';
import 'udp_client.dart';
import '../control_input/control_state.dart';

class ConnectionProvider extends ChangeNotifier {
  final UDPClient _client = UDPClient();
  bool _isConnecting = false;
  String? _errorMessage;

  bool get isConnected => _client.isConnected;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  UDPClient get client => _client;

  Future<bool> connect(String ipAddress, int port, ControlState Function() getState) async {
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.connect(ipAddress, port);
      if (_client.isConnected) {
        debugPrint('Connected successfully, starting transmission engine');
        _client.startTransmitting(getState);
      } else {
        _errorMessage = "Failed to connect to $ipAddress:$port";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
    
    return _client.isConnected;
  }

  void disconnect() {
    _client.stopTransmitting();
    _client.disconnect();
    notifyListeners();
  }
}
