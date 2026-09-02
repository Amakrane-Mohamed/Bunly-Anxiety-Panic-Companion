import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/profile/user_plan.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/fade_up.dart';
import '../../shared/widgets/readable_width.dart';
import '../home/home_screen.dart';
import '../legal/legal_screen.dart';

enum _PayPlan { yearly, monthly }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, this.asGate = false});

  final bool asGate;

  static Future<void> open(BuildContext context) async {
    if (Access.instance.unlocked) return;
    await NativeChrome.hideForPanic();
    if (!context.mounted) {
      await NativeChrome.showRoot();
      return;
    }
    try {
      await Navigator.of(
        context,
        rootNavigator: true,
      ).push<void>(AppMotion.fadeTo(const PaywallScreen(asGate: true)));
    } finally {
      await NativeChrome.showRoot();
    }
  }

  static Future<bool> require(BuildContext context) async {
    if (Access.instance.unlocked) return true;
    await open(context);
    return Access.instance.unlocked;
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  static const _night = Color(0xFF1A1040);
  static const _violet = Color(0xFF5B38AC);

  AnimationController? _breathe;

  var _plan = _PayPlan.yearly;
  var _busy = false;
  var _titleTaps = 0;
  Timer? _titleTapReset;

  AnimationController get _breatheAnimation {
    return _breathe ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    AppAudio.stopMusic();
    unawaited(PurchasesService.instance.refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _breatheAnimation.value = 0.5;
        return;
      }
      _breatheAnimation.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _titleTapReset?.cancel();
    _breathe?.dispose();
    super.dispose();
  }

  void _enterHome() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(AppMotion.fadeTo(const HomeScreen()), (_) => false);
  }

  void _unlocked() {
    HapticFeedback.mediumImpact();
    if (widget.asGate) {
      Navigator.of(context).pop();
      return;
    }
    _enterHome();
  }

  void _dismiss() {
    if (widget.asGate) {
      Navigator.of(context).pop();
      return;
    }
    _enterHome();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _buy() async {
    if (_busy) return;
    final purchases = PurchasesService.instance;
    if (!purchases.ready) {
      _toast('Couldn’t load plans. Check your connection and try again.');
      return;
    }
    setState(() => _busy = true);
    final package = _plan == _PayPlan.yearly
        ? purchases.annualPackage
        : purchases.monthlyPackage;
    if (package == null) {
      setState(() => _busy = false);
      _toast('Couldn’t load plans. Check your connection and try again.');
      return;
    }
    final ok = await purchases.purchase(package);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok || purchases.isPro) {
      _unlocked();
      return;
    }
    if (purchases.lastError != null) {
      _toast('Couldn’t complete the purchase.');
    }
  }

  Future<void> _restore() async {
    HapticFeedback.selectionClick();
    final purchases = PurchasesService.instance;
    if (!purchases.ready) {
      _toast('Couldn’t restore purchases. Try again.');
      return;
    }
    setState(() => _busy = true);
    final ok = await purchases.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      _unlocked();
      return;
    }
    if (purchases.lastError != null) {
      _toast('Couldn’t restore purchases. Try again.');
      return;
    }
    _toast('No active subscription on this Apple ID.');
  }

  void _onTitleTap() {
    if (_busy) return;
    _titleTapReset?.cancel();
    _titleTaps += 1;
    HapticFeedback.selectionClick();
    if (_titleTaps >= 3) {
      _titleTaps = 0;
      unawaited(_openTester());
      return;
    }
    _titleTapReset = Timer(const Duration(milliseconds: 900), () {
      _titleTaps = 0;
    });
  }

  Future<void> _openTester() async {
    HapticFeedback.selectionClick();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) => const _TesterDialog(),
    );
    if (ok == true && mounted) _unlocked();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final yearly = _plan == _PayPlan.yearly;
    final name = UserPlan.instance.firstName;
    final promise = UserPlan.instance.paywallPromise;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: _violet,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _night,
          body: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_breatheAnimation.value);
                  return Transform.scale(
                    scale: 1.04 + (t * 0.05),
                    alignment: const Alignment(0, -0.2),
                    child: child,
                  );
                },
                child: Image.asset(
                  OnboardingArt.paywall,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.04),
                  filterQuality: FilterQuality.high,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xB3180E32),
                      Color(0x59180E32),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xCC5B38AC),
                      Color(0xF25B38AC),
                    ],
                    stops: [0, 0.16, 0.32, 0.5, 0.74, 1],
                  ),
                ),
              ),
              ReadableWidth(
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: _GlassClose(onTap: _dismiss),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 18),
                            FadeUp(
                              child: GestureDetector(
                                onTap: _onTitleTap,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    promise,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.display(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      height: 1.12,
                                      letterSpacing: -0.8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeUp(
                              delay: const Duration(milliseconds: 80),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  name == 'friend'
                                      ? 'Bondly stays when a wave comes.'
                                      : 'Bondly stays with you, $name.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.ui(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 10 + bottomInset),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeUp(
                            delay: const Duration(milliseconds: 120),
                            child: const _ProIncludes(),
                          ),
                          const SizedBox(height: 10),
                          FadeUp(
                            delay: const Duration(milliseconds: 140),
                            child: ListenableBuilder(
                              listenable: PurchasesService.instance,
                              builder: (context, _) {
                                return _PlanBlock(
                                  yearly: yearly,
                                  busy: _busy,
                                  onSelectYearly: () =>
                                      setState(() => _plan = _PayPlan.yearly),
                                  onSelectMonthly: () =>
                                      setState(() => _plan = _PayPlan.monthly),
                                  onRetry: () =>
                                      PurchasesService.instance.refresh(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeUp(
                            delay: const Duration(milliseconds: 220),
                            child: ListenableBuilder(
                              listenable: PurchasesService.instance,
                              builder: (context, _) {
                                final package = yearly
                                    ? PurchasesService.instance.annualPackage
                                    : PurchasesService.instance.monthlyPackage;
                                return _SubscribeButton(
                                  label: _busy
                                      ? 'One moment…'
                                      : _subscribeLabel(package),
                                  onPressed: _busy || package == null
                                      ? null
                                      : _buy,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeUp(
                            delay: const Duration(milliseconds: 250),
                            child: ListenableBuilder(
                              listenable: PurchasesService.instance,
                              builder: (context, _) {
                                return Text(
                                  _renewalLine(
                                    yearly
                                        ? PurchasesService
                                              .instance
                                              .annualPackage
                                        : PurchasesService
                                              .instance
                                              .monthlyPackage,
                                    yearly,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.ui(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: Colors.white.withValues(alpha: 0.58),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeUp(
                            delay: const Duration(milliseconds: 280),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _LegalLink(
                                  label: 'Privacy Policy',
                                  onTap: () => LegalScreen.openPrivacy(context),
                                ),
                                _FooterDot(),
                                _LegalLink(
                                  label: _busy
                                      ? 'Restoring…'
                                      : 'Restore Purchases',
                                  onTap: _busy ? () {} : _restore,
                                ),
                                _FooterDot(),
                                _LegalLink(
                                  label: 'Terms of Use',
                                  onTap: () => LegalScreen.openTerms(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

class _ProIncludes extends StatelessWidget {
  const _ProIncludes();

  static const _items = [
    'Home Screen widgets you can customize',
    'All Bondly face cards in You',
    'Full Journey — lessons, sessions, and reminders',
    'Panic companion tools on Today',
  ];

  @override
  Widget build(BuildContext context) {
    return _NoiseGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _items[i],
                    style: AppTypography.ui(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NoiseGlass extends StatelessWidget {
  const _NoiseGlass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1040).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _NoisePainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  static final _specks = List<_Speck>.generate(96, (i) {
    final n = (i * 7919 + 104729) % 10000;
    return _Speck(
      x: (n % 97) / 97,
      y: ((n ~/ 97) % 53) / 53,
      size: 0.6 + ((n % 7) * 0.18),
      opacity: 0.04 + ((n % 11) * 0.012),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final speck in _specks) {
      paint.color = Colors.white.withValues(alpha: speck.opacity);
      canvas.drawCircle(
        Offset(speck.x * size.width, speck.y * size.height),
        speck.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Speck {
  const _Speck({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });

  final double x;
  final double y;
  final double size;
  final double opacity;
}

class _PlanBlock extends StatelessWidget {
  const _PlanBlock({
    required this.yearly,
    required this.busy,
    required this.onSelectYearly,
    required this.onSelectMonthly,
    required this.onRetry,
  });

  final bool yearly;
  final bool busy;
  final VoidCallback onSelectYearly;
  final VoidCallback onSelectMonthly;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final purchases = PurchasesService.instance;
    final hasPlans =
        purchases.annualPackage != null || purchases.monthlyPackage != null;
    final loading = purchases.offerings == null && purchases.lastError == null;
    if (loading && !hasPlans) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    if (!hasPlans) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              'Couldn’t load plans right now. Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 12),
            _RestoreButton(label: 'Try again', busy: busy, onTap: onRetry),
          ],
        ),
      );
    }

    final annual = purchases.annualPackage;
    final monthly = purchases.monthlyPackage;
    final save = _savePercent(annual, monthly);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PlanCard(
              title: 'Bunly Pro',
              length: '1 year',
              price: annual?.storeProduct.priceString ?? 'Price unavailable',
              detail: _yearlyDetail(annual),
              badge: save == null ? 'Best value' : 'Save $save%',
              selected: yearly,
              onTap: onSelectYearly,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PlanCard(
              title: 'Bunly Pro',
              length: '1 month',
              price: monthly?.storeProduct.priceString ?? 'Price unavailable',
              detail: 'per month',
              selected: !yearly,
              onTap: onSelectMonthly,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({
    required this.onTap,
    this.busy = false,
    this.label = 'Restore Purchases',
  });

  final VoidCallback onTap;
  final bool busy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: SizedBox(
            height: 46,
            width: double.infinity,
            child: Center(
              child: Text(
                busy ? 'One moment…' : label,
                style: AppTypography.ui(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.length,
    required this.price,
    required this.detail,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String length;
  final String price;
  final String detail;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      button: true,
      selected: selected,
      label: '$title $length $price',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          AppAudio.answer();
          onTap();
        },
        child: AnimatedScale(
          scale: selected ? 1 : 0.97,
          duration: const Duration(milliseconds: 220),
          curve: const Cubic(0.22, 1, 0.36, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 156,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.16),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.ui(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                        _SelectDot(selected: selected),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      length,
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: AppTypography.display(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: AppTypography.ui(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
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

    if (badge == null) return card;
    return SizedBox(
      height: 156,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: card),
          Positioned(
            top: -11,
            left: 0,
            right: 0,
            child: Center(child: _GoldBadge(label: badge!)),
          ),
        ],
      ),
    );
  }
}

class _GoldBadge extends StatelessWidget {
  const _GoldBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8E7B0), Color(0xFFE4C36A), Color(0xFFC9A227)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE4C36A).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.ui(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.55,
            color: const Color(0xFF3A2A08),
          ),
        ),
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Color(0xFF5B38AC))
          : null,
    );
  }
}

class _SubscribeButton extends StatefulWidget {
  const _SubscribeButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<_SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: enabled ? 1 : 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFFFDF2E6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: _pressed ? 10 : 24,
                    offset: Offset(0, _pressed ? 4 : 10),
                  ),
                ],
              ),
              child: SizedBox(
                height: 58,
                width: double.infinity,
                child: Center(
                  child: Text(
                    widget.label,
                    style: AppTypography.ui(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassClose extends StatelessWidget {
  const _GlassClose({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.34),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TesterDialog extends StatefulWidget {
  const _TesterDialog();

  @override
  State<_TesterDialog> createState() => _TesterDialogState();
}

class _TesterDialogState extends State<_TesterDialog> {
  late final TextEditingController _code;
  var _wrong = false;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.text.trim() != Access.testerCode) {
      HapticFeedback.heavyImpact();
      setState(() => _wrong = true);
      return;
    }
    HapticFeedback.mediumImpact();
    await Access.instance.enableTester();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tester access',
              style: AppTypography.display(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the code to open the whole app.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              onChanged: (_) {
                if (_wrong) setState(() => _wrong = false);
              },
              onSubmitted: (_) => _submit(),
              style: AppTypography.ui(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                filled: true,
                fillColor: Colors.white,
                errorText: _wrong ? 'That’s not the code.' : null,
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _submit,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Open the app',
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: AppTypography.ui(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Text(
          label,
          style: AppTypography.ui(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ),
    );
  }
}

String _yearlyDetail(Package? package) {
  final product = package?.storeProduct;
  if (product == null) return 'per year';
  final monthly = product.price / 12;
  if (monthly <= 0) return 'per year';
  final symbol = _currencySymbol(product.priceString);
  return '$symbol${monthly.toStringAsFixed(2)}/mo';
}

String _renewalLine(Package? package, bool yearly) {
  final price = package?.storeProduct.priceString;
  final period = yearly ? '1 year' : '1 month';
  final shown = price == null ? period : '$period · $price';
  return 'Bunly Pro · $shown. Auto-renews. Cancel in Settings at least 24 hours before the period ends. Charged to your Apple ID.';
}

int? _savePercent(Package? annual, Package? monthly) {
  final year = annual?.storeProduct.price;
  final month = monthly?.storeProduct.price;
  if (year == null || month == null || month <= 0) return null;
  final yearIfMonthly = month * 12;
  if (year >= yearIfMonthly) return null;
  return (((yearIfMonthly - year) / yearIfMonthly) * 100).round();
}

String _subscribeLabel(Package? package) {
  final trial = _trialLabel(package);
  if (trial != null) return 'Start free trial';
  return 'Unlock Bunly Pro';
}

String? _trialLabel(Package? package) {
  final intro = package?.storeProduct.introductoryPrice;
  if (intro == null || intro.price > 0) return null;
  final units = intro.periodNumberOfUnits * intro.cycles;
  switch (intro.periodUnit) {
    case PeriodUnit.day:
      return units == 1 ? '1 day' : '$units days';
    case PeriodUnit.week:
      final days = units * 7;
      return days == 1 ? '1 day' : '$days days';
    case PeriodUnit.month:
      return units == 1 ? '1 month' : '$units months';
    case PeriodUnit.year:
      return units == 1 ? '1 year' : '$units years';
    case PeriodUnit.unknown:
      return null;
  }
}

String _currencySymbol(String priceString) {
  final match = RegExp(r'^[^\d]+').firstMatch(priceString.trim());
  return match?.group(0)?.trim() ?? '';
}
