import 'package:flutter/material.dart';

class AppTheme {
  static const Color voidInk = Color(0xFF080808);
  static const Color leapOfFaithRed = Color(0xFFE63946);
  static const Color multiverseCyan = Color(0xFF00F2FF);
  static const Color glitchMagenta = Color(0xFFFF00FF);
  static const Color wireframe = Color(0xFF1A1A1A);
  
  static const Color textColorPrimary = Colors.white;
  static const Color textColorMuted = Color(0xFF888888);

  static const String digitalFontFamily = 'Roboto';

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: voidInk,
      primaryColor: multiverseCyan,
      colorScheme: const ColorScheme.dark(
        primary: multiverseCyan,
        secondary: glitchMagenta,
        surface: wireframe,
      ),
    );
  }
}
