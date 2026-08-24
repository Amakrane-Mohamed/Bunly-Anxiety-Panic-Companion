import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/theme/app_colors.dart';
import '../shell/app_shell.dart';
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
  static const _circleCurve = Cubic(0.4, 0.0, 0.2, 1.0);

  late final AnimationController _icon;
  late final AnimationController _fill;
  late final Animation<double> _fillValue;
  var _left = false;

  @override
  void initState() {
    super.initState();
    _icon = AnimationController(vsync: this, duration: _iconInDuration);
    _fill = AnimationController(vsync: this, duration: _circleDuration);
    _fillValue = CurvedAnimation(parent: _fill, curve: _circleCurve);
    NativeChrome.hideTabs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NativeChrome.hideTabs();
      if (mounted) _play();
    });
  }

  Future<void> _play() async {
    final reduced = MediaQuery.disableAnimationsOf(context);

    if (reduced) {
      _icon.value = 0;
      _fill.value = 1;
      if (!mounted) return;
      await _leave();
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

    await _leave();
  }

  Future<void> _leave() async {
    if (_left) return;
    _left = true;
    NativeChrome.hideTabs();
    if (!mounted) return;
    final Widget next;
    if (Access.instance.onboarded) {
      AppAudio.stopMusic();
      next = const AppShell();
    } else {
      next = const WelcomeScreen();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => next,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _icon.dispose();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final diameter = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    return Scaffold(
      backgroundColor: AppColors.splash,
      body: Stack(
        alignment: Alignment.center,
        children: [
          const ColoredBox(
            color: AppColors.splash,
            child: SizedBox.expand(),
          ),
          AnimatedBuilder(
              animation: Listenable.merge([_icon, _fill]),
              builder: (context, _) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: AppColors.splash,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
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
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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
