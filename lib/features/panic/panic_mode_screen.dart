import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/profile/user_plan.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import 'recovery_screen.dart';

enum _Phase { open, breathe, ground }

class PanicModeScreen extends StatefulWidget {
  const PanicModeScreen({super.key, required this.episode});

  final PanicEpisode episode;

  @override
  State<PanicModeScreen> createState() => _PanicModeScreenState();
}

class _PanicModeScreenState extends State<PanicModeScreen>
    with TickerProviderStateMixin {
  static const _ground = [
    'Look around. Name one thing you can see.',
    'Notice one thing you can feel against your skin.',
    'Listen. Name one sound, even a small one.',
  ];

  var _phase = _Phase.open;
  var _openStep = 0;
  var _groundStep = 0;
  var _secondsLeft = 4;
  var _breathLabel = 'Breathe in';
  late final AnimationController _orb;
  var _running = true;
  Timer? _tick;

  static const _openLines = [
    'I’m here.',
    'You don’t need to fix anything right now.',
    'Stay with me.',
  ];

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    NativeChrome.hideForPanic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runOpen();
    });
  }

  @override
  void dispose() {
    _running = false;
    _tick?.cancel();
    _orb.dispose();
    NativeChrome.showRoot();
    super.dispose();
  }

  Future<void> _runOpen() async {
    for (var i = 0; i < _openLines.length; i++) {
      if (!mounted || !_running) return;
      setState(() => _openStep = i);
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 1600));
    }
    if (!mounted || !_running) return;
    setState(() => _phase = _Phase.breathe);
    await _runBreath();
  }

  Future<void> _runBreath() async {
    for (var i = 0; i < 2; i++) {
      if (!mounted || !_running) return;
      await _phaseBreath('Breathe in', const Duration(seconds: 4), 1);
      if (!mounted || !_running) return;
      await _phaseBreath('Hold', const Duration(seconds: 2), 1);
      if (!mounted || !_running) return;
      await _phaseBreath('Breathe out', const Duration(seconds: 6), 0);
    }
    if (!mounted || !_running) return;
    setState(() => _phase = _Phase.ground);
  }

  Future<void> _phaseBreath(String label, Duration duration, double to) async {
    HapticFeedback.selectionClick();
    setState(() {
      _breathLabel = label;
      _secondsLeft = duration.inSeconds;
    });
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final left = duration.inSeconds - timer.tick;
      setState(() => _secondsLeft = left < 1 ? 1 : left);
    });
    if (label == 'Hold') {
      await Future<void>.delayed(duration);
    } else {
      try {
        _orb.duration = duration;
        await _orb.animateTo(to, curve: AppMotion.curve);
      } on TickerCanceled {
        return;
      }
    }
    _tick?.cancel();
  }

  void _nextGround() {
    HapticFeedback.lightImpact();
    if (_groundStep >= _ground.length - 1) {
      Navigator.of(context).pushReplacement(
        AppMotion.fadeTo(RecoveryScreen(episode: widget.episode)),
      );
      return;
    }
    setState(() => _groundStep += 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cue = UserPlan.instance.breathCue;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBF8FF), AppColors.canvas],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, 24, 28, 12 + bottom),
              child: Column(
                children: [
                  Text(
                    switch (_phase) {
                      _Phase.open => _openLines[_openStep],
                      _Phase.breathe => cue,
                      _Phase.ground => _ground[_groundStep],
                    },
                    textAlign: TextAlign.center,
                    style: AppTypography.display(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.6,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    switch (_phase) {
                      _Phase.open => switch (_openStep) {
                        0 => BunlyPanic.readyToHelp,
                        1 => BunlyPanic.staying,
                        _ => BunlyPanic.countingDown,
                      },
                      _Phase.breathe => BunlyPanic.breathing,
                      _Phase.ground => switch (_groundStep) {
                        0 => BunlyPanic.grounding,
                        1 => BunlyPanic.easing,
                        _ => BunlyPanic.passed,
                      },
                    },
                    height: 150,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 20),
                  if (_phase == _Phase.breathe)
                    AnimatedBuilder(
                      animation: _orb,
                      builder: (context, _) {
                        final scale = 0.78 + (_orb.value * 0.22);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 148,
                            height: 148,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.brandHi,
                                  AppColors.brand,
                                  AppColors.brandLo,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_secondsLeft',
                                  style: AppTypography.display(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _breathLabel,
                                  style: AppTypography.ui(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const Spacer(),
                  if (_phase == _Phase.ground)
                    BunlyPrimaryButton(
                      label: 'I notice it',
                      onPressed: _nextGround,
                    )
                  else
                    const SizedBox(height: 62),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
