import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'panic_mode_screen.dart';

abstract final class PanicEntrySheet {
  static Future<void> show(BuildContext context) async {
    HapticFeedback.lightImpact();
    await NativeChrome.hideForPanic();
    if (!context.mounted) return;
    final comingOn = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.optionLine,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Image.asset(
                        BunlyPanic.readyToHelp,
                        height: 92,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'I’m here.',
                        style: AppTypography.display(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You don’t need to fix anything right now.',
                        textAlign: TextAlign.center,
                        style: AppTypography.ui(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Choice(
                        label: 'I’m panicking',
                        onTap: () => Navigator.of(sheetContext).pop(false),
                      ),
                      const SizedBox(height: 10),
                      _Choice(
                        label: 'I feel it coming',
                        onTap: () => Navigator.of(sheetContext).pop(true),
                      ),
                      const SizedBox(height: 6),
                      CupertinoButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          'Not now',
                          style: AppTypography.ui(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;
    if (comingOn == null) {
      await NativeChrome.showRoot();
      return;
    }

    final episode = AppStore.instance.startPanic(comingOn: comingOn);
    if (!context.mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(AppMotion.fadeTo(PanicModeScreen(episode: episode)));
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.optionLine),
        ),
        child: Text(
          label,
          style: AppTypography.ui(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
