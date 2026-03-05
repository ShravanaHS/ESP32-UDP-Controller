class TelemetryState {
  final double batteryVoltage;
  final double temperature;
  final int ping;
  final bool isConnected;

  TelemetryState({
    this.batteryVoltage = 0.0,
    this.temperature = 0.0,
    this.ping = 0,
    this.isConnected = false,
  });

  TelemetryState copyWith({
    double? batteryVoltage,
    double? temperature,
    int? ping,
    bool? isConnected,
  }) {
    return TelemetryState(
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      temperature: temperature ?? this.temperature,
      ping: ping ?? this.ping,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
