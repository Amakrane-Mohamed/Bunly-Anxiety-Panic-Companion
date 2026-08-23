import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import 'guide_beats.dart';
import 'help_backdrop.dart';
import 'recovery_screen.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({
    super.key,
    required this.beats,
    this.episode,
    this.recover = false,
  });

  final List<GuideBeat> beats;
  final PanicEpisode? episode;
  final bool recover;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  var _pops = 0;
  var _breaths = 0;
  var _holding = false;
  var _breathLabel = 'Press and hold';
  var _starHome = true;
  var _running = true;
  Timer? _listen;

  late final AnimationController _orb;

  GuideBeat get _beat => widget.beats[_index];

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppAudio.startMusic();
      _armListen();
    });
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
    if (_beat.kind != BeatKind.listen) return;
    _listen = Timer(const Duration(seconds: 9), () {
      if (mounted && _running && _beat.kind == BeatKind.listen) _advance();
    });
  }

  void _advance() {
    if (!_running || !mounted) return;
    AppAudio.answer();
    HapticFeedback.mediumImpact();
    if (_index >= widget.beats.length - 1) {
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
    final episode = widget.episode;
    if (episode != null) {
      final kind = _beat.kind;
      if (kind == BeatKind.hold) {
        AppStore.instance.useTool(episode, 'breathing');
      }
      if (kind == BeatKind.pops || kind == BeatKind.drag) {
        AppStore.instance.useTool(episode, 'grounding');
      }
    }
    _armListen();
  }

  void _finish() {
    _running = false;
    _listen?.cancel();
    final episode = widget.episode;
    if (widget.recover && episode != null) {
      AppAudio.stopMusic();
      Navigator.of(context).pushReplacement(
        AppMotion.fadeTo(RecoveryScreen(episode: episode)),
      );
      return;
    }
    AppAudio.win();
    Navigator.of(context).maybePop();
  }

  void _leave() {
    _running = false;
    _listen?.cancel();
    AppAudio.stopMusic();
    if (widget.recover && widget.episode != null) {
      Navigator.of(context).pushReplacement(
        AppMotion.fadeTo(RecoveryScreen(episode: widget.episode!)),
      );
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _breathDown() {
    if (_beat.kind != BeatKind.hold) return;
    _orb.stop();
    _holding = true;
    AppAudio.tap();
    HapticFeedback.mediumImpact();
    setState(() => _breathLabel = 'Breathe in');
    _orb.duration = const Duration(seconds: 4);
    _orb.animateTo(1, curve: Curves.easeInOutSine);
  }

  void _breathUp() {
    if (_beat.kind != BeatKind.hold || !_holding) return;
    _holding = false;
    HapticFeedback.lightImpact();
    final amount = _orb.value;
    setState(() => _breathLabel = 'Let it go');
    _orb.stop();
    _orb.duration = Duration(
      milliseconds: (4200 * amount + 800).round().clamp(500, 6000),
    );
    _orb.animateTo(0, curve: Curves.easeInOutSine).whenComplete(() {
      if (!mounted || _beat.kind != BeatKind.hold) return;
      if (amount >= 0.28) {
        setState(() => _breaths += 1);
      }
      setState(() {
        _breathLabel = _breaths >= 2 ? 'Nice.' : 'Again, with me.';
      });
      if (_breaths >= 2) {
        Future<void>.delayed(const Duration(milliseconds: 380), () {
          if (!mounted || !_running || _beat.kind != BeatKind.hold) return;
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
    final bottom = MediaQuery.paddingOf(context).bottom;
    final beat = _beat;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF5A3FBE),
        body: HelpBackdrop(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: QuietToggle(),
                ),
              ),
              const Spacer(),
              HelpSheet(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 16, 22, 10 + bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HelpProgress(
                        step: _index,
                        total: widget.beats.length,
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Image.asset(
                          beat.art,
                          key: ValueKey(beat.art),
                          height: 92,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: KeyedSubtree(
                          key: ValueKey(_index),
                          child: _body(beat),
                        ),
                      ),
                      BunlyTextButton(
                        label: 'I’m okay now',
                        onPressed: _leave,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(GuideBeat beat) {
    return Column(
      children: [
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
        const SizedBox(height: 16),
        switch (beat.kind) {
          BeatKind.tap => BunlyPrimaryButton(
            label: beat.action,
            onPressed: _advance,
          ),
          BeatKind.listen => BunlyPrimaryButton(
            label: beat.action,
            onPressed: _advance,
          ),
          BeatKind.hold => _HoldOrb(
            orb: _orb,
            label: _breathLabel,
            breaths: _breaths,
            onDown: _breathDown,
            onUp: _breathUp,
          ),
          BeatKind.pops => _Pops(
            total: beat.pops,
            done: _pops,
            onPop: _pop,
          ),
          BeatKind.drag => _StarDrop(
            home: _starHome,
            onDrop: () {
              setState(() => _starHome = false);
              Future<void>.delayed(const Duration(milliseconds: 280), _advance);
            },
          ),
        },
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
                        color: AppColors.brand.withValues(alpha: 0.26 + t * 0.16),
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
    required this.onPop,
  });

  final int total;
  final int done;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
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
              child: i < done
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _StarDrop extends StatelessWidget {
  const _StarDrop({
    required this.home,
    required this.onDrop,
  });

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
