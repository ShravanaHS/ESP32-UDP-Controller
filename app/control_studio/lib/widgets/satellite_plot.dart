import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SatellitePlot extends StatelessWidget {
  final double size; // square size
  final Offset joystickPos; // normalized -1..1

  const SatellitePlot({
    super.key,
    required this.size,
    required this.joystickPos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.4), // Smokey Glass
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1), // Faint grey boundary
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomPaint(
            painter: _SatellitePainter(joystickPos: joystickPos),
          ),
        ),
      ),
    );
  }
}

class _SatellitePainter extends CustomPainter {
  final Offset joystickPos;
  _SatellitePainter({required this.joystickPos});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintGrid = Paint()
      ..color = Colors.white.withValues(alpha: 0.15) // Faint crosshairs
      ..strokeWidth = 1;

    // Draw Static Crosshairs
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paintGrid);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paintGrid);

    // Draw Leap-of-Faith Red dot
    final dotPaint = Paint()
      ..color = AppTheme.leapOfFaithRed
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Map joystickPos (-1..1) to pixel coordinates
    final dx = (joystickPos.dx + 1) / 2 * size.width;
    final dy = (1 - joystickPos.dy) / 2 * size.height; // invert Y to match UI
    
    canvas.drawCircle(Offset(dx, dy), 5, dotPaint);
    canvas.drawCircle(Offset(dx, dy), 5, Paint()..color = Colors.white.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant _SatellitePainter oldDelegate) => oldDelegate.joystickPos != joystickPos;
}
