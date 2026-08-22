import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/profile/user_plan.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../onboarding/widgets/onboarding_chrome.dart';
import 'convert_chrome.dart';
import 'first_breath_screen.dart';

class PlanRevealScreen extends StatefulWidget {
  const PlanRevealScreen({super.key});

  @override
  State<PlanRevealScreen> createState() => _PlanRevealScreenState();
}

class _PlanRevealScreenState extends State<PlanRevealScreen> {
  @override
  void initState() {
    super.initState();
    AppAudio.startMusic();
  }

  void _continue() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.fadeTo(const FirstBreathScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final plan = UserPlan.instance;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final name = plan.firstName;

    return PopScope(
      canPop: false,
      child: ConvertWash(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  children: [
                    FadeUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ConvertEyebrow('Your plan'),
                          const SizedBox(height: 14),
                          WelcomeQuestion(
                            text: 'I made this for you, $name.',
                            highlight: name == 'friend' ? 'for you' : name,
                            fontSize: 30,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeUp(
                      delay: const Duration(milliseconds: 140),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          BunlyPoses.huggingStar,
                          height: 108,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeUp(
                      delay: const Duration(milliseconds: 220),
                      child: ConvertPlanCard(
                        index: '01',
                        kicker: 'When a wave hits',
                        body: plan.wishLine,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeUp(
                      delay: const Duration(milliseconds: 320),
                      child: ConvertPlanCard(
                        index: '02',
                        kicker: 'We’ll work toward',
                        body: plan.winLine,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeUp(
                      delay: const Duration(milliseconds: 420),
                      child: ConvertPlanCard(
                        index: '03',
                        kicker: 'Starting with',
                        body: plan.startFocus,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeUp(
                      delay: const Duration(milliseconds: 520),
                      child: Text(
                        'We’ll try this together for 7 days — one calm moment at a time.',
                        style: AppTypography.ui(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeUp(
              delay: const Duration(milliseconds: 640),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 18 + bottomInset),
                child: BunlyPrimaryButton(
                  label: 'Try a calm moment',
                  onPressed: _continue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
