import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingOptionTile extends StatefulWidget {
  const OnboardingOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<OnboardingOptionTile> createState() => _OnboardingOptionTileState();
}

class _OnboardingOptionTileState extends State<OnboardingOptionTile> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? AppColors.brand.withValues(alpha: 0.42)
                    : AppColors.optionLine,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: _pressed
                  ? AppColors.liftPressed
                  : selected
                  ? [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : AppColors.lift,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: selected
                    ? const [Color(0xFFF8F4FC), AppColors.optionSelected]
                    : const [Color(0xFFFFFFFF), Color(0xFFFBF9FE)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTypography.ui(
                      fontSize: 18,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.25,
                      letterSpacing: -0.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.brand : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.brand : AppColors.optionLine,
                      width: 1.6,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.brand.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.onBrand,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
