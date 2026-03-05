import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/connection_screen.dart';
import 'control_input/control_provider.dart';
import 'device_manager/discovery_service.dart';
import 'telemetry/telemetry_parser.dart';
import 'network/connection_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ControlProvider()),
          ChangeNotifierProvider(create: (_) => DiscoveryService()..startDiscovery()),
          ChangeNotifierProvider(create: (_) => TelemetryService()..startListening()),
          ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ],
        child: const ESP32ControlStudioApp(),
      ),
    );
  });
}

class ESP32ControlStudioApp extends StatelessWidget {
  const ESP32ControlStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Control Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.cyan,
        ),
      ),
      home: const ConnectionScreen(),
    );
  }
}

