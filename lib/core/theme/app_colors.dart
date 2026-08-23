import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color brand = Color(0xFF6C4FD0);
  static const Color brandHi = Color(0xFF8B6FE0);
  static const Color brandLo = Color(0xFF3D2B6B);
  static const Color seed = Color(0xFF6C4FD0);
  static const Color splash = Color(0xFF3D2B6B);
  static const Color breath = Color(0xFF6C4FD0);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onSplash = Color(0xFFF4F0EA);

  static const Color canvas = Color(0xFFFFFFFF);
  static const Color home = Color(0xFFFDF2E6);
  static const Color surface = Color(0xFFF3EEFC);
  static const Color washTop = Color(0xFFF3EEFC);
  static const Color washBottom = Color(0xFFF3EEFC);
  static const Color ink = Color(0xFF3D2B6B);
  static const Color inkMuted = Color(0xFF6B6B76);
  static const Color gold = Color(0xFFF2A93B);
  static const Color positive = Color(0xFF4CAF7D);
  static const Color sos = Color(0xFFE2574C);
  static const Color sosDeep = Color(0xFFB03A4A);

  static const Color ctaLip = Color(0xFF3D2B6B);
  static const Color optionLine = Color(0xFFE4DCF5);
  static const Color optionFill = Color(0xFFF3EEFC);
  static const Color optionSelected = Color(0xFFE7DFF8);
  static const Color track = Color(0xFFE4DCF5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color handled = Color(0xFF4CAF7D);
  static const Color handledFill = Color(0xFFDCEFE4);
  static const Color warmth = Color(0xFFF3E6C4);
  static const Color faceDark = Color(0xFF3D2B6B);

  static List<BoxShadow> get lift {
    return [
      BoxShadow(
        color: const Color(0xFF6C4FD0).withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> get liftPressed {
    return [
      BoxShadow(
        color: const Color(0xFF6C4FD0).withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
