import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../convert/paywall_screen.dart';
import '../panic/panic_entry_sheet.dart';
import '../talk/talk_screen.dart';

class TodayHomeBody extends StatelessWidget {
  const TodayHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeekStrip(),
        SizedBox(height: 10),
        _PairRow(),
        _ActionCard(
          title: 'Know the pattern',
          subtitle: 'Tell Bondly what’s here.',
          icon: CupertinoIcons.eye_fill,
          onTalk: true,
        ),
      ],
    );
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Help',
                subtitle: 'Tell me what you need.',
                icon: CupertinoIcons.heart_fill,
                onHelp: true,
                compact: true,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ActionCard(
                title: 'A wave is coming',
                subtitle: 'Catch it early, together.',
                icon: CupertinoIcons.sun_min_fill,
                onComing: true,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  static const _names = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return BunlyCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        child: Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _DayCell(
                  name: _names[i],
                  date: days[i],
                  isToday: AppStore.sameDay(days[i], today),
                  marked: store.hasCheckInOn(days[i]) ||
                      store.hasPanicOn(days[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.name,
    required this.date,
    required this.isToday,
    required this.marked,
  });

  final String name;
  final DateTime date;
  final bool isToday;
  final bool marked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: AppTypography.ui(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: isToday ? AppColors.brand : AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppColors.brand : AppColors.optionFill,
          ),
          child: Text(
            '${date.day}',
            style: AppTypography.ui(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isToday ? Colors.white : AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 6,
          child: marked
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.brand : AppColors.brandHi,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 6, height: 6),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onHelp = false,
    this.onTalk = false,
    this.onComing = false,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool onHelp;
  final bool onTalk;
  final bool onComing;
  final bool compact;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  var _pressed = false;

  Future<void> _open() async {
    if (!await PaywallScreen.require(context)) return;
    if (!mounted) return;
    if (widget.onHelp) {
      PanicEntrySheet.help(context);
      return;
    }
    if (widget.onComing) {
      PanicEntrySheet.coming(context);
      return;
    }
    NativeChrome.push(
      context,
      AppMotion.fadeTo(const TalkScreen()),
      title: 'Know the pattern',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 0 : 6),
      child: Semantics(
        button: true,
        label: widget.title,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.selectionClick();
            AppAudio.tap();
            _open();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: BunlyCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: widget.compact ? _compact() : _wide(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wide() {
    return Row(
      children: [
        Icon(widget.icon, size: 18, color: AppColors.inkMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: AppTypography.ui(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                widget.subtitle,
                style: AppTypography.ui(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 22,
          color: AppColors.inkMuted.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _compact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(widget.icon, size: 18, color: AppColors.inkMuted),
        const SizedBox(height: 10),
        Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.ui(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }
}
