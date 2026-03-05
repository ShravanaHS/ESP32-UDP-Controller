import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/vector_joystick.dart';
import '../widgets/neon_button.dart';
import '../widgets/slide_to_arm.dart';
import '../widgets/telemetry_panel.dart';
import '../widgets/satellite_plot.dart';
import '../theme/app_theme.dart';
import '../control_input/control_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlProvider = Provider.of<ControlProvider>(context);
    final state = controlProvider.state;

    return Scaffold(
      backgroundColor: AppTheme.voidInk,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Top: Telemetry Panel
              const Expanded(
                flex: 12,
                child: TelemetryPanel(),
              ),
              const SizedBox(height: 16),
              // Middle: Joysticks and Buttons
              Expanded(
                flex: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Column: Satellite Plot + Joystick
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                          child: Selector<ControlProvider, Offset>(
                            selector: (_, p) => Offset(p.state.joystick1XNorm, p.state.joystick1YNorm),
                            builder: (context, pos, _) {
                              return SatellitePlot(
                                size: 85,
                                joystickPos: pos,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        VectorJoystickWidget(
                          size: 130,
                          onChanged: (pos) {
                            double curvedX = pos.dx * pos.dx * pos.dx;
                            double curvedY = pos.dy * pos.dy * pos.dy;
                            int x = ((curvedX + 1.0) / 2.0 * 255).round().clamp(0, 255);
                            int y = ((curvedY + 1.0) / 2.0 * 255).round().clamp(0, 255);
                            controlProvider.updateJoystick1(x, y, pos.dx, pos.dy);
                          },
                        ),
                      ],
                    ),
                    // Center Buttons Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return NeonPulseButton(
                              label: 'B${index + 1}',
                              onPressed: (val) {
                                controlProvider.updateButton(index, val);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    // Right Column: Satellite Plot + Joystick
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                          child: Selector<ControlProvider, Offset>(
                            selector: (_, p) => Offset(p.state.joystick2XNorm, p.state.joystick2YNorm),
                            builder: (context, pos, _) {
                              return SatellitePlot(
                                size: 85,
                                joystickPos: pos,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        VectorJoystickWidget(
                          size: 130,
                          onChanged: (pos) {
                            double curvedX = pos.dx * pos.dx * pos.dx;
                            double curvedY = pos.dy * pos.dy * pos.dy;
                            int x = ((curvedX + 1.0) / 2.0 * 255).round().clamp(0, 255);
                            int y = ((curvedY + 1.0) / 2.0 * 255).round().clamp(0, 255);
                            controlProvider.updateJoystick2(x, y, pos.dx, pos.dy);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom Switches Row
              Expanded(
                flex: 25,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SlideToArmWidget(
                          label: index == 0 ? 'ARM SYSTEM' : 'SW${index + 1}',
                          initialValue: state.toggleStates[index],
                          onChanged: (val) {
                            controlProvider.updateToggle(index, val);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
