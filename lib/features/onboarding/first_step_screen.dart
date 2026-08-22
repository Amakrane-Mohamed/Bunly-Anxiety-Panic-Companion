import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import 'onboarding_flow.dart';

class FirstStepScreen extends StatelessWidget {
  const FirstStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
                    Color(0xFFFBF8F4),
                    Color(0xFFF4EEF8),
                    Color(0xFFE4D6F0),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: FadeUp(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: AppColors.lift,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(26, 26, 26, 30),
                              child: _FirstStepCopy(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 18 + bottomInset),
                  child: BunlyPrimaryButton(
                    label: "Let's go!",
                    onPressed: () => _openOnboarding(context),
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

class _FirstStepCopy extends StatelessWidget {
  const _FirstStepCopy();

  @override
  Widget build(BuildContext context) {
    final body = AppTypography.ui(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.ink,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AvatarSpeech(),
        const SizedBox(height: 22),
        Text(
          'You’ve just taken the first step.',
          style: AppTypography.display(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.55,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'And that already says a lot about you. I know it’s not always easy to talk about how we feel, but this is a space where you can.',
          style: body,
        ),
        const SizedBox(height: 16),
        Text(
          'I’m here to support you every day, through the good and the tough.',
          style: body,
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: body,
            children: [
              const TextSpan(
                text:
                    'Before we begin, I’d love to get to know you a bit better so I can create a ',
              ),
              TextSpan(
                text: 'wellbeing plan',
                style: AppTypography.ui(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: AppColors.ink,
                ),
              ),
              const TextSpan(text: ' just for you.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarSpeech extends StatelessWidget {
  const _AvatarSpeech();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.optionFill,
            boxShadow: AppColors.lift,
            border: Border.all(color: Colors.white, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            BunlyEmotions.happy,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(width: 10),
        CustomPaint(
          size: const Size(70, 34),
          painter: _SpeechWavePainter(
            color: AppColors.brand.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _SpeechWavePainter extends CustomPainter {
  const _SpeechWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.16 + i * 0.23);
      final amp = 4.5 - i * 0.4;
      final path = Path()..moveTo(0, y);
      path.cubicTo(
        size.width * 0.28,
        y - amp,
        size.width * 0.58,
        y + amp,
        size.width,
        y,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeechWavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

void _openOnboarding(BuildContext context) {
  Navigator.of(context).push(AppMotion.fadeTo(const OnboardingFlow()));
}
