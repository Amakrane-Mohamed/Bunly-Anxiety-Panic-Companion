import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'journey_catalog.dart';
import 'journey_look.dart';

class JourneySessionScreen extends StatefulWidget {
  const JourneySessionScreen({super.key, required this.session});

  final JourneySession session;

  @override
  State<JourneySessionScreen> createState() => _JourneySessionScreenState();
}

class _JourneySessionScreenState extends State<JourneySessionScreen>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  var _pops = 0;
  var _breaths = 0;
  var _holding = false;
  var _breathLabel = 'Press and hold';
  var _starHome = true;
  var _running = true;
  var _scale = 0;
  var _listenReady = false;
  String? _picked;
  Timer? _listen;

  late final AnimationController _orb;

  JourneyBeat get _beat => widget.session.beats[_index];

  String get _art {
    final art = _beat.art;
    return art.isNotEmpty ? art : BunlyPoses.sitting;
  }

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    _armListen();
  }

  @override
  void dispose() {
    _running = false;
    _listen?.cancel();
    _orb.dispose();
    super.dispose();
  }

  void _armListen() {
    _listen?.cancel();
    _listenReady = false;
    if (_beat.kind != 'listen') return;
    _listen = Timer(const Duration(seconds: 8), () {
      if (!mounted || !_running || _beat.kind != 'listen') return;
      setState(() => _listenReady = true);
    });
  }

  void _saveChoice(JourneyChoice choice) {
    final store = AppStore.instance;
    switch (_beat.save) {
      case 'scare':
        store.setJourneyScare(choice.id);
      case 'life':
        store.journeyLifeId = choice.id;
      case 'ask':
        store.journeyAskAnswer = choice.label;
    }
  }

  void _advance() {
    if (!_running || !mounted) return;
    AppAudio.answer();
    HapticFeedback.mediumImpact();
    if (_index >= widget.session.beats.length - 1) {
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
      _scale = 0;
      _listenReady = false;
      _picked = null;
      _orb.value = 0;
    });
    _armListen();
  }

  String get _headerLine {
    return switch (_beat.kind) {
      'choice' => 'Pick one. I’ll wait.',
      'pops' => 'Tap what you notice.',
      'hold' => 'Hold with me. Then let go.',
      'scale' => 'How loud is it, then Next.',
      'drag' => 'Drag the star home.',
      'listen' => 'Stay a second. I’m here.',
      _ => 'Read this. Then Next.',
    };
  }

  void _finish() {
    _running = false;
    _listen?.cancel();
    AppStore.instance.markJourneyClaim(widget.session.id);
    Navigator.of(context).pop(true);
  }

  void _pick(JourneyChoice choice) {
    if (_picked != null || !_running) return;
    _saveChoice(choice);
    setState(() => _picked = choice.id);
    Future<void>.delayed(const Duration(milliseconds: 780), () {
      if (!mounted || !_running) return;
      _advance();
    });
  }

  void _breathDown() {
    if (_beat.kind != 'hold') return;
    _orb.stop();
    _holding = true;
    AppAudio.tap();
    HapticFeedback.mediumImpact();
    setState(() => _breathLabel = 'Breathe in');
    _orb.duration = const Duration(seconds: 4);
    _orb.animateTo(1, curve: Curves.easeInOutSine);
  }

  void _breathUp() {
    if (_beat.kind != 'hold' || !_holding) return;
    _holding = false;
    HapticFeedback.lightImpact();
    final amount = _orb.value;
    setState(() => _breathLabel = 'Let it go');
    _orb.stop();
    _orb.duration = Duration(
      milliseconds: (4200 * amount + 800).round().clamp(500, 6000),
    );
    _orb.animateTo(0, curve: Curves.easeInOutSine).whenComplete(() {
      if (!mounted || _beat.kind != 'hold') return;
      if (amount >= 0.28) setState(() => _breaths += 1);
      setState(() {
        _breathLabel = _breaths >= 2 ? 'Nice.' : 'Again, with me.';
      });
      if (_breaths >= 2) {
        Future<void>.delayed(const Duration(milliseconds: 420), () {
          if (!mounted || !_running || _beat.kind != 'hold') return;
          _advance();
        });
      }
    });
  }

  void _pop() {
    if (_pops + 1 >= _beat.pops) {
      setState(() => _pops += 1);
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (!mounted || !_running) return;
        _advance();
      });
      return;
    }
    setState(() => _pops += 1);
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    final total = widget.session.beats.length;

    return ColoredBox(
      color: AppColors.home,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const JourneyBackdrop(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, safe.top + 8, 16, 10 + safe.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JourneyBackButton(),
                const SizedBox(height: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0.06),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: ListView(
                      key: ValueKey(_index),
                      padding: EdgeInsets.zero,
                      children: [
                        _SessionHeader(
                          title: widget.session.title,
                          step: '${_index + 1} of $total',
                          line: _headerLine,
                        ),
                        const SizedBox(height: 16),
                        JourneySectionLabel(_sectionFor(_beat.kind)),
                        const SizedBox(height: 8),
                        ..._beatCards(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _beatCards() {
    final beat = _beat;
    final art = _art;

    return switch (beat.kind) {
      'choice' => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        for (final choice in beat.choices)
          JourneyPickRow(
            title: choice.label,
            subtitle: 'Tap this one.',
            art: art,
            selected: _picked == choice.id,
            dimmed: _picked != null && _picked != choice.id,
            chipLabel: 'This one',
            onPick: () => _pick(choice),
          ),
      ],
      'pops' when beat.popLabels.length == beat.pops => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        for (var i = 0; i < beat.pops; i++)
          JourneyPickRow(
            title: beat.popLabels[i],
            subtitle: i == _pops
                ? 'Tap when you notice it.'
                : 'Not yet. One at a time.',
            art: art,
            selected: i < _pops,
            dimmed: i > _pops,
            enabled: i == _pops,
            chipLabel: 'This',
            onPick: _pop,
          ),
      ],
      'hold' => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        _HoldCard(
          orb: _orb,
          label: _breathLabel,
          breaths: _breaths,
          onDown: _breathDown,
          onUp: _breathUp,
        ),
      ],
      'scale' => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        _ScaleCard(
          low: beat.low,
          high: beat.high,
          scale: _scale,
          onScale: (value) {
            HapticFeedback.selectionClick();
            AppAudio.tap();
            setState(() => _scale = value);
            if (beat.save == 'fear') {
              AppStore.instance.setJourneyFear(value);
            }
          },
        ),
        const SizedBox(height: 8),
        JourneyPickRow(
          title: beat.action,
          subtitle: _scale == 0
              ? 'Pick a number first. I’m not a mind reader.'
              : 'That’s the loudness for now.',
          art: art,
          enabled: _scale != 0,
          chipLabel: 'Next',
          onPick: _advance,
        ),
      ],
      'drag' => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        _StarDrop(home: _starHome, onDrop: () {
          setState(() => _starHome = false);
          Future<void>.delayed(const Duration(milliseconds: 280), _advance);
        }),
      ],
      'listen' => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        JourneyPickRow(
          title: beat.action,
          subtitle: _listenReady
              ? 'That’s long enough.'
              : 'Stay a moment. I’m counting in my head.',
          art: art,
          enabled: _listenReady,
          chipLabel: 'Next',
          onPick: _advance,
        ),
      ],
      _ => [
        _PromptCard(art: art, title: beat.title, body: beat.body),
        const SizedBox(height: 8),
        JourneyPickRow(
          title: beat.action,
          subtitle: 'When you’re ready.',
          art: art,
          chipLabel: 'Next',
          onPick: _advance,
        ),
      ],
    };
  }
}

String _sectionFor(String kind) {
  return switch (kind) {
    'choice' => 'Pick one',
    'pops' => 'Check these off',
    'hold' => 'Breathe',
    'scale' => 'How loud',
    'drag' => 'One small move',
    'listen' => 'Stay a second',
    _ => 'This step',
  };
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.title,
    required this.step,
    required this.line,
  });

  final String title;
  final String step;
  final String line;

  @override
  Widget build(BuildContext context) {
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
                    title,
                    style: AppTypography.ui(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step,
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.art,
    required this.title,
    required this.body,
  });

  final String art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: JourneyBrandCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                art,
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
                      title,
                      style: AppTypography.ui(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
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
      ),
    );
  }
}

class _HoldCard extends StatelessWidget {
  const _HoldCard({
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
    return JourneyBrandCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Column(
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
                    scale: 0.9 + (t * 0.12),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTypography.ui(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                JourneyStampCheck(claimed: breaths >= 1, celebrate: breaths >= 1),
                const SizedBox(width: 12),
                JourneyStampCheck(claimed: breaths >= 2, celebrate: breaths >= 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleCard extends StatelessWidget {
  const _ScaleCard({
    required this.low,
    required this.high,
    required this.scale,
    required this.onScale,
  });

  final String low;
  final String high;
  final int scale;
  final ValueChanged<int> onScale;

  @override
  Widget build(BuildContext context) {
    return JourneyBrandCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 1; i <= 5; i++) ...[
                  if (i > 1) const SizedBox(width: 8),
                  Expanded(
                    child: _ScalePip(
                      n: i,
                      selected: scale == i,
                      filled: scale != 0 && i <= scale,
                      onTap: () => onScale(i),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    low,
                    style: AppTypography.ui(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  high,
                  style: AppTypography.ui(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
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

class _ScalePip extends StatefulWidget {
  const _ScalePip({
    required this.n,
    required this.selected,
    required this.filled,
    required this.onTap,
  });

  final int n;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_ScalePip> createState() => _ScalePipState();
}

class _ScalePipState extends State<_ScalePip> {
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
        scale: _pressed || widget.selected ? 0.92 : 1,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.filled ? AppColors.brand : const Color(0xFFFDF2E6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected ? AppColors.brand : const Color(0xFFDCC9A8),
              width: widget.selected ? 1.6 : 1.2,
            ),
          ),
          child: Text(
            '${widget.n}',
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: widget.filled ? Colors.white : AppColors.ink,
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
    return JourneyBrandCard(
      claimed: !home,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: SizedBox(
          height: 120,
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
                          childWhenDragging: const SizedBox(
                            width: 72,
                            height: 72,
                          ),
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
                            ? const Color(0xFFE7DFF8)
                            : const Color(0xFFFDF2E6),
                        border: Border.all(
                          color: hot ? AppColors.brand : const Color(0xFFDCC9A8),
                          width: hot ? 1.6 : 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: !home
                          ? Image.asset(
                              BunlyPoses.huggingStar,
                              height: 64,
                              filterQuality: FilterQuality.high,
                            )
                          : JourneyStampCheck(claimed: false, celebrate: false),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
