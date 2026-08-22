import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'lesson_screen.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  static const lessons = [
    (
      title: 'Understand panic',
      takeaway: 'A wave is a body alarm, not proof of danger.',
    ),
    (
      title: 'Understand symptoms',
      takeaway: 'Racing heart, breath, and thoughts can all be the same wave.',
    ),
    (
      title: 'The fear cycle',
      takeaway: 'Fear of the wave can make the wave feel bigger.',
    ),
    (
      title: 'Triggers',
      takeaway: 'Noticing a pattern is not blaming yourself for it.',
    ),
    (
      title: 'Confidence',
      takeaway: 'Confidence grows from staying with a moment, not avoiding it.',
    ),
    (
      title: 'If it returns',
      takeaway: 'A return is not a reset. You already know the way through.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final unlocked = store.journeyUnlocked;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                '${store.completedLessons.length} of ${lessons.length} paths walked',
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  store.completedLessons.length >= lessons.length
                      ? BunlyJourney.graduation
                      : store.completedLessons.isEmpty
                      ? BunlyJourney.firstStep
                      : BunlyJourney.pathAhead,
                  height: 140,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < lessons.length; i++) ...[
                _PathNode(
                  index: i,
                  title: lessons[i].title,
                  done: store.completedLessons.contains(i),
                  current: i == unlocked && !store.completedLessons.contains(i),
                  locked: i > unlocked,
                  alignRight: i.isOdd,
                  onTap: i > unlocked
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          NativeChrome.push(
                            context,
                            AppMotion.fadeTo(
                              LessonScreen(
                                index: i,
                                title: lessons[i].title,
                                takeaway: lessons[i].takeaway,
                              ),
                            ),
                            title: lessons[i].title,
                          );
                        },
                ),
                if (i < lessons.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.index,
    required this.title,
    required this.done,
    required this.current,
    required this.locked,
    required this.alignRight,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool done;
  final bool current;
  final bool locked;
  final bool alignRight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final node = GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.38 : 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight && current)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  BunlyPoses.sitting,
                  height: 52,
                  filterQuality: FilterQuality.high,
                ),
              ),
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || current ? AppColors.brand : AppColors.optionFill,
                border: Border.all(
                  color: current ? AppColors.brandHi : AppColors.optionLine,
                  width: current ? 3 : 1,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: AppTypography.ui(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: current || done
                            ? Colors.white
                            : AppColors.inkMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: Text(
                title,
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (alignRight && current)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Image.asset(
                  BunlyPoses.sitting,
                  height: 52,
                  filterQuality: FilterQuality.high,
                ),
              ),
          ],
        ),
      ),
    );

    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: node,
    );
  }
}
