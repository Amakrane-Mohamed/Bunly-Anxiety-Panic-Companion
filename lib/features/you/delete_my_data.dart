import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../welcome/welcome_screen.dart';

Future<void> confirmAndDeleteMyData(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.home,
        title: Text(
          'Delete my data?',
          style: AppTypography.ui(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          'This removes check-ins, notes, and companion memory on this device. It does not cancel an App Store subscription. Cancel that in Settings → your name → Subscriptions.',
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Keep data',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.inkMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.brand,
              ),
            ),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;

  HapticFeedback.mediumImpact();
  AppAudio.tap();
  await AppStore.instance.erase();
  await Access.instance.reset();
  await NativeChrome.hideTabs();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const WelcomeScreen(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
    (_) => false,
  );
}
