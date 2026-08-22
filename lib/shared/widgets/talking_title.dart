import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'fade_up.dart';

class TalkingTitle extends StatefulWidget {
  const TalkingTitle({
    super.key,
    required this.text,
    this.highlight,
    this.fontSize = 32,
    this.delay = Duration.zero,
    this.wordDelay = const Duration(milliseconds: 90),
    this.wordDuration = const Duration(milliseconds: 560),
    this.color,
    this.emphasisColor,
    this.alignment = WrapAlignment.start,
    this.shadows,
    this.onComplete,
  });

  final String text;
  final String? highlight;
  final double fontSize;
  final Duration delay;
  final Duration wordDelay;
  final Duration wordDuration;
  final Color? color;
  final Color? emphasisColor;
  final WrapAlignment alignment;
  final List<Shadow>? shadows;
  final VoidCallback? onComplete;

  @override
  State<TalkingTitle> createState() => _TalkingTitleState();
}

class _TalkingTitleState extends State<TalkingTitle> {
  Timer? _done;

  @override
  void initState() {
    super.initState();
    final words = _words;
    if (words.isEmpty) {
      widget.onComplete?.call();
      return;
    }
    final wait =
        widget.delay +
        widget.wordDelay * (words.length - 1) +
        widget.wordDuration +
        const Duration(milliseconds: 180);
    _done = Timer(wait, () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _done?.cancel();
    super.dispose();
  }

  List<String> get _words =>
      widget.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final words = _words;
    final marks = widget.highlight
        ?.toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();
    final base = widget.color ?? AppColors.inkMuted;
    final emph = widget.emphasisColor ?? AppColors.ink;

    return Semantics(
      header: true,
      liveRegion: true,
      label: widget.text,
      child: Wrap(
        alignment: widget.alignment,
        runAlignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          for (var i = 0; i < words.length; i++)
            FadeUp(
              delay: widget.delay + (widget.wordDelay * i),
              duration: widget.wordDuration,
              offset: 10,
              child: Text(
                words[i],
                style: AppTypography.display(
                  fontSize: widget.fontSize,
                  fontWeight: _emphasized(words[i], marks)
                      ? FontWeight.w800
                      : FontWeight.w700,
                  height: 1.16,
                  letterSpacing: -0.8,
                  color: _emphasized(words[i], marks) ? emph : base,
                ).copyWith(shadows: widget.shadows),
              ),
            ),
        ],
      ),
    );
  }

  bool _emphasized(String word, Set<String>? marks) {
    if (marks == null || marks.isEmpty) return false;
    final cleaned = word.toLowerCase().replaceAll(RegExp(r"[^a-z0-9']"), '');
    return marks.contains(cleaned);
  }
}
