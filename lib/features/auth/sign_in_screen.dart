import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/fade_up.dart';
import '../home/profile_setup.dart';
import '../onboarding/widgets/onboarding_chrome.dart';
import 'auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _busyWith;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppAudio.stopMusic();
    AuthService.initialize();
  }

  bool get _busy => _busyWith != null;

  Future<void> _signIn(String provider) async {
    if (_busy) return;
    setState(() {
      _busyWith = provider;
      _error = null;
    });
    HapticFeedback.lightImpact();

    final outcome = provider == 'apple'
        ? await AuthService.signInWithApple()
        : await AuthService.signInWithGoogle();
    if (!mounted) return;

    setState(() => _busyWith = null);
    switch (outcome) {
      case AuthOutcome.success:
        AppAudio.answer();
        Navigator.of(context).pushAndRemoveUntil(
          AppMotion.fadeTo(const ProfileSetupScreen()),
          (_) => false,
        );
      case AuthOutcome.canceled:
        return;
      case AuthOutcome.failed:
        setState(() {
          _error = AuthService.lastMessage ?? 'Couldn’t sign in. Try again.';
        });
    }
  }

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
                    AppColors.washTop,
                    Color(0xFFFBF8FF),
                    AppColors.canvas,
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                    child: FadeUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I’m still here with you.',
                            style: AppTypography.ui(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const WelcomeQuestion(
                            text: 'Let’s save your plan so it stays yours.',
                            highlight: 'stays yours',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in and I’ll keep it safe for the next time you need me.',
                            style: AppTypography.ui(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FadeUp(
                    delay: const Duration(milliseconds: 80),
                    offset: 18,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Image.asset(
                          BunlyPoses.huggingStar,
                          height: 260,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 18 + bottomInset),
                  child: Column(
                    children: [
                      _AuthButton(
                        label: 'Continue with Apple',
                        background: AppColors.ink,
                        foreground: Colors.white,
                        busy: _busyWith == 'apple',
                        icon: CustomPaint(
                          size: const Size(18, 18),
                          painter: AppleLogoPainter(color: Colors.white),
                        ),
                        onPressed: _busy ? null : () => _signIn('apple'),
                      ),
                      const SizedBox(height: 12),
                      _AuthButton(
                        label: 'Continue with Google',
                        background: Colors.white,
                        foreground: AppColors.ink,
                        bordered: true,
                        busy: _busyWith == 'google',
                        icon: Image.asset(
                          AppAssets.googleG,
                          width: 20,
                          height: 20,
                          filterQuality: FilterQuality.high,
                        ),
                        onPressed: _busy ? null : () => _signIn('google'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.ui(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: AppColors.sos,
                          ),
                        ),
                      ],
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

class _AuthButton extends StatefulWidget {
  const _AuthButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.busy,
    this.bordered = false,
    this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Widget icon;
  final bool busy;
  final bool bordered;
  final VoidCallback? onPressed;

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: enabled || widget.busy ? 1 : 0.55,
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(999),
              border: widget.bordered
                  ? Border.all(color: AppColors.optionLine)
                  : null,
              boxShadow: enabled ? AppColors.lift : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: widget.foreground,
                      ),
                    ),
                  )
                else ...[
                  widget.icon,
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: AppTypography.ui(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: widget.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
