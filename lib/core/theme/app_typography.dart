import 'package:flutter/material.dart';

import 'app_fonts.dart';

abstract final class AppTypography {
  static String get family => AppFonts.family;

  static TextStyle display({
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
    double height = 1.15,
    double letterSpacing = -0.6,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: TextDecoration.none,
    );
  }

  static TextStyle ui({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.4,
    double letterSpacing = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: TextDecoration.none,
    );
  }

  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: display(fontSize: 48, letterSpacing: -1.2),
      displayMedium: display(fontSize: 40, letterSpacing: -0.9),
      displaySmall: display(fontSize: 34, letterSpacing: -0.6),
      headlineLarge: display(fontSize: 28, letterSpacing: -0.5),
      headlineMedium: display(fontSize: 24, letterSpacing: -0.4),
      headlineSmall: display(fontSize: 20, letterSpacing: -0.3),
      titleLarge: ui(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: ui(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: ui(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: ui(fontSize: 17, fontWeight: FontWeight.w400, height: 1.45),
      bodyMedium: ui(fontSize: 15, fontWeight: FontWeight.w400, height: 1.45),
      bodySmall: ui(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: ui(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: ui(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: ui(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
