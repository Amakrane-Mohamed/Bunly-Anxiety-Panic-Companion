import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../convert/paywall_screen.dart';
import '../../core/theme/app_typography.dart';
import 'journey_catalog.dart';
import 'journey_look.dart';
import 'journey_read.dart';
import 'journey_session.dart';

class JourneyBody extends StatefulWidget {
  const JourneyBody({super.key});

  @override
  State<JourneyBody> createState() => _JourneyBodyState();
}

class _JourneyBodyState extends State<JourneyBody> {
  late final Future<JourneyCatalog> _catalog = JourneyCatalog.load();
  String? _justClaimed;

  Future<void> _afterClaim(String id) async {
    if (!mounted) return;
    AppAudio.win();
    HapticFeedback.mediumImpact();
    setState(() => _justClaimed = id);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (mounted && _justClaimed == id) {
      setState(() => _justClaimed = null);
    }
  }

  Future<void> _openSession(JourneySession session) async {
    if (!await PaywallScreen.require(context)) return;
    if (!mounted) return;
    final done = await NativeChrome.push<bool>(
      context,
      AppMotion.fadeTo(JourneySessionScreen(session: session)),
      title: session.title,
    );
    if (done == true) await _afterClaim(session.id);
  }

  Future<void> _openReminder(JourneyReminder reminder) async {
    if (!await PaywallScreen.require(context)) return;
    if (!mounted) return;
    final done = await NativeChrome.push<bool>(
      context,
      AppMotion.fadeTo(
        JourneyReadScreen(
          title: 'Today’s reminder',
          claimId: 'reminder',
          pages: [
            JourneyLessonPage(title: reminder.title, body: reminder.body),
          ],
        ),
      ),
      title: 'Reminder',
    );
    if (done == true) await _afterClaim('reminder');
  }

  Future<void> _openLesson(JourneyLesson lesson) async {
    if (!await PaywallScreen.require(context)) return;
    if (!mounted) return;
    final wasDone = AppStore.instance.lessonDone(lesson.id);
    final done = await NativeChrome.push<bool>(
      context,
      AppMotion.fadeTo(
        JourneyReadScreen(
          title: 'Lesson',
          lessonId: lesson.id,
          pages: lesson.pages,
        ),
      ),
      title: lesson.title,
    );
    if (done == true && !wasDone) await _afterClaim('lesson-${lesson.id}');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JourneyCatalog>(
      future: _catalog,
      builder: (context, snap) {
        final catalog = snap.data;
        if (catalog == null) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final store = AppStore.instance;
        final reminder = catalog.reminderForToday();
        final weekday = _weekday[DateTime.now().weekday - 1];
        final allDone = store.claimsToday >= 4;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _LogoHeader(
              weekday: weekday,
              claimed: store.claimsToday,
              allDone: allDone,
              justClaimed: _justClaimed != null,
            ),
            if (_justClaimed != null) ...[
              const SizedBox(height: 10),
              const _ClaimToast(),
            ],
            const SizedBox(height: 16),
            const JourneySectionLabel('Today’s check'),
            const SizedBox(height: 8),
            for (final session in catalog.sessions)
              JourneyClaimRow(
                title: session.title,
                subtitle: session.subtitle,
                meta: '${session.minutes} min',
                art: _artFor(session.id),
                claimed: store.claimedToday(session.id),
                celebrate: _justClaimed == session.id,
                onClaim: () => _openSession(session),
              ),
            const SizedBox(height: 16),
            const JourneySectionLabel('Today’s reminder'),
            const SizedBox(height: 8),
            JourneyClaimRow(
              title: reminder.title,
              subtitle: 'Bondly wrote this on a napkin. Claim it anyway.',
              meta: '3 min',
              art: BunlyPoses.winking,
              claimed: store.claimedToday('reminder'),
              celebrate: _justClaimed == 'reminder',
              onClaim: () => _openReminder(reminder),
            ),
            const SizedBox(height: 16),
            const JourneySectionLabel('Lessons'),
            const SizedBox(height: 8),
            for (var i = 0; i < catalog.lessons.length; i++)
              _LessonRow(
                index: i + 1,
                lesson: catalog.lessons[i],
                done: store.lessonDone(catalog.lessons[i].id),
                locked: i > 0 && !store.lessonDone(catalog.lessons[i - 1].id),
                celebrate: _justClaimed == 'lesson-${catalog.lessons[i].id}',
                onOpen: () => _openLesson(catalog.lessons[i]),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

String _artFor(String id) {
  return switch (id) {
    'life' => BunlyPoses.jumping,
    'ask' => BunlyPoses.sitting,
    _ => BunlyPoses.huggingStar,
  };
}

const _weekday = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({
    required this.weekday,
    required this.claimed,
    required this.allDone,
    required this.justClaimed,
  });

  final String weekday;
  final int claimed;
  final bool allDone;
  final bool justClaimed;

  @override
  Widget build(BuildContext context) {
    final line = justClaimed
        ? 'Claimed. Bondly did a tiny private dance.'
        : allDone
        ? 'Four for four. Disgustingly competent.'
        : 'Claim the rows. I’m keeping score. Badly.';

    return JourneyBrandCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AppAssets.bunlyIcon,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s path',
                    style: AppTypography.ui(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$weekday · $claimed of 4 claimed',
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line,
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimToast extends StatelessWidget {
  const _ClaimToast();

  @override
  Widget build(BuildContext context) {
    return JourneyBrandCard(
      claimed: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Image.asset(
              BunlyPoses.proud,
              height: 44,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'In the bag. Checkmark acquired. Very official.',
                style: AppTypography.ui(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.index,
    required this.lesson,
    required this.done,
    required this.locked,
    required this.celebrate,
    required this.onOpen,
  });

  final int index;
  final JourneyLesson lesson;
  final bool done;
  final bool locked;
  final bool celebrate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: locked ? 0.5 : 1,
        child: GestureDetector(
          onTap: locked
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  AppAudio.tap();
                  onOpen();
                },
          child: JourneyBrandCard(
            claimed: done,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  JourneyStampCheck(claimed: done, celebrate: celebrate),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          done
                              ? 'Done · ${lesson.title}'
                              : '$index. ${lesson.title}',
                          style: AppTypography.ui(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          locked
                              ? 'Read the one above first. Bondly is petty like that.'
                              : done
                              ? 'Claimed. Your brain did a sit-up.'
                              : '${lesson.minutes} min read',
                          style: AppTypography.ui(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    locked
                        ? CupertinoIcons.lock_fill
                        : done
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.book_fill,
                    size: 18,
                    color: done ? AppColors.brand : AppColors.ink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
