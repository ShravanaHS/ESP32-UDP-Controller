class ESP32Device {
  final String id;
  final String ipAddress;
  final String name;
  final DateTime lastSeen;

  ESP32Device({
    required this.id,
    required this.ipAddress,
    required this.name,
    required this.lastSeen,
  });

  bool get isOnline {
    // Consider device offline if not seen for 5 seconds
    return DateTime.now().difference(lastSeen).inSeconds < 5;
  }
}
