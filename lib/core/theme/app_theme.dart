import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.family,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: AppFonts.family),
        ),
      ),
    );

    return base.copyWith(
      textTheme: AppTypography.textTheme(base.textTheme),
      primaryTextTheme: AppTypography.textTheme(base.primaryTextTheme),
    );
  }
}
