import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _iconInDuration = Duration(milliseconds: 720);
  static const _iconHold = Duration(milliseconds: 700);
  static const _iconOutDuration = Duration(milliseconds: 220);
  static const _circleDuration = Duration(milliseconds: 1100);
  static const _phraseDuration = Duration(milliseconds: 640);
  static const _holdDuration = Duration(seconds: 3);
  static const _phraseOutDuration = Duration(milliseconds: 360);
  static const _circleCurve = Cubic(0.4, 0.0, 0.2, 1.0);

  late final AnimationController _icon;
  late final AnimationController _fill;
  late final AnimationController _phrase;
  late final Animation<double> _fillValue;

  var _baseGone = false;
  var _overlayGone = false;

  @override
  void initState() {
    super.initState();
    _icon = AnimationController(vsync: this, duration: _iconInDuration);
    _fill = AnimationController(vsync: this, duration: _circleDuration);
    _phrase = AnimationController(vsync: this, duration: _phraseDuration);
    _fillValue = CurvedAnimation(parent: _fill, curve: _circleCurve);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _play();
    });
  }

  Future<void> _play() async {
    final reduced = MediaQuery.disableAnimationsOf(context);

    if (reduced) {
      _icon.value = 0;
      _fill.value = 1;
      _phrase.value = 1;
      _baseGone = true;
      await Future<void>.delayed(_holdDuration);
      if (!mounted) return;
      _phrase.value = 0;
      _fill.value = 0;
      setState(() => _overlayGone = true);
      return;
    }

    await _icon.forward();
    if (!mounted) return;

    await Future<void>.delayed(_iconHold);
    if (!mounted) return;

    _icon.duration = _iconOutDuration;
    _icon.reverse();
    await _fill.forward();
    if (!mounted) return;

    _baseGone = true;

    await _phrase.forward();
    if (!mounted) return;

    await Future<void>.delayed(_holdDuration);
    if (!mounted) return;

    _phrase.duration = _phraseOutDuration;
    await _phrase.reverse();
    if (!mounted) return;

    await _fill.reverse();
    if (!mounted) return;

    setState(() => _overlayGone = true);
  }

  @override
  void dispose() {
    _icon.dispose();
    _fill.dispose();
    _phrase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final diameter = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null
            ? const HomeScreen()
            : const WelcomeScreen(),
        if (!_overlayGone)
          AnimatedBuilder(
            animation: Listenable.merge([_icon, _fill, _phrase]),
            builder: (context, _) {
              final onPurple = !_baseGone || _fillValue.value > 0.42;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: onPurple
                    ? SystemUiOverlayStyle.light.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: AppColors.splash,
                        systemNavigationBarIconBrightness: Brightness.light,
                      )
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: AppColors.canvas,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!_baseGone)
                      const ColoredBox(
                        color: AppColors.splash,
                        child: SizedBox.expand(),
                      ),
                    Opacity(
                      opacity: _icon.value,
                      child: Transform.scale(
                        scale: 0.92 + (0.08 * _icon.value),
                        child: const _SplashIcon(),
                      ),
                    ),
                    OverflowBox(
                      maxWidth: diameter,
                      maxHeight: diameter,
                      child: RepaintBoundary(
                        child: Transform.scale(
                          scale: _fillValue.value,
                          child: Container(
                            width: diameter,
                            height: diameter,
                            decoration: const BoxDecoration(
                              color: AppColors.breath,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      excluding: _phrase.value == 0,
                      child: _BreathPhrase(progress: _phrase.value),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SplashIcon extends StatelessWidget {
  const _SplashIcon();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: Image.asset(
        AppAssets.bunlyIcon,
        width: 118,
        height: 118,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BreathPhrase extends StatelessWidget {
  const _BreathPhrase({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - progress)),
        child: Semantics(
          liveRegion: true,
          label: 'take a deep breath',
          child: Text(
            'take a deep breath',
            textAlign: TextAlign.center,
            style:
                AppTypography.display(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: AppColors.onBrand,
                ).copyWith(
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                  shadows: const [],
                ),
          ),
        ),
      ),
    );
  }
}
