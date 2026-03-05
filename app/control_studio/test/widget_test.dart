// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:control_studio/screens/dashboard_screen.dart';
import 'package:control_studio/widgets/telemetry_panel.dart';
import 'package:control_studio/control_input/control_provider.dart';
import 'package:control_studio/device_manager/discovery_service.dart';
import 'package:control_studio/telemetry/telemetry_parser.dart';
import 'package:control_studio/network/connection_provider.dart';

void main() {
  testWidgets('App boots to dashboard test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to provide the services because DashboardScreen expects them.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ControlProvider()),
          ChangeNotifierProvider(create: (_) => DiscoveryService()),
          ChangeNotifierProvider(create: (_) => TelemetryService()),
          ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Verify that our dashboard screen and telemetry panel are found.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(TelemetryPanel), findsOneWidget);
  });
}
