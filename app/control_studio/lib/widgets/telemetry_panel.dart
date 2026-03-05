import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../telemetry/telemetry_parser.dart';
import '../network/connection_provider.dart';
import '../theme/app_theme.dart';

class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final telemetryService = Provider.of<TelemetryService>(context);
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final state = telemetryService.state;
    final isConnected = connectionProvider.isConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.voidInk.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TELEMETRY',
                style: TextStyle(
                  color: AppTheme.multiverseCyan.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? Colors.green : Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected ? Colors.green : Colors.red).withValues(alpha: 0.5),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'LINK ACTIVE' : 'NO LINK',
                    style: TextStyle(
                      color: AppTheme.textColorMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTelemetryItem(Icons.battery_charging_full, 'Battery', isConnected ? '${state.batteryVoltage.toStringAsFixed(1)} V' : '-- V'),
                _buildTelemetryItem(Icons.thermostat, 'Temp', isConnected ? '${state.temperature.toStringAsFixed(1)} °C' : '-- °C'),
                _buildTelemetryItem(Icons.speed, 'Ping', isConnected ? '${state.ping} ms' : '-- ms'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(IconData icon, String label, String value) {
    final parts = value.split(' ');
    final valStr = parts[0];
    final unitStr = parts.length > 1 ? parts[1] : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.multiverseCyan.withValues(alpha: 0.4), size: 16),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: valStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: unitStr,
                style: const TextStyle(
                  color: AppTheme.multiverseCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.textColorMuted,
            fontSize: 7,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
