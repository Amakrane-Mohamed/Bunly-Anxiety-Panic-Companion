import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';
import '../convert/plan_reveal_screen.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({super.key});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _glow;
  late final AnimationController _spin;
  late final Animation<double> _scale;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _scale = CurvedAnimation(parent: _pop, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _pop.forward();
      AppAudio.stopMusic();
      _playWinSound();
    });
  }

  Future<void> _playWinSound() async {
    try {
      final ctx = AudioContextConfig(respectSilence: false).build();
      await AudioPlayer.global.setAudioContext(ctx);
      await _player.setAudioContext(ctx);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1);
      await _player.play(AssetSource('audio/win.mp3'));
    } catch (error, stack) {
      debugPrint('Win sound failed: $error\n$stack');
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _glow.dispose();
    _spin.dispose();
    _player.dispose();
    super.dispose();
  }

  void _continue() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.fadeTo(const PlanRevealScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF3D6),
                      Color(0xFFFFF8EC),
                      Color(0xFFF8F3FC),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.28, 0.62, 1],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.72),
                child: AnimatedBuilder(
                  animation: _glow,
                  builder: (context, _) {
                    final t = 0.82 + (_glow.value * 0.18);
                    return Container(
                      width: 280 * t,
                      height: 160 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFE08A).withValues(alpha: 0.9),
                            const Color(0xFFFFF3D6).withValues(alpha: 0.35),
                            const Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedBuilder(
                animation: _spin,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GoldRaysPainter(turn: _spin.value),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _glow,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GoldSparklePainter(pulse: _glow.value),
                  );
                },
              ),
              Column(
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: _scale,
                    child: Image.asset(
                      BunlyPoses.happyWin,
                      height: 280,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  FadeUp(
                    delay: const Duration(milliseconds: 360),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 4, 32, 0),
                      child: Text(
                        'That’s brave. I hear you.',
                        textAlign: TextAlign.center,
                        style: AppTypography.display(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.16,
                          letterSpacing: -0.8,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeUp(
                    delay: const Duration(milliseconds: 520),
                    child: Text(
                      'Thank you for telling me.',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeUp(
                    delay: const Duration(milliseconds: 780),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 18 + bottomInset),
                      child: BunlyPrimaryButton(
                        label: 'Continue',
                        onPressed: _continue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldRaysPainter extends CustomPainter {
  const _GoldRaysPainter({required this.turn});

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turn * math.pi * 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD56A).withValues(alpha: 0.28),
          const Color(0x00FFD56A),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 210));
    const rays = 16;
    for (var i = 0; i < rays; i++) {
      final a = (i / rays) * math.pi * 2;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.06) * 210, math.sin(a - 0.06) * 210)
        ..lineTo(math.cos(a + 0.06) * 210, math.sin(a + 0.06) * 210)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoldRaysPainter oldDelegate) =>
      oldDelegate.turn != turn;
}

class _GoldSparklePainter extends CustomPainter {
  const _GoldSparklePainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(11);
    for (var i = 0; i < 22; i++) {
      final seed = random.nextDouble();
      final x = size.width * (0.1 + seed * 0.8);
      final y = size.height * (0.08 + random.nextDouble() * 0.52);
      final twinkle = 0.5 + 0.5 * math.sin((pulse + seed) * math.pi);
      final r = (2.0 + seed * 3.2) * (0.85 + twinkle * 0.25);
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFF1B8),
          const Color(0xFFE8B84A),
          seed,
        )!.withValues(alpha: 0.22 + twinkle * 0.55);
      _star(canvas, Offset(x, y), r, paint);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()..moveTo(c.dx, c.dy - r);
    for (var i = 1; i < 8; i++) {
      final ang = -math.pi / 2 + i * math.pi / 4;
      final rad = i.isOdd ? r * 0.38 : r;
      path.lineTo(c.dx + math.cos(ang) * rad, c.dy + math.sin(ang) * rad);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldSparklePainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
