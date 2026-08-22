import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/profile/user_plan.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../onboarding/widgets/onboarding_chrome.dart';
import 'convert_chrome.dart';
import 'paywall_screen.dart';

class StayCloseScreen extends StatefulWidget {
  const StayCloseScreen({super.key});

  @override
  State<StayCloseScreen> createState() => _StayCloseScreenState();
}

class _StayCloseScreenState extends State<StayCloseScreen> {
  var _busy = false;

  Future<void> _allow() async {
    if (_busy) return;
    setState(() => _busy = true);
    UserPlan.instance.wantsCheckIns = true;
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      debugPrint('Notification permission failed: $error');
    }
    if (!mounted) return;
    _openPaywall();
  }

  void _skip() {
    UserPlan.instance.wantsCheckIns = false;
    _openPaywall();
  }

  void _openPaywall() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.fadeTo(const PaywallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final name = UserPlan.instance.firstName;
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
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeUp(child: const ConvertEyebrow('Stay close')),
                      const SizedBox(height: 14),
                      FadeUp(
                        delay: const Duration(milliseconds: 80),
                        child: WelcomeQuestion(
                          text:
                              'When a wave might come, can I check in, $name?',
                          highlight: 'check in',
                          fontSize: 30,
                        ),
                      ),
                      const Spacer(),
                      FadeUp(
                        delay: const Duration(milliseconds: 200),
                        child: Center(
                          child: Image.asset(
                            BunlyPoses.winking,
                            height: 176,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeUp(
                        delay: const Duration(milliseconds: 320),
                        child: Text(
                          'A quiet reminder that you’re not doing this alone. I’ll stay close for these 7 days.',
                          style: AppTypography.ui(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 8 + bottomInset),
              child: FadeUp(
                delay: const Duration(milliseconds: 420),
                child: Column(
                  children: [
                    BunlyPrimaryButton(
                      label: 'Stay close',
                      onPressed: _busy ? null : _allow,
                    ),
                    if (!_busy)
                      BunlyTextButton(label: 'Not now', onPressed: _skip),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
