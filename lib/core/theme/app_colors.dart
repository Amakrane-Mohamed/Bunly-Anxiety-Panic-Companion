import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color splash = Color(0xFF3C275C);
  static const Color breath = Color(0xFF6B4C9A);
  static const Color brand = Color(0xFF6B4C9A);
  static const Color brandHi = Color(0xFF7E5CB4);
  static const Color brandLo = Color(0xFF5A3D86);
  static const Color seed = Color(0xFF6B4C9A);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onSplash = Color(0xFFF4F0EA);

  static const Color washTop = Color(0xFFFFFCFE);
  static const Color washBottom = Color(0xFFF7F1FC);
  static const Color ink = Color(0xFF1C1529);
  static const Color inkMuted = Color(0xFF6B6278);
  static const Color ctaLip = Color(0xFF4E3478);
  static const Color optionLine = Color(0xFFE8E2F1);
  static const Color optionFill = Color(0xFFF6F1FC);
  static const Color optionSelected = Color(0xFFEEE6F8);
  static const Color track = Color(0xFFEDE7F5);
  static const Color card = Color(0xFFFFFFFF);

  static List<BoxShadow> get lift {
    return [
      BoxShadow(
        color: splash.withValues(alpha: 0.07),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: splash.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> get liftPressed {
    return [
      BoxShadow(
        color: splash.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];
  }
}
