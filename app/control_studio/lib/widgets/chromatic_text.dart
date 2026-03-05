import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChromaticText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double offsetFactor; 

  const ChromaticText(
    this.text, {
    super.key,
    required this.style,
    this.offsetFactor = 1.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        shadows: [
          // Magenta Glitch Offset Left
          Shadow(
            offset: Offset(-1.5 * offsetFactor, 0.0),
            color: AppTheme.glitchMagenta.withValues(alpha: 0.7),
            blurRadius: 1.0,
          ),
          // Cyan Glitch Offset Right
          Shadow(
            offset: Offset(1.5 * offsetFactor, 0.0),
            color: AppTheme.multiverseCyan.withValues(alpha: 0.7),
            blurRadius: 1.0,
          ),
          // Drop shadow for LCD readability
          Shadow(
            offset: const Offset(0, 2),
            color: AppTheme.voidInk.withValues(alpha: 0.9),
            blurRadius: 4.0,
          ),
        ],
      ),
    );
  }
}
