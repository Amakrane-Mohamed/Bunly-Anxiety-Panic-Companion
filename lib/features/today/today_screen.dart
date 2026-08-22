import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/profile/user_plan.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../checkin/checkin_screen.dart';
import '../panic/panic_entry_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final name = UserPlan.instance.firstName;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.washTop, Color(0xFFF7F1FC), AppColors.canvas],
              stops: [0, 0.38, 1],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                FadeUp(
                  child: Text(
                    '$_greeting, $name',
                    style: AppTypography.display(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeUp(
                  delay: const Duration(milliseconds: 60),
                  child: Text(
                    store.checkedInToday
                        ? 'I’m here. We already checked in today.'
                        : 'How’s this moment feeling?',
                    style: AppTypography.ui(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeUp(
                  delay: const Duration(milliseconds: 100),
                  child: Center(
                    child: Image.asset(
                      store.checkedInToday
                          ? BunlyPoses.proud
                          : BunlyPoses.sitting,
                      height: 168,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeUp(
                  delay: const Duration(milliseconds: 140),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: 'Handled',
                          value: '${store.handledMoments}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatChip(
                          label: 'Check-ins',
                          value: '${store.checkIns.length}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FadeUp(
                  delay: const Duration(milliseconds: 180),
                  child: BunlyPrimaryButton(
                    label: 'I need you',
                    onPressed: () => PanicEntrySheet.show(context),
                  ),
                ),
                const SizedBox(height: 12),
                FadeUp(
                  delay: const Duration(milliseconds: 220),
                  child: _ActionCard(
                    title: store.checkedInToday
                        ? 'Checked in'
                        : 'Daily check-in',
                    subtitle: store.checkedInToday
                        ? 'Come back tomorrow — questions will change.'
                        : '30 seconds. Helps Bunly learn your days.',
                    cta: store.checkedInToday ? 'Update' : 'Check in',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      NativeChrome.push(
                        context,
                        AppMotion.fadeTo(const CheckInScreen()),
                        title: 'Check-in',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                FadeUp(
                  delay: const Duration(milliseconds: 260),
                  child: _InsightCard(text: store.insight),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.optionLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.display(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.brand,
            ),
          ),
          Text(
            label,
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.optionLine),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.ui(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.ui(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              cta,
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: AppColors.brand,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.optionFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For you',
            style: AppTypography.ui(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
