import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/motion/app_motion.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import 'help_backdrop.dart';
import 'recovery_screen.dart';

enum _Step { breathe, see, feel, feet, truth }

class PanicModeScreen extends StatefulWidget {
  const PanicModeScreen({super.key, required this.episode});

  final PanicEpisode episode;

  @override
  State<PanicModeScreen> createState() => _PanicModeScreenState();
}

class _PanicModeScreenState extends State<PanicModeScreen>
    with SingleTickerProviderStateMixin {
  static const _truths = [
    ('Your body is being loud.', 'That’s a false alarm. Not a fire.'),
    ('This peaks. Then it passes.', 'That’s the deal. We wait together.'),
    ('You stayed.', 'That’s the brave part. I’m proud of you.'),
  ];

  var _step = _Step.breathe;
  var _breaths = 0;
  var _holding = false;
  var _breathLabel = 'Press and hold';
  var _pops = 0;
  var _truth = 0;
  var _running = true;

  late final AnimationController _orb;

  int get _stepIndex => _Step.values.indexOf(_step);

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this);
    AppStore.instance.useTool(widget.episode, 'breathing');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppAudio.startMusic();
    });
  }

  @override
  void dispose() {
    _running = false;
    _orb.dispose();
    super.dispose();
  }

  void _next() {
    if (!_running || !mounted) return;
    AppAudio.answer();
    HapticFeedback.mediumImpact();
    final nextIndex = _stepIndex + 1;
    if (nextIndex >= _Step.values.length) {
      _okayNow();
      return;
    }
    setState(() {
      _step = _Step.values[nextIndex];
      _pops = 0;
      if (_step == _Step.see || _step == _Step.feel) {
        AppStore.instance.useTool(widget.episode, 'grounding');
      }
    });
  }

  void _okayNow() {
    _running = false;
    AppAudio.stopMusic();
    Navigator.of(context).pushReplacement(
      AppMotion.fadeTo(RecoveryScreen(episode: widget.episode)),
    );
  }

  void _breathDown() {
    if (_step != _Step.breathe) return;
    _orb.stop();
    _holding = true;
    AppAudio.tap();
    HapticFeedback.mediumImpact();
    setState(() => _breathLabel = 'Breathe in');
    _orb.duration = const Duration(seconds: 4);
    _orb.animateTo(1, curve: Curves.easeInOutSine);
  }

  void _breathUp() {
    if (_step != _Step.breathe || !_holding) return;
    _holding = false;
    HapticFeedback.lightImpact();
    final amount = _orb.value;
    setState(() => _breathLabel = 'Let it go');
    _orb.stop();
    _orb.duration = Duration(
      milliseconds: (4200 * amount + 800).round().clamp(500, 6000),
    );
    _orb.animateTo(0, curve: Curves.easeInOutSine).whenComplete(() {
      if (!mounted || _step != _Step.breathe) return;
      final earned = amount >= 0.28;
      setState(() {
        if (earned) _breaths += 1;
        _breathLabel = _breaths >= 3 ? 'Nice. That helped.' : 'Again. Hold with me.';
      });
      if (_breaths >= 3) {
        Future<void>.delayed(const Duration(milliseconds: 420), () {
          if (!mounted || !_running || _step != _Step.breathe) return;
          _next();
        });
      }
    });
  }

  void _pop() {
    final need = _step == _Step.see ? 5 : 4;
    AppAudio.tap();
    HapticFeedback.selectionClick();
    if (_pops + 1 >= need) {
      _next();
      return;
    }
    setState(() => _pops += 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

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
                  padding: EdgeInsets.fromLTRB(22, 18, 22, 12 + bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HelpProgress(
                        step: _stepIndex,
                        total: _Step.values.length,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _stepBody(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BunlyTextButton(
                        label: 'I’m okay now',
                        onPressed: _okayNow,
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

  Widget _stepBody() {
    return switch (_step) {
      _Step.breathe => _BreatheStep(
        orb: _orb,
        label: _breathLabel,
        breaths: _breaths,
        onDown: _breathDown,
        onUp: _breathUp,
      ),
      _Step.see => _LightsStep(
        title: 'Tap 5 things you can see.',
        subtitle: 'A lamp. A colour. My silly coat. Anything.',
        total: 5,
        done: _pops,
        onPop: _pop,
      ),
      _Step.feel => _LightsStep(
        title: 'Now 4 things you can feel.',
        subtitle: 'Your shirt. The floor. This phone. Air.',
        total: 4,
        done: _pops,
        onPop: _pop,
      ),
      _Step.feet => _TalkStep(
        title: 'Both feet. Heavy.',
        body: 'Press them into the floor like you’re plugging in. Tap when they feel real.',
        action: 'They’re on the floor',
        onAction: _next,
      ),
      _Step.truth => _TalkStep(
        title: _truths[_truth].$1,
        body: _truths[_truth].$2,
        action: _truth >= _truths.length - 1 ? 'I’m okay now' : 'Still here',
        onAction: () {
          if (_truth >= _truths.length - 1) {
            _okayNow();
            return;
          }
          AppAudio.answer();
          HapticFeedback.selectionClick();
          setState(() => _truth += 1);
        },
      ),
    };
  }
}

class _BreatheStep extends StatelessWidget {
  const _BreatheStep({
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
        Text(
          'Breathe with me.',
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
          'Hold the circle to breathe in. Let go to breathe out.',
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 16),
        Listener(
          onPointerDown: (_) => onDown(),
          onPointerUp: (_) => onUp(),
          onPointerCancel: (_) => onUp(),
          child: AnimatedBuilder(
            animation: orb,
            builder: (context, _) {
              final t = orb.value;
              final scale = 0.82 + (t * 0.22);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 148,
                  height: 148,
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
                        color: AppColors.brand.withValues(alpha: 0.28 + t * 0.18),
                        blurRadius: 22 + t * 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$breaths / 3 breaths',
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

class _LightsStep extends StatelessWidget {
  const _LightsStep({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.done,
    required this.onPop,
  });

  final String title;
  final String subtitle;
  final int total;
  final int done;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < total; i++)
              _LightDot(
                lit: i < done,
                next: i == done,
                onTap: i == done ? onPop : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _LightDot extends StatelessWidget {
  const _LightDot({
    required this.lit,
    required this.next,
    required this.onTap,
  });

  final bool lit;
  final bool next;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: next ? 1.08 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lit ? AppColors.brand : AppColors.optionFill,
            border: Border.all(
              color: next ? AppColors.brand : AppColors.optionLine,
              width: next ? 2 : 1.4,
            ),
            boxShadow: next
                ? [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: lit
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
              : null,
        ),
      ),
    );
  }
}

class _TalkStep extends StatelessWidget {
  const _TalkStep({
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 20),
        BunlyPrimaryButton(label: action, onPressed: onAction),
      ],
    );
  }
}
