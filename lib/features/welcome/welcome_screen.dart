import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../onboarding/first_step_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppAudio.startMusic();
    });

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
                    Color(0xFFFBF8FF),
                    AppColors.canvas,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(28, 36, 28, 0),
                    child: FadeUp(child: _WelcomeCopy()),
                  ),
                ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _WelcomeSheet(bottomInset: bottomInset),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 72 + bottomInset,
                        child: IgnorePointer(
                          child: FadeUp(
                            delay: const Duration(milliseconds: 80),
                            offset: 18,
                            child: Image.asset(
                              BunlyPoses.winking,
                              height: 248,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi there, I’m Bunly.',
          style: AppTypography.ui(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: AppTypography.display(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: -0.8,
              color: AppColors.inkMuted,
            ),
            children: [
              const TextSpan(text: 'I’m here to support you through '),
              TextSpan(
                text: 'anxiety and panic.',
                style: AppTypography.display(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.16,
                  letterSpacing: -0.8,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'I’ve got you. Let’s begin.',
          style: AppTypography.ui(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }
}

class _WelcomeSheet extends StatelessWidget {
  const _WelcomeSheet({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 20 + bottomInset),
        child: BunlyPrimaryButton(
          label: 'Get started',
          onPressed: () => _openFirstStep(context),
        ),
      ),
    );
  }
}

void _openFirstStep(BuildContext context) {
  Navigator.of(context).push(AppMotion.fadeTo(const FirstStepScreen()));
}
