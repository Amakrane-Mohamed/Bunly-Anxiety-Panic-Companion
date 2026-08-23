import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BunlyCard extends StatelessWidget {
  const BunlyCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.optionLine),
      ),
      child: child,
    );
  }
}
