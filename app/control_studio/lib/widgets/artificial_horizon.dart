import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';

class ArtificialHorizon extends StatelessWidget {
  const ArtificialHorizon({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch telemetry state for Pitch and Roll (Assuming they are available, or mock them based on joystick)
    // We will use joystick inputs to simulate pitch/roll since real telemetry doesn't have it yet.
    // In a real scenario, this would read from telemetryService.state.pitch / roll
    // For visual simulation, we'll watch the ControlProvider if Telemetry is missing pitch.
    
    // As a placeholder, we use 0, but you could map this to live data later.
    double pitch = 0.0; 
    double roll = 0.0;

    return GlassPanel(
      width: 150,
      height: 150,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(75), // Circle
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Horizon Background Map
            Transform.rotate(
              angle: -roll * (pi / 180.0), // Roll rotation
              child: Transform.translate(
                offset: Offset(0, pitch * 2.0), // Pitch translation (2 pixels per degree)
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A), // Dark smokey blue
                        AppTheme.leapOfFaithRed.withValues(alpha: 0.8), // Dark red
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 0.5], // Hard line at center
                    ),
                  ),
                  child: CustomPaint(painter: _PitchLadderPainter()),
                ),
              ),
            ),
            
            // Fixed Center Reticle
            const Icon(
              Icons.add,
              color: AppTheme.multiverseCyan,
              size: 32,
            ),

            // Top indicator
            Positioned(
              top: 8,
              child: Container(
                width: 4,
                height: 12,
                color: AppTheme.glitchMagenta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchLadderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.stencilWhite.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;

    final double center = size.height / 2;
    final double width = size.width;

    // Draw pitch lines every 10 degrees (20 pixels per 10 deg)
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue; // Skip horizon
      
      double y = center - (i * 20.0);
      double lineWidth = i.abs() % 2 == 0 ? 40.0 : 20.0; // Alternating widths
      
      canvas.drawLine(Offset((width / 2) - lineWidth, y), Offset((width / 2) + lineWidth, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
