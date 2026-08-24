import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/motion/app_motion.dart';
import '../../core/profile/user_plan.dart';
import '../../core/store/local_disk.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../auth/sign_in_screen.dart';
import '../home/profile_setup.dart';
import 'onboarding_content.dart';
import 'widgets/bunly_moments.dart';
import 'widgets/onboarding_chrome.dart';
import 'widgets/onboarding_option_tile.dart';
import 'widgets/onboarding_slider.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static final _steps = OnboardingContent.steps;

  var _index = 0;
  final _multi = <int, Set<int>>{};
  final _sliders = <int, double>{};

  @override
  void initState() {
    super.initState();
    AppAudio.startMusic();
  }

  OnboardingStep get _step => _steps[_index];

  bool get _canContinue {
    switch (_step.kind) {
      case OnboardingKind.multi:
        return _multi[_index]?.isNotEmpty ?? false;
      case OnboardingKind.slider:
      case OnboardingKind.peek:
      case OnboardingKind.cheer:
      case OnboardingKind.journey:
        return true;
      case OnboardingKind.generating:
        return false;
    }
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index -= 1);
  }

  void _next() {
    if (!_canContinue) return;
    if (_index >= _steps.length - 1) return;
    setState(() => _index += 1);
  }

  void _toggle(int option) {
    final set = _multi.putIfAbsent(_index, () => <int>{});
    setState(() {
      if (set.contains(option)) {
        set.remove(option);
      } else {
        set.add(option);
      }
    });
  }

  void _savePlan() {
    List<String> picked(int index) {
      final options = _steps[index].options;
      final selected = _multi[index] ?? {};
      return selected
          .where((i) => i >= 0 && i < options.length)
          .map((i) => options[i])
          .toList();
    }

    final plan = UserPlan.instance;
    plan.hardest = picked(1);
    plan.feelsLike = picked(4);
    plan.wish = picked(7);
    plan.win = picked(9);
    plan.heaviness = _sliders[3] ?? 0.5;
    plan.waiting = _sliders[5] ?? 0.5;
    unawaited(LocalDisk.writePlan());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final generating = _step.kind == OnboardingKind.generating;
    final progress = (_index + 1) / _steps.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.washTop,
                    Color(0xFFF8F3FC),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            if (generating)
              _GeneratingStep(
                pose: _step.pose,
                onDone: () {
                  _savePlan();
                  final signedIn = FirebaseAuth.instance.currentUser != null;
                  Navigator.of(context).pushAndRemoveUntil(
                    AppMotion.fadeTo(
                      signedIn
                          ? const ProfileSetupScreen()
                          : const SignInScreen(),
                    ),
                    (_) => false,
                  );
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
                      child: OnboardingProgressBar(
                        progress: progress,
                        onBack: _back,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.page,
                      switchInCurve: AppMotion.curve,
                      switchOutCurve: AppMotion.curve,
                      layoutBuilder: (current, previous) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [...previous, ?current],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_index),
                        child: _pageFor(_step),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 18 + bottomInset),
                    child: BunlyPrimaryButton(
                      label: _step.continueLabel,
                      onPressed: _canContinue ? _next : null,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _pageFor(OnboardingStep step) {
    switch (step.kind) {
      case OnboardingKind.multi:
        final selected = _multi[_index] ?? {};
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          itemCount: step.options.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return _QuestionIntro(step: step);
            }
            return OnboardingOptionTile(
              label: step.options[i - 1],
              selected: selected.contains(i - 1),
              onTap: () => _toggle(i - 1),
            );
          },
        );
      case OnboardingKind.slider:
        final value = _sliders.putIfAbsent(_index, () => 0.5);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 28, 16),
          child: Column(
            children: [
              _QuestionIntro(step: step),
              Expanded(
                child: Center(
                  child: OnboardingSlider(
                    value: value,
                    marks: step.sliderMarks,
                    lowLabel: step.lowLabel ?? '',
                    highLabel: step.highLabel ?? '',
                    onChanged: (v) => setState(() => _sliders[_index] = v),
                  ),
                ),
              ),
            ],
          ),
        );
      case OnboardingKind.peek:
        return BunlyPeek(step: step);
      case OnboardingKind.cheer:
        return BunlyCheer(step: step);
      case OnboardingKind.journey:
        return BunlyJourney(step: step);
      case OnboardingKind.generating:
        return const SizedBox.shrink();
    }
  }
}

class _QuestionIntro extends StatelessWidget {
  const _QuestionIntro({required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 22),
      child: WelcomeQuestion(text: step.prompt, highlight: step.highlight),
    );
  }
}

class _GeneratingStep extends StatefulWidget {
  const _GeneratingStep({required this.pose, required this.onDone});

  final String pose;
  final VoidCallback onDone;

  @override
  State<_GeneratingStep> createState() => _GeneratingStepState();
}

class _GeneratingStepState extends State<_GeneratingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        });
    _spin.forward();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          FadeUp(
            duration: AppMotion.page,
            child: Image.asset(
              widget.pose,
              height: 168,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 20),
          FadeUp(
            delay: const Duration(milliseconds: 160),
            duration: AppMotion.page,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Creating your plan… I’ll stay right here.',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.16,
                  letterSpacing: -0.8,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeUp(
            delay: const Duration(milliseconds: 240),
            duration: AppMotion.page,
            child: AnimatedBuilder(
              animation: _spin,
              builder: (context, _) {
                return SizedBox(
                  width: 168,
                  height: 168,
                  child: CustomPaint(
                    painter: _RingPainter(progress: _spin.value),
                  ),
                );
              },
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final track = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.brandHi, AppColors.brand],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      progress * 6.2832,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
