import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/profile/user_plan.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import 'convert_chrome.dart';
import 'stay_close_screen.dart';

enum _BreathPhase { inhale, hold, exhale }

class FirstBreathScreen extends StatefulWidget {
  const FirstBreathScreen({super.key});

  @override
  State<FirstBreathScreen> createState() => _FirstBreathScreenState();
}

class _FirstBreathScreenState extends State<FirstBreathScreen>
    with SingleTickerProviderStateMixin {
  static const _cycles = 3;

  late final AnimationController _orb;
  var _phase = _BreathPhase.inhale;
  var _secondsLeft = 4;
  var _cycle = 0;
  var _finished = false;
  var _canSkip = false;
  var _running = true;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runSession();
    });
  }

  @override
  void dispose() {
    _running = false;
    _tick?.cancel();
    _orb.dispose();
    super.dispose();
  }

  Future<void> _runSession() async {
    for (var i = 0; i < _cycles; i++) {
      if (!mounted || !_running) return;
      setState(() {
        _cycle = i;
        if (i == 1) _canSkip = true;
      });
      await _playPhase(_BreathPhase.inhale, const Duration(seconds: 4), 1);
      if (!mounted || !_running) return;
      await _playPhase(_BreathPhase.hold, const Duration(seconds: 2), 1);
      if (!mounted || !_running) return;
      await _playPhase(_BreathPhase.exhale, const Duration(seconds: 6), 0);
    }
    if (!mounted || !_running) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _finished = true;
      _canSkip = false;
    });
    try {
      _orb.duration = const Duration(milliseconds: 700);
      await _orb.animateTo(1, curve: AppMotion.curve);
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _playPhase(
    _BreathPhase phase,
    Duration duration,
    double to,
  ) async {
    HapticFeedback.selectionClick();
    setState(() {
      _phase = phase;
      _secondsLeft = duration.inSeconds;
    });
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final left = duration.inSeconds - timer.tick;
      setState(() => _secondsLeft = left < 1 ? 1 : left);
    });

    if (phase == _BreathPhase.hold) {
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

  void _goNext() {
    _running = false;
    _tick?.cancel();
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.fadeTo(const StayCloseScreen()));
  }

  String get _phaseLabel {
    return switch (_phase) {
      _BreathPhase.inhale => 'Breathe in',
      _BreathPhase.hold => 'Hold',
      _BreathPhase.exhale => 'Breathe out',
    };
  }

  @override
  Widget build(BuildContext context) {
    final plan = UserPlan.instance;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      child: ConvertWash(
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Column(
                    children: [
                      FadeUp(
                        child: Column(
                          children: [
                            ConvertEyebrow(
                              _finished ? 'You did it' : 'A calm moment',
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _finished
                                  ? 'That’s a real first step, ${plan.firstName}.'
                                  : plan.breathCue,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.18,
                                letterSpacing: -0.7,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      FadeUp(
                        delay: const Duration(milliseconds: 180),
                        child: AnimatedSwitcher(
                          duration: AppMotion.page,
                          child: Image.asset(
                            _finished ? BunlyPoses.proud : BunlyPoses.sitting,
                            key: ValueKey(_finished),
                            height: 132,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeUp(
                        delay: const Duration(milliseconds: 280),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _orb,
                              builder: (context, _) {
                                return _BreathOrb(
                                  progress: _orb.value,
                                  seconds: _finished ? null : _secondsLeft,
                                  label: _finished ? 'Nice.' : _phaseLabel,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _finished
                                  ? 'You stayed with it.'
                                  : '${_cycle + 1} of $_cycles',
                              style: AppTypography.ui(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8 + bottomInset),
              child: Column(
                children: [
                  if (_finished)
                    FadeUp(
                      child: BunlyPrimaryButton(
                        label: 'Continue',
                        onPressed: _goNext,
                      ),
                    )
                  else if (_canSkip)
                    FadeUp(
                      child: BunlyTextButton(
                        label: 'Skip for now',
                        onPressed: _goNext,
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathOrb extends StatelessWidget {
  const _BreathOrb({required this.progress, required this.label, this.seconds});

  final double progress;
  final String label;
  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final scale = 0.78 + (progress * 0.22);
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandHi.withValues(alpha: 0.28 + progress * 0.18),
                    AppColors.brand.withValues(alpha: 0.10),
                    const Color(0x00FFFFFF),
                  ],
                  stops: const [0.35, 0.7, 1],
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: scale,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandHi,
                    AppColors.brand,
                    AppColors.brandLo,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.28),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (seconds != null)
                    Text(
                      '$seconds',
                      style: AppTypography.display(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: AppColors.onBrand,
                      ),
                    ),
                  Text(
                    label,
                    style: AppTypography.ui(
                      fontSize: seconds == null ? 20 : 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBrand.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
