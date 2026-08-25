import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/legal/legal_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

abstract final class CrisisSheet {
  static Future<void> open(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.home,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'If this is an emergency',
                  style: AppTypography.display(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bunly is a companion, not medical care or crisis support. If you are in danger, call your local emergency number.',
                  style: AppTypography.ui(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'In the US and Canada, 988 is the Suicide & Crisis Lifeline.',
                  style: AppTypography.ui(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                _CrisisButton(
                  label: 'Call 988',
                  filled: true,
                  onTap: () => LegalLinks.call988(),
                ),
                const SizedBox(height: 8),
                _CrisisButton(
                  label: 'Text 988',
                  filled: false,
                  onTap: () => LegalLinks.text988(),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Stay here',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CrisisButton extends StatelessWidget {
  const _CrisisButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? AppColors.sos : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: filled ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
