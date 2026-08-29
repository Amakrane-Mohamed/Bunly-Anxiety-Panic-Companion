import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/layout/app_layout.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/hud_chips.dart';
import '../../shared/widgets/readable_width.dart';
import '../../shared/widgets/scene_hero.dart';
import '../../shared/widgets/sos_button.dart';
import '../panic/panic_entry_sheet.dart';
import 'today_home_body.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const _roomAspect = 765 / 1024;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        final wide = AppLayout.isWide(context);
        final heroWidth = math.min(size.width, AppLayout.contentMax);
        final naturalHero = heroWidth / _roomAspect;
        final heroHeight = wide
            ? math.min(naturalHero, size.height * 0.42)
            : naturalHero;

        return ColoredBox(
          color: AppColors.home,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: const ReadableWidth(child: _HomeHero()),
              ),
              Expanded(
                child: ReadableWidth(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: const [TodayHomeBody()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ExcludeSemantics(child: SceneArt(asset: BunlyToday.home)),
        _BondlyOnRug(line: AppStore.instance.bunlyLine),
        const _TodayHud(),
        _BedSos(),
      ],
    );
  }
}

class _BedSos extends StatelessWidget {
  const _BedSos();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.52, 0.72),
      child: SosButton(onPressed: () => PanicEntrySheet.sos(context)),
    );
  }
}

/// House Bondly: sleeping until the Today screen is touched.
/// Later, [interacting] can be driven by real activity instead of taps.
class _BondlyOnRug extends StatefulWidget {
  const _BondlyOnRug({required this.line});

  final String line;

  static const poses = [
    BunlyPoses.sitting,
    BunlyPoses.winking,
    BunlyPoses.huggingStar,
    BunlyPoses.delighted,
    BunlyPoses.proud,
    BunlyPoses.jumping,
  ];

  @override
  State<_BondlyOnRug> createState() => _BondlyOnRugState();
}

class _BondlyOnRugState extends State<_BondlyOnRug>
    with SingleTickerProviderStateMixin {
  static const _restAfter = Duration(seconds: 5);

  late final AnimationController _breathe;
  Timer? _rest;
  var _interacting = false;
  var _poseIndex = 0;

  bool get interacting => _interacting;

  String get _art {
    if (!interacting) return BunlyToday.sleeping;
    return _BondlyOnRug.poses[_poseIndex];
  }

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce || interacting) {
      _breathe.stop();
      _breathe.value = 0;
      return;
    }
    if (!_breathe.isAnimating) {
      _breathe.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rest?.cancel();
    _breathe.dispose();
    super.dispose();
  }

  void _onInteract() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_interacting) {
        _poseIndex = (_poseIndex + 1) % _BondlyOnRug.poses.length;
      } else {
        _interacting = true;
        _poseIndex = 0;
      }
    });
    _syncMotion();
    _rest?.cancel();
    _rest = Timer(_restAfter, _goToSleep);
  }

  void _goToSleep() {
    if (!mounted || !_interacting) return;
    setState(() {
      _interacting = false;
      _poseIndex = 0;
    });
    _syncMotion();
  }

  @override
  Widget build(BuildContext context) {
    final art = _art;
    final sleeping = !interacting;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final bunlyWidth = width * (sleeping ? 0.40 : 0.28);
        final bunlyHeight = sleeping ? bunlyWidth * 0.70 : bunlyWidth;

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: height * 0.20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Whisper(text: widget.line),
                  const SizedBox(height: 8),
                  Semantics(
                    button: true,
                    label: sleeping ? 'Bunly is sleeping' : 'Bunly is with you',
                    child: GestureDetector(
                      onTap: _onInteract,
                      child: AnimatedBuilder(
                        animation: _breathe,
                        builder: (context, child) {
                          final scale = 1 + (_breathe.value * 0.018);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 380),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.94,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            art,
                            key: ValueKey(art),
                            width: bunlyWidth,
                            height: bunlyHeight,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TodayHud extends StatelessWidget {
  const _TodayHud();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final top = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: top + 8,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: HudStatRow(hearts: store.hearts, streak: store.checkInStreak),
      ),
    );
  }
}

class _Whisper extends StatelessWidget {
  const _Whisper({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 196),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.lift,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
