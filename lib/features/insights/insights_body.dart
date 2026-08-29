import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/hud_chips.dart';

class InsightsBody extends StatefulWidget {
  const InsightsBody({super.key});

  @override
  State<InsightsBody> createState() => _InsightsBodyState();
}

class _InsightsBodyState extends State<InsightsBody> {
  DateTime? _heatFocus;
  DateTime? _chartFocus;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final week = store.weekDays;
    final today = AppStore.dateOnly(DateTime.now());
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HudStatRow(hearts: store.hearts, streak: store.checkInStreak),
        const SizedBox(height: 12),
        _StatRow(
          waves: store.panicThisMonth,
          showedUp: store.showedUpDaysInMonth(now),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _WeekChart(
            store: store,
            week: week,
            today: today,
            focus: _chartFocus,
            onSelect: (day) => setState(() => _chartFocus = day),
          ),
        ),
        const SizedBox(height: 8),
        _HabitCard(
          title: 'Check-in',
          icon: CupertinoIcons.checkmark_circle_fill,
          days: week,
          today: today,
          doneOn: store.hasCheckInOn,
        ),
        _HabitCard(
          title: 'Stayed with a wave',
          icon: CupertinoIcons.heart_fill,
          days: week,
          today: today,
          doneOn: store.stayedWithOn,
        ),
        _HabitCard(
          title: 'Caught it early',
          icon: CupertinoIcons.sun_min_fill,
          days: week,
          today: today,
          doneOn: store.caughtEarlyOn,
        ),
        const SizedBox(height: 8),
        _GithubHeat(
          store: store,
          today: today,
          focus: _heatFocus,
          onSelect: (day) => setState(() => _heatFocus = day),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.waves, required this.showedUp});

  final int waves;
  final int showedUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$waves',
            label: waves == 1 ? 'Wave' : 'Waves',
            hint: 'this month',
            semantics: '$waves waves this month',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '$showedUp',
            label: 'Showed up',
            hint: 'this month',
            semantics: 'Showed up $showedUp days this month',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.hint,
    required this.semantics,
  });

  final String value;
  final String label;
  final String hint;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      child: BunlyCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.ui(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.ui(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                hint,
                style: AppTypography.ui(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({
    required this.store,
    required this.week,
    required this.today,
    required this.focus,
    required this.onSelect,
  });

  final AppStore store;
  final List<DateTime> week;
  final DateTime today;
  final DateTime? focus;
  final ValueChanged<DateTime> onSelect;

  static const _names = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  static String _moodLine(double? mood) {
    if (mood == null) return 'no check-in';
    if (mood <= 1.5) return 'heavy';
    if (mood <= 2.5) return 'a little heavy';
    if (mood <= 3.5) return 'okay';
    if (mood <= 4.5) return 'calm';
    return 'light';
  }

  @override
  Widget build(BuildContext context) {
    final focused = focus ?? today;
    final mood = store.moodAverageOn(focused);
    final inWeek = week.any((day) => AppStore.sameDay(day, focused));

    return BunlyCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'How the week felt',
                  style: AppTypography.ui(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                if (inWeek)
                  Text(
                    '${_names[focused.weekday - 1]} · ${_moodLine(mood)}',
                    style: AppTypography.ui(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE8DFD4)),
                    left: BorderSide(color: Color(0xFFE8DFD4)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < week.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Expanded(
                        child: _ChartBar(
                          name: _names[i],
                          mood: store.moodAverageOn(week[i]),
                          selected: AppStore.sameDay(week[i], focused),
                          future: week[i].isAfter(today),
                          delay: 0.06 * i,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            AppAudio.tap();
                            onSelect(week[i]);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final name in _names)
                  Expanded(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.name,
    required this.mood,
    required this.selected,
    required this.future,
    required this.delay,
    required this.onTap,
  });

  final String name;
  final double? mood;
  final bool selected;
  final bool future;
  final double delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = mood == null || future;
    final target = empty
        ? 0.08
        : (0.18 + ((mood ?? 0) / 5).clamp(0.0, 1.0) * 0.72);
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduce ? target : 0.06, end: target),
          duration: Duration(milliseconds: reduce ? 0 : 640),
          curve: Interval(delay, 1, curve: Curves.easeOutCubic),
          builder: (context, h, _) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: h.clamp(0.06, 1),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 16 : 12,
                    decoration: BoxDecoration(
                      color: empty
                          ? const Color(0xFFEFE6DA)
                          : selected
                          ? AppColors.brand
                          : AppColors.brandHi,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.title,
    required this.icon,
    required this.days,
    required this.today,
    required this.doneOn,
  });

  final String title;
  final IconData icon;
  final List<DateTime> days;
  final DateTime today;
  final bool Function(DateTime day) doneOn;

  @override
  Widget build(BuildContext context) {
    final done = days.where((day) => !day.isAfter(today) && doneOn(day)).length;
    final outOf = days.where((day) => !day.isAfter(today)).length.clamp(1, 7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: BunlyCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.inkMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '$done/$outOf',
                style: AppTypography.ui(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 118,
                child: Row(
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        child: _DayMark(
                          day: days[i],
                          today: today,
                          done: doneOn(days[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayMark extends StatelessWidget {
  const _DayMark({required this.day, required this.today, required this.done});

  final DateTime day;
  final DateTime today;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final future = day.isAfter(today);
    final isToday = AppStore.sameDay(day, today);

    return Semantics(
      label: '${day.month}/${day.day}${done ? ', done' : ''}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 10,
        decoration: BoxDecoration(
          color: done
              ? AppColors.brand
              : future
              ? const Color(0xFFF6F1EA)
              : const Color(0xFFEFE6DA),
          borderRadius: BorderRadius.circular(99),
          border: isToday
              ? Border.all(color: AppColors.brand, width: 1.2)
              : null,
        ),
      ),
    );
  }
}

class _GithubHeat extends StatelessWidget {
  const _GithubHeat({
    required this.store,
    required this.today,
    required this.focus,
    required this.onSelect,
  });

  final AppStore store;
  final DateTime today;
  final DateTime? focus;
  final ValueChanged<DateTime> onSelect;

  static const _names = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  static const _fills = [
    Color(0xFFEFE6DA),
    Color(0xFFE7DFF8),
    Color(0xFFCDBDF0),
    Color(0xFF8B6FE0),
    Color(0xFF6C4FD0),
  ];

  @override
  Widget build(BuildContext context) {
    final focused = focus ?? today;
    final heat = store.heatOn(focused);
    final line = heat == 0
        ? 'quiet'
        : heat == 1
        ? 'a little'
        : heat >= 4
        ? 'full'
        : 'solid';

    return BunlyCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Your month',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '${focused.month}/${focused.day} · $line',
                  style: AppTypography.ui(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 3.0;
                const labelW = 18.0;
                const target = 11.0;
                final usable = constraints.maxWidth - labelW - 6;
                final weeks = ((usable + gap) / (target + gap)).floor().clamp(
                  8,
                  26,
                );
                final cell = (usable - (weeks - 1) * gap) / weeks;
                final days = store.heatDays(weeks: weeks);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: labelW,
                      child: Column(
                        children: [
                          for (var r = 0; r < 7; r++)
                            SizedBox(
                              height: cell + (r == 6 ? 0 : gap),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  r.isEven ? _names[r] : '',
                                  style: AppTypography.ui(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        for (var week = 0; week < weeks; week++) ...[
                          if (week > 0) const SizedBox(width: gap),
                          Column(
                            children: [
                              for (var d = 0; d < 7; d++) ...[
                                if (d > 0) const SizedBox(height: gap),
                                _HeatDot(
                                  size: cell,
                                  day: days[week * 7 + d],
                                  today: today,
                                  heat: store.heatOn(days[week * 7 + d]),
                                  selected: AppStore.sameDay(
                                    days[week * 7 + d],
                                    focused,
                                  ),
                                  fills: _fills,
                                  onSelect: onSelect,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatDot extends StatelessWidget {
  const _HeatDot({
    required this.size,
    required this.day,
    required this.today,
    required this.heat,
    required this.selected,
    required this.fills,
    required this.onSelect,
  });

  final double size;
  final DateTime day;
  final DateTime today;
  final int heat;
  final bool selected;
  final List<Color> fills;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final future = day.isAfter(today);

    return Semantics(
      button: true,
      label: '${day.month}/${day.day}, heat $heat',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          AppAudio.tap();
          onSelect(day);
        },
        child: AnimatedScale(
          scale: selected ? 1.16 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: future ? const Color(0xFFF7F3EC) : fills[heat.clamp(0, 4)],
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: selected ? AppColors.brand : const Color(0x00FFFFFF),
                width: selected ? 1.2 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
