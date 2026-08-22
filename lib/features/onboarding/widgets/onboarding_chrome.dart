import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WelcomeQuestion extends StatelessWidget {
  const WelcomeQuestion({
    super.key,
    required this.text,
    this.highlight,
    this.fontSize = 32,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final String? highlight;
  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.display(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.16,
      letterSpacing: -0.8,
      color: AppColors.inkMuted,
    );
    final emph = AppTypography.display(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.16,
      letterSpacing: -0.8,
      color: AppColors.ink,
    );

    final mark = highlight;
    if (mark == null || mark.isEmpty || !text.contains(mark)) {
      return Text(text, textAlign: textAlign, style: base);
    }

    final i = text.indexOf(mark);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (i > 0) TextSpan(text: text.substring(0, i)),
          TextSpan(text: mark, style: emph),
          if (i + mark.length < text.length)
            TextSpan(text: text.substring(i + mark.length)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.progress,
    required this.onBack,
  });

  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            onBack();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.optionFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.track,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 780),
                curve: const Cubic(0.4, 0.0, 0.2, 1.0),
                widthFactor: progress.clamp(0.1, 1),
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.brandHi, AppColors.brand],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
