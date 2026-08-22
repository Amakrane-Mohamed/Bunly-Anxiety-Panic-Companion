import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding_content.dart';
import 'onboarding_chrome.dart';

class BunlyPeek extends StatelessWidget {
  const BunlyPeek({super.key, required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final fromRight = step.peekSide == PeekSide.right;
    final begin = Offset(fromRight ? 0.28 : -0.28, 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
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
                WelcomeQuestion(text: step.prompt, highlight: step.highlight),
              ],
            ),
          ),
          Expanded(
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(begin: begin, end: Offset.zero),
              duration: AppMotion.moment,
              curve: AppMotion.curve,
              builder: (context, offset, child) {
                return FractionalTranslation(translation: offset, child: child);
              },
              child: Align(
                alignment: fromRight
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: fromRight ? 0 : 8,
                    right: fromRight ? 8 : 0,
                    bottom: 8,
                  ),
                  child: Image.asset(
                    step.pose,
                    height: 280,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    alignment: fromRight
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BunlyCheer extends StatelessWidget {
  const BunlyCheer({super.key, required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: AppMotion.moment,
          curve: AppMotion.curve,
          builder: (context, scale, child) {
            return Opacity(
              opacity: ((scale - 0.92) / 0.08).clamp(0, 1),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  step.pose,
                  height: 220,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 20),
                WelcomeQuestion(
                  text: step.prompt,
                  highlight: step.highlight,
                  textAlign: TextAlign.center,
                ),
                if (step.speech != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    step.speech!,
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BunlyJourney extends StatelessWidget {
  const BunlyJourney({super.key, required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.42,
                      child: Image.asset(
                        OnboardingArt.journeyLandscape,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  Image.asset(
                    step.pose,
                    height: 260,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          WelcomeQuestion(
            text: step.prompt,
            highlight: step.highlight,
            textAlign: TextAlign.center,
            fontSize: 28,
          ),
          if (step.speech != null) ...[
            const SizedBox(height: 12),
            Text(
              step.speech!,
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
