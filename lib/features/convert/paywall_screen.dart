import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
                                if (kDebugMode) _TestLabel(onTap: _openTester),
                              ],
                            ),
                            const SizedBox(height: 18),
                            FadeUp(
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
                            delay: const Duration(milliseconds: 140),
                            child: ListenableBuilder(
                              listenable: PurchasesService.instance,
                              builder: (context, _) {
                                final purchases = PurchasesService.instance;
                                final annual = purchases.annualPackage;
                                final monthly = purchases.monthlyPackage;
                                final save = _savePercent(annual, monthly);
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _PlanCard(
                                        title: 'Yearly',
                                        price:
                                            annual?.storeProduct.priceString ??
                                            '—',
                                        detail: _yearlyDetail(annual),
                                        badge: save == null
                                            ? null
                                            : 'Save $save%',
                                        selected: yearly,
                                        onTap: () => setState(
                                          () => _plan = _PayPlan.yearly,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _PlanCard(
                                        title: 'Monthly',
                                        price:
                                            monthly?.storeProduct.priceString ??
                                            '—',
                                        detail: 'billed monthly',
                                        selected: !yearly,
                                        onTap: () => setState(
                                          () => _plan = _PayPlan.monthly,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                      : _subscribeLabel(package, yearly),
                                  onPressed: _busy ? null : _buy,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeUp(
                            delay: const Duration(milliseconds: 260),
                            child: Text(
                              yearly
                                  ? 'Bunly Pro yearly. Auto-renews until you cancel in Settings → Subscriptions, at least 24 hours before the period ends. Charged to your Apple ID.'
                                  : 'Bunly Pro monthly. Auto-renews until you cancel in Settings → Subscriptions, at least 24 hours before the period ends. Charged to your Apple ID.',
                              textAlign: TextAlign.center,
                              style: AppTypography.ui(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FadeUp(
                            delay: const Duration(milliseconds: 280),
                            child: GestureDetector(
                              onTap: () {
                                if (!_busy) _restore();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  'Restore purchases',
                                  style: AppTypography.ui(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          FadeUp(
                            delay: const Duration(milliseconds: 320),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _LegalLink(
                                  label: 'Privacy Policy',
                                  onTap: () => LegalScreen.openPrivacy(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '·',
                                    style: AppTypography.ui(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
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
    return Semantics(
      button: true,
      selected: selected,
      label: title,
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
            height: 148,
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
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.ui(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.94),
                            ),
                          ),
                        ),
                        _SelectDot(selected: selected),
                      ],
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: selected ? 0.22 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
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
                      ),
                    ] else
                      const SizedBox(height: 8),
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
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
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

class _TestLabel extends StatelessWidget {
  const _TestLabel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Test',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Text(
            'Test',
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.32),
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

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          label,
          style: AppTypography.ui(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

String _yearlyDetail(Package? package) {
  final product = package?.storeProduct;
  if (product == null) return 'billed yearly';
  final monthly = product.price / 12;
  if (monthly <= 0) return 'billed yearly';
  final symbol = _currencySymbol(product.priceString);
  return '$symbol${monthly.toStringAsFixed(2)} / month';
}

int? _savePercent(Package? annual, Package? monthly) {
  final year = annual?.storeProduct.price;
  final month = monthly?.storeProduct.price;
  if (year == null || month == null || month <= 0) return null;
  final yearIfMonthly = month * 12;
  if (year >= yearIfMonthly) return null;
  return (((yearIfMonthly - year) / yearIfMonthly) * 100).round();
}

String _subscribeLabel(Package? package, bool yearly) {
  final trial = _trialLabel(package);
  if (yearly && trial != null) return 'Start $trial free';
  return 'Continue';
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
