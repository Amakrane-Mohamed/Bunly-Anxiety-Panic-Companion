import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../home/home_screen.dart';

enum _PayPlan { yearly, monthly }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  static const _lines = [
    'When a wave hits, I’m right here.',
    'Calm moments, anytime you need.',
    'A companion that stays close.',
    'A plan made just for you.',
  ];

  AnimationController? _closeIn;
  Timer? _closeTimer;

  var _plan = _PayPlan.yearly;

  AnimationController get _closeAnimation {
    return _closeIn ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
  }

  @override
  void initState() {
    super.initState();
    _closeAnimation;
    AppAudio.stopMusic();
    _closeTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _closeAnimation.value = 1;
        return;
      }
      _closeAnimation.forward();
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _closeIn?.dispose();
    super.dispose();
  }

  void _enterHome() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(AppMotion.fadeTo(const HomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final yearly = _plan == _PayPlan.yearly;
    final imageHeight = size.height * (size.height < 740 ? 0.24 : 0.28);

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.canvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          body: Column(
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      OnboardingArt.paywall,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                    ),
                    const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x00FFFFFF),
                              Color(0xA3FFFFFF),
                              AppColors.canvas,
                            ],
                            stops: [0, 0.52, 0.8, 1],
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _closeAnimation,
                      builder: (context, child) {
                        return IgnorePointer(
                          ignoring: _closeAnimation.value < 0.2,
                          child: FadeTransition(
                            opacity: _closeAnimation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.86, end: 1).animate(
                                CurvedAnimation(
                                  parent: _closeAnimation,
                                  curve: const Cubic(0.16, 1, 0.3, 1),
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                            child: _LiquidGlassClose(onTap: _enterHome),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                child: FadeUp(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Keep Bunly beside you ',
                          style: AppTypography.display(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                            letterSpacing: -0.6,
                            color: AppColors.brand,
                          ),
                        ),
                        TextSpan(
                          text: '✨',
                          style: AppTypography.display(
                            fontSize: 26,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeUp(
                  delay: const Duration(milliseconds: 80),
                  child: Column(
                    children: [
                      for (var i = 0; i < _lines.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Text(
                          _lines[i],
                          textAlign: TextAlign.center,
                          style: AppTypography.ui(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8 + bottomInset),
                child: Column(
                  children: [
                    FadeUp(
                      delay: const Duration(milliseconds: 140),
                      child: _OfferRow(
                        title: 'Annual',
                        price: '\$39.99',
                        detail: '\$3.33/mo',
                        badge: '65% OFF',
                        selected: yearly,
                        onTap: () => setState(() => _plan = _PayPlan.yearly),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeUp(
                      delay: const Duration(milliseconds: 180),
                      child: _OfferRow(
                        title: 'Monthly',
                        price: '\$9.99',
                        detail: 'billed monthly',
                        selected: !yearly,
                        onTap: () => setState(() => _plan = _PayPlan.monthly),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeUp(
                      delay: const Duration(milliseconds: 220),
                      child: BunlyPrimaryButton(
                        label: yearly ? 'Start 7 days free' : 'Subscribe now',
                        onPressed: _enterHome,
                      ),
                    ),
                    BunlyTextButton(
                      label: 'Restore Purchases',
                      onPressed: () => HapticFeedback.selectionClick(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.title,
    required this.price,
    required this.detail,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String detail;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        AppAudio.answer();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 64,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelected : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.optionLine,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.brand : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.brand : AppColors.optionLine,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTypography.ui(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.ui(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTypography.ui(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  detail,
                  style: AppTypography.ui(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
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

class _LiquidGlassClose extends StatelessWidget {
  const _LiquidGlassClose({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.28),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.62),
                      Colors.white.withValues(alpha: 0.20),
                      const Color(0xFFD4C2F0).withValues(alpha: 0.20),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 1.1,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Color(0x73FFFFFF), Color(0x00FFFFFF)],
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: const Color(0xFF1C1529).withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
