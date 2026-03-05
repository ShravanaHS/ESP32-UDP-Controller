import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlitchOverlay extends StatelessWidget {
  final Widget child;
  const GlitchOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Tactile Noise / Printed Paper Filter
        IgnorePointer(
          child: Opacity(
            opacity: 0.03, // Very subtle
            child: CustomPaint(
              painter: _NoisePainter(),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  final Random _rnd = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.stencilWhite
      ..style = PaintingStyle.fill;

    // Draw random tiny dots to simulate paper grain/noise
    // Optimized: only draw a sparse amount so it doesn't wreck 60FPS
    for (int i = 0; i < 2000; i++) {
      double x = _rnd.nextDouble() * size.width;
      double y = _rnd.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), paint);
    }
  }

  // Returning true gives a slight "flickering" noise on redraws, adding to the glitch aesthetic.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; 
}
