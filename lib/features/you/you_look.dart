import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';

const Color kYouFloor = Color(0xFFF4EEF8);
const Color kYouNight = Color(0xFF24183F);
const Color kYouGlow = Color(0xFFB9A4F0);

class YouFace {
  const YouFace({
    required this.name,
    required this.art,
    required this.fallback,
    required this.line,
    this.thanksHint = false,
  });

  final String name;
  final String art;
  final String fallback;
  final String line;
  final bool thanksHint;

  static const all = [
    YouFace(
      name: 'Curiosity',
      art: BunlyCards.curiosity,
      fallback: BunlyActivities.thinking,
      line: 'Asking is allowed. Even the tiny questions.',
    ),
    YouFace(
      name: 'Anxious',
      art: BunlyCards.anxious,
      fallback: BunlyActivities.worried,
      line: 'Feeling a lot still counts as trying.',
    ),
    YouFace(
      name: 'Problem Solver',
      art: BunlyCards.problemSolver,
      fallback: BunlyActivities.working,
      line: 'We can think it through. Slowly is fine.',
    ),
    YouFace(
      name: 'Investigator',
      art: BunlyCards.investigator,
      fallback: BunlyActivities.detective,
      line: 'Little things are clues. Not proof you’re broken.',
    ),
    YouFace(
      name: 'Nurturer',
      art: BunlyCards.nurturer,
      fallback: BunlyActivities.gardening,
      line: 'Little by little. Including you.',
      thanksHint: true,
    ),
    YouFace(
      name: 'Kind Heart',
      art: BunlyCards.kindHeart,
      fallback: BunlyActivities.gifting,
      line: 'Kindness can be tiny and still true.',
      thanksHint: true,
    ),
  ];
}

class YouGlow extends StatelessWidget {
  const YouGlow({super.key, required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 220.0 : 340.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kYouGlow.withValues(alpha: 0.55),
                  kYouGlow.withValues(alpha: 0.18),
                  kYouFloor.withValues(alpha: 0),
                ],
              ),
            ),
            child: SizedBox(width: size, height: size),
          ),
        ),
        child,
      ],
    );
  }
}

class YouCardArt extends StatelessWidget {
  const YouCardArt({
    super.key,
    required this.face,
    this.height,
    this.locked = false,
  });

  final YouFace face;
  final double? height;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    Widget art = Image.asset(
      face.art,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) {
        return _DrawnCard(face: face, height: height ?? 300);
      },
    );
    if (locked) {
      art = ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: art,
            ),
            const IgnorePointer(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xCCFFFFFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      CupertinoIcons.lock_fill,
                      size: 22,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (height == null) return art;
    return SizedBox(height: height, width: double.infinity, child: art);
  }
}

class _DrawnCard extends StatelessWidget {
  const _DrawnCard({required this.face, required this.height});

  final YouFace face;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.95,
                colors: [
                  Color(0xFFD9C8FF),
                  Color(0xFF8B6FE0),
                  Color(0xFF5A3FB8),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.12),
            child: Image.asset(
              face.fallback,
              height: height * 0.62,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Align(
            alignment: const Alignment(-0.72, -0.86),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Text(
                  face.name,
                  style: AppTypography.ui(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.78, 0.42),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'BUNLY',
                  style: AppTypography.ui(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class YouNoteCard extends StatelessWidget {
  const YouNoteCard({
    super.key,
    required this.text,
    required this.when,
    required this.onOpen,
  });

  final String text;
  final String when;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Thanks. $text',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          AppAudio.tap();
          onOpen();
        },
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  when,
                  style: AppTypography.ui(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppTypography.ui(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YouKitTile extends StatelessWidget {
  const YouKitTile({
    super.key,
    required this.title,
    required this.body,
    required this.art,
    required this.onOpen,
    this.trailing = CupertinoIcons.pencil,
  });

  final String title;
  final String body;
  final String art;
  final VoidCallback onOpen;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          AppAudio.tap();
          onOpen();
        },
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Image.asset(
                  art,
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.ui(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.ui(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  trailing,
                  size: 16,
                  color: AppColors.brand.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YouQuietBar extends StatelessWidget {
  const YouQuietBar({super.key, required this.quiet, required this.onChanged});

  final bool quiet;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: quiet,
      label: quiet ? 'Quiet on' : 'Sounds on',
      child: BunlyCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Image.asset(
                quiet ? BunlyToday.sleeping : BunlyPoses.winking,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiet ? 'Quiet' : 'Sounds on',
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      quiet
                          ? 'Bondly stays quiet in here.'
                          : 'Taps and the little music.',
                      style: AppTypography.ui(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: quiet,
                activeTrackColor: AppColors.brand,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YouWriteSheet extends StatefulWidget {
  const YouWriteSheet({
    super.key,
    required this.title,
    required this.hint,
    required this.lines,
    this.value = '',
    this.saveLabel = 'Keep it',
  });

  final String title;
  final String hint;
  final String value;
  final int lines;
  final String saveLabel;

  static Future<String?> open(
    BuildContext context, {
    required String title,
    required String hint,
    required int lines,
    String value = '',
    String saveLabel = 'Keep it',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.home,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: YouWriteSheet(
            title: title,
            hint: hint,
            lines: lines,
            value: value,
            saveLabel: saveLabel,
          ),
        );
      },
    );
  }

  @override
  State<YouWriteSheet> createState() => _YouWriteSheetState();
}

class _YouWriteSheetState extends State<YouWriteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.pencil, size: 20, color: AppColors.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.ui(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: widget.lines,
              style: AppTypography.ui(fontSize: 16, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.ui(
                  fontSize: 16,
                  color: AppColors.inkMuted,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                AppAudio.tap();
                Navigator.of(context).pop(_controller.text);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    widget.saveLabel,
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
