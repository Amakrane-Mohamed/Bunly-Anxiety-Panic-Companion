import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'bunly_button.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.illustration,
    required this.headline,
    required this.message,
    this.cta,
    this.onCta,
  });

  final String illustration;
  final String headline;
  final String message;
  final String? cta;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.lift,
      ),
      child: Column(
        children: [
          Image.asset(
            illustration,
            height: 96,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.inkMuted,
            ),
          ),
          if (cta != null && onCta != null) ...[
            const SizedBox(height: 16),
            BunlyPrimaryButton(label: cta!, onPressed: onCta),
          ],
        ],
      ),
    );
  }
}
