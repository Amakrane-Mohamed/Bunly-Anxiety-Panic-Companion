import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import 'journey_content.dart';

class JourneyAskScreen extends StatefulWidget {
  const JourneyAskScreen({super.key});

  @override
  State<JourneyAskScreen> createState() => _JourneyAskScreenState();
}

class _JourneyAskScreenState extends State<JourneyAskScreen> {
  late final List<AskItem> _asks;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _asks = JourneyContent.asksForToday();
  }

  void _pick(String answer) {
    HapticFeedback.selectionClick();
    AppAudio.answer();
    if (_index >= _asks.length - 1) {
      AppStore.instance.markJourneyAsk(answer);
      AppAudio.win();
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final ask = _asks[_index];

    return BunlyScaffold(
      title: 'Bondly asks',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < _asks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _index
                            ? AppColors.brand
                            : const Color(0xFFE8DFD4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Image.asset(
              BunlyPoses.sitting,
              height: 96,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                ask.prompt,
                key: ValueKey(_index),
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap what fits. No essay.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
            const Spacer(),
            for (var i = 0; i < ask.choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _AskChoice(
                label: ask.choices[i],
                onTap: () => _pick(ask.choices[i]),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AskChoice extends StatefulWidget {
  const _AskChoice({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_AskChoice> createState() => _AskChoiceState();
}

class _AskChoiceState extends State<_AskChoice> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 80),
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
