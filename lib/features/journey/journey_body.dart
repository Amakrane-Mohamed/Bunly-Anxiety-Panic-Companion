import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../convert/paywall_screen.dart';
import 'journey_catalog.dart';
import 'journey_path.dart';
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
    await Future<void>.delayed(const Duration(milliseconds: 1600));
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
        final todayDone = store.claimsToday;
        final lessonsDone = catalog.lessons
            .where((lesson) => store.lessonDone(lesson.id))
            .length;

        final todayNodes = <JourneyPathNode>[
          for (final session in catalog.sessions)
            JourneyPathNode(
              id: session.id,
              title: session.title,
              icon: _iconFor(session.id),
              done: store.claimedToday(session.id),
              locked: false,
              onOpen: () => _openSession(session),
            ),
          JourneyPathNode(
            id: 'reminder',
            title: reminder.title,
            icon: CupertinoIcons.sparkles,
            done: store.claimedToday('reminder'),
            locked: false,
            gold: true,
            onOpen: () => _openReminder(reminder),
          ),
        ];

        final lessonNodes = <JourneyPathNode>[
          for (var i = 0; i < catalog.lessons.length; i++)
            JourneyPathNode(
              id: 'lesson-${catalog.lessons[i].id}',
              title: catalog.lessons[i].title,
              icon: CupertinoIcons.book_fill,
              done: store.lessonDone(catalog.lessons[i].id),
              locked: i > 0 && !store.lessonDone(catalog.lessons[i - 1].id),
              onOpen: () => _openLesson(catalog.lessons[i]),
            ),
        ];

        final currentId = _currentId([...todayNodes, ...lessonNodes]);

        return ListView(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          children: [
            _PathHeader(
              weekday: weekday,
              claimed: todayDone,
              justClaimed: _justClaimed != null,
            ),
            const SizedBox(height: 14),
            JourneyUnitBanner(
              kicker: 'SECTION 1, UNIT 1',
              title: 'Today’s check',
              progress: '$todayDone / 4',
            ),
            JourneySnake(
              nodes: todayNodes,
              pathFrom: 0,
              currentId: currentId,
            ),
            const SizedBox(height: 10),
            JourneyUnitBanner(
              kicker: 'SECTION 2, UNIT 1',
              title: 'Lessons',
              progress: '$lessonsDone / ${catalog.lessons.length}',
              color: AppColors.brandLo,
            ),
            JourneySnake(
              nodes: lessonNodes,
              pathFrom: todayNodes.length,
              currentId: currentId,
            ),
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}

String? _currentId(List<JourneyPathNode> nodes) {
  for (final node in nodes) {
    if (!node.done && !node.locked) return node.id;
  }
  if (nodes.isEmpty) return null;
  return nodes.last.id;
}

IconData _iconFor(String id) {
  return switch (id) {
    'life' => CupertinoIcons.sun_min_fill,
    'ask' => CupertinoIcons.chat_bubble_fill,
    _ => CupertinoIcons.heart_fill,
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

class _PathHeader extends StatelessWidget {
  const _PathHeader({
    required this.weekday,
    required this.claimed,
    required this.justClaimed,
  });

  final String weekday;
  final int claimed;
  final bool justClaimed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          justClaimed ? 'Claimed.' : 'Today’s path',
          style: AppTypography.display(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.7,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$weekday · $claimed of 4',
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  height: 8,
                  decoration: BoxDecoration(
                    color: i < claimed
                        ? AppColors.brand
                        : const Color(0xFFDCC9A8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
