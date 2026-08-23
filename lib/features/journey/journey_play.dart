import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import 'journey_content.dart';

class JourneyPlayScreen extends StatefulWidget {
  const JourneyPlayScreen({super.key, required this.scareId});

  final String scareId;

  @override
  State<JourneyPlayScreen> createState() => _JourneyPlayScreenState();
}

class _JourneyPlayScreenState extends State<JourneyPlayScreen>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  var _pops = 0;
  var _breaths = 0;
  var _holding = false;
  var _breathLabel = 'Press and hold';
  var _starHome = true;
  var _running = true;

  late final AnimationController _orb;
  late final List<PlayBeat> _beats;

  PlayBeat get _beat => _beats[_index];

  @override
  void initState() {
    super.initState();
    _beats = JourneyContent.beatsFor(widget.scareId);
    _orb = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _running = false;
    _orb.dispose();
    super.dispose();
  }

  void _advance() {
    if (!_running || !mounted) return;
    AppAudio.answer();
    HapticFeedback.mediumImpact();
    if (_index >= _beats.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index += 1;
      _pops = 0;
      _breaths = 0;
      _holding = false;
      _breathLabel = 'Press and hold';
      _starHome = true;
      _orb.value = 0;
    });
  }

  void _finish() {
    _running = false;
    AppStore.instance.markJourneyPractice();
    AppAudio.win();
    Navigator.of(context).maybePop();
  }

  void _breathDown() {
    if (_beat.kind != PlayKind.hold) return;
    _orb.stop();
    _holding = true;
    AppAudio.tap();
    HapticFeedback.mediumImpact();
    setState(() => _breathLabel = 'Breathe in');
    _orb.duration = const Duration(seconds: 4);
    _orb.animateTo(1, curve: Curves.easeInOutSine);
  }

  void _breathUp() {
    if (_beat.kind != PlayKind.hold || !_holding) return;
    _holding = false;
    HapticFeedback.lightImpact();
    final amount = _orb.value;
    setState(() => _breathLabel = 'Let it go');
    _orb.stop();
    _orb.duration = Duration(
      milliseconds: (4200 * amount + 800).round().clamp(500, 6000),
    );
    _orb.animateTo(0, curve: Curves.easeInOutSine).whenComplete(() {
      if (!mounted || _beat.kind != PlayKind.hold) return;
      if (amount >= 0.28) {
        setState(() => _breaths += 1);
      }
      setState(() {
        _breathLabel = _breaths >= 2 ? 'Nice.' : 'Again, with me.';
      });
      if (_breaths >= 2) {
        Future<void>.delayed(const Duration(milliseconds: 380), () {
          if (!mounted || !_running || _beat.kind != PlayKind.hold) return;
          _advance();
        });
      }
    });
  }

  void _pop() {
    AppAudio.tap();
    HapticFeedback.selectionClick();
    if (_pops + 1 >= _beat.pops) {
      _advance();
      return;
    }
    setState(() => _pops += 1);
  }

  @override
  Widget build(BuildContext context) {
    final beat = _beat;
    final scare = JourneyContent.scareById(widget.scareId);

    return BunlyScaffold(
      title: scare.sip,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          children: [
            _PlayDots(step: _index, total: _beats.length),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: KeyedSubtree(
                  key: ValueKey(_index),
                  child: _BeatView(
                    beat: beat,
                    orb: _orb,
                    breathLabel: _breathLabel,
                    breaths: _breaths,
                    pops: _pops,
                    starHome: _starHome,
                    onAdvance: _advance,
                    onBreathDown: _breathDown,
                    onBreathUp: _breathUp,
                    onPop: _pop,
                    onDrop: () {
                      setState(() => _starHome = false);
                      Future<void>.delayed(
                        const Duration(milliseconds: 280),
                        _advance,
                      );
                    },
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

class _PlayDots extends StatelessWidget {
  const _PlayDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.brand : const Color(0xFFE8DFD4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BeatView extends StatelessWidget {
  const _BeatView({
    required this.beat,
    required this.orb,
    required this.breathLabel,
    required this.breaths,
    required this.pops,
    required this.starHome,
    required this.onAdvance,
    required this.onBreathDown,
    required this.onBreathUp,
    required this.onPop,
    required this.onDrop,
  });

  final PlayBeat beat;
  final AnimationController orb;
  final String breathLabel;
  final int breaths;
  final int pops;
  final bool starHome;
  final VoidCallback onAdvance;
  final VoidCallback onBreathDown;
  final VoidCallback onBreathUp;
  final VoidCallback onPop;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          beat.art,
          height: 96,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 12),
        Text(
          beat.title,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          beat.body,
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: AppColors.inkMuted,
          ),
        ),
        const Spacer(),
        switch (beat.kind) {
          PlayKind.tap => BunlyPrimaryButton(
            label: beat.action,
            onPressed: onAdvance,
          ),
          PlayKind.hold => _HoldOrb(
            orb: orb,
            label: breathLabel,
            breaths: breaths,
            onDown: onBreathDown,
            onUp: onBreathUp,
          ),
          PlayKind.pops => _Pops(
            total: beat.pops,
            done: pops,
            labels: beat.popLabels,
            onPop: onPop,
          ),
          PlayKind.drag => _StarDrop(home: starHome, onDrop: onDrop),
          PlayKind.choice => _Choices(
            choices: beat.choices,
            onPick: onAdvance,
          ),
        },
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HoldOrb extends StatelessWidget {
  const _HoldOrb({
    required this.orb,
    required this.label,
    required this.breaths,
    required this.onDown,
    required this.onUp,
  });

  final AnimationController orb;
  final String label;
  final int breaths;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Listener(
          onPointerDown: (_) => onDown(),
          onPointerUp: (_) => onUp(),
          onPointerCancel: (_) => onUp(),
          child: AnimatedBuilder(
            animation: orb,
            builder: (context, _) {
              final t = orb.value;
              return Transform.scale(
                scale: 0.86 + (t * 0.18),
                child: Container(
                  width: 132,
                  height: 132,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.brandHi, AppColors.brand],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(
                          alpha: 0.26 + t * 0.16,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$breaths / 2',
          style: AppTypography.ui(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
      ],
    );
  }
}

class _Pops extends StatelessWidget {
  const _Pops({
    required this.total,
    required this.done,
    required this.labels,
    required this.onPop,
  });

  final int total;
  final int done;
  final List<String> labels;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    if (labels.length == total) {
      return Column(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LabeledPop(
              label: labels[i],
              state: i < done
                  ? _PopState.done
                  : i == done
                  ? _PopState.now
                  : _PopState.wait,
              onTap: i == done ? onPop : null,
            ),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          GestureDetector(
            onTap: i == done ? onPop : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < done ? AppColors.brand : AppColors.optionFill,
                border: Border.all(
                  color: i == done ? AppColors.brand : AppColors.optionLine,
                  width: i == done ? 2 : 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: i < done
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: AppTypography.ui(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkMuted,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

enum _PopState { wait, now, done }

class _LabeledPop extends StatelessWidget {
  const _LabeledPop({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _PopState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: state == _PopState.wait ? 0.45 : 1,
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state == _PopState.done
                        ? AppColors.brand
                        : AppColors.optionFill,
                    border: Border.all(
                      color: state == _PopState.now
                          ? AppColors.brand
                          : AppColors.optionLine,
                    ),
                  ),
                  child: state == _PopState.done
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.ui(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
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

class _StarDrop extends StatelessWidget {
  const _StarDrop({required this.home, required this.onDrop});

  final bool home;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: home
                  ? Draggable<String>(
                      data: 'star',
                      onDragStarted: () => AppAudio.tap(),
                      feedback: Image.asset(
                        BunlyPoses.huggingStar,
                        height: 72,
                        filterQuality: FilterQuality.high,
                      ),
                      childWhenDragging: const SizedBox(width: 72, height: 72),
                      child: Image.asset(
                        BunlyPoses.huggingStar,
                        height: 72,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : const SizedBox(width: 72, height: 72),
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) => details.data == 'star',
              onAcceptWithDetails: (_) {
                AppAudio.answer();
                HapticFeedback.mediumImpact();
                onDrop();
              },
              builder: (context, candidate, _) {
                final hot = candidate.isNotEmpty || !home;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hot
                        ? AppColors.optionSelected
                        : AppColors.optionFill,
                    border: Border.all(
                      color: hot ? AppColors.brand : AppColors.optionLine,
                      width: 2,
                    ),
                  ),
                  child: !home
                      ? Image.asset(
                          BunlyPoses.huggingStar,
                          height: 64,
                          filterQuality: FilterQuality.high,
                        )
                      : Icon(
                          Icons.north_west_rounded,
                          color: AppColors.brand.withValues(alpha: 0.5),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.choices, required this.onPick});

  final List<String> choices;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ChoiceTile(label: choices[i], onTap: onPick),
        ],
      ],
    );
  }
}

class _ChoiceTile extends StatefulWidget {
  const _ChoiceTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ChoiceTile> createState() => _ChoiceTileState();
}

class _ChoiceTileState extends State<_ChoiceTile> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        AppAudio.tap();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 80),
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
