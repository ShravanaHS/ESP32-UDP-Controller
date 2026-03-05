import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../network/connection_provider.dart';
import '../control_input/control_provider.dart';
import '../device_manager/discovery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import 'dashboard_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.31.232');
  final TextEditingController _portController = TextEditingController(text: '8888');

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8888;

    final connectionProvider = context.read<ConnectionProvider>();
    final controlProvider = context.read<ControlProvider>();
    
    final success = await connectionProvider.connect(ip, port, () => controlProvider.state);
    
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<ConnectionProvider>();
    final discoveryService = context.watch<DiscoveryService>();

    return Scaffold(
      backgroundColor: AppTheme.voidInk,
      body: Center(
        child: SingleChildScrollView(
          child: GlassPanel(
            width: 400,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ESP32 Control Studio',
                  style: const TextStyle(
                    color: AppTheme.multiverseCyan,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'IP Address',
                    labelStyle: const TextStyle(color: AppTheme.textColorMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.multiverseCyan),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.wifi, color: AppTheme.multiverseCyan),
                  ),
                  style: const TextStyle(color: AppTheme.textColorPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    labelStyle: const TextStyle(color: AppTheme.textColorMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.multiverseCyan),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.settings_ethernet, color: AppTheme.multiverseCyan),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textColorPrimary),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: connectionProvider.isConnecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.multiverseCyan.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.multiverseCyan,
                      side: const BorderSide(color: AppTheme.multiverseCyan, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 10,
                      shadowColor: AppTheme.multiverseCyan.withValues(alpha: 0.5),
                    ),
                    child: connectionProvider.isConnecting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: AppTheme.multiverseCyan, strokeWidth: 2),
                          )
                        : const Text(
                            'CONNECT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppTheme.multiverseCyan,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (connectionProvider.errorMessage != null) ...[
                  Text(
                    connectionProvider.errorMessage!,
                    style: const TextStyle(color: AppTheme.glitchMagenta, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  connectionProvider.isConnecting
                      ? 'Connecting...'
                      : (connectionProvider.isConnected ? 'Connected' : 'Disconnected'),
                  style: TextStyle(
                    color: connectionProvider.isConnected
                        ? AppTheme.multiverseCyan
                        : AppTheme.textColorMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (discoveryService.devices.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Discovered Devices',
                    style: TextStyle(
                      color: AppTheme.multiverseCyan,
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: discoveryService.devices.length,
                    itemBuilder: (context, index) {
                      final device = discoveryService.devices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.wireframe.withValues(alpha: 0.5),
                          border: Border.all(color: AppTheme.wireframe),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.memory, color: AppTheme.multiverseCyan),
                          title: Text(device.name, style: const TextStyle(color: AppTheme.textColorPrimary)),
                          subtitle: Text(device.ipAddress, style: const TextStyle(color: AppTheme.textColorMuted)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.glitchMagenta),
                          onTap: () {
                            _ipController.text = device.ipAddress;
                            _connect();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
