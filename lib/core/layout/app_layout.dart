import 'package:flutter/widgets.dart';

/// Phone-first layout that stays readable on iPad and Split View.
abstract final class AppLayout {
  /// Comfortable column width — about an iPhone Pro Max, not a stretched iPad.
  static const contentMax = 480.0;

  /// Bottom sheets and action clusters.
  static const sheetMax = 520.0;

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width > contentMax + 40;
  }
}
