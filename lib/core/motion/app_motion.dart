import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration page = Duration(milliseconds: 780);
  static const Duration pageReverse = Duration(milliseconds: 680);
  static const Duration moment = Duration(milliseconds: 900);
  static const Curve curve = Cubic(0.4, 0.0, 0.2, 1.0);

  static PageRouteBuilder<T> fadeTo<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => screen,
      transitionDuration: page,
      reverseTransitionDuration: pageReverse,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: curve,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}
