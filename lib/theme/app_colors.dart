import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0471B6);

  // Texts
  static const Color textDark = Color(0xFF333744);
  static const Color textLight = Color(0xFF717686);

  // Backgrounds
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgSecondary = Color(0xFFE7F2F8);

  // Borders
  static const Color borderStroke = Color(0xFFD0D2D4);

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0471B6,
    <int, Color>{
      50: Color(0xFFE8F4FB),
      100: Color(0xFFC6E3F5),
      200: Color(0xFFA0D1EF),
      300: Color(0xFF7ABEE9),
      400: Color(0xFF5DB0E4),
      500: Color(0xFF0471B6), // Primary color
      600: Color(0xFF0366A3),
      700: Color(0xFF03598E),
      800: Color(0xFF024D7A),
      900: Color(0xFF023A5C),
    },
  );
}
