import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import '../home/home_screen.dart';

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
      await Navigator.of(context, rootNavigator: true).push<void>(
        AppMotion.fadeTo(const PaywallScreen(asGate: true)),
      );
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

  AnimationController? _closeIn;
  AnimationController? _breathe;
  Timer? _closeTimer;

  var _plan = _PayPlan.yearly;
  var _busy = false;

  AnimationController get _closeAnimation {
    return _closeIn ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
  }

  AnimationController get _breatheAnimation {
    return _breathe ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    _closeAnimation;
    AppAudio.stopMusic();
    unawaited(PurchasesService.instance.refresh());
    _closeTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _closeAnimation.value = 1;
        return;
      }
      _closeAnimation.forward();
    });
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
    _closeTimer?.cancel();
    _closeIn?.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _buy() async {
    if (_busy) return;
    final purchases = PurchasesService.instance;
    if (!purchases.ready) {
      _toast('Add your RevenueCat Apple API key, then try again.');
      return;
    }
    setState(() => _busy = true);
    final package = _plan == _PayPlan.yearly
        ? purchases.annualPackage
        : purchases.monthlyPackage;
    if (package == null) {
      setState(() => _busy = false);
      _toast('Add bunly_annual / bunly_monthly in RevenueCat, then try again.');
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
      _toast('Paste your RevenueCat Apple API key first.');
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
                  alignment: const Alignment(0, -0.12),
                  filterQuality: FilterQuality.high,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x3308142A),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xA62A1458),
                      Color(0xF25B38AC),
                    ],
                    stops: [0, 0.22, 0.46, 0.68, 1],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: AnimatedBuilder(
                            animation: _closeAnimation,
                            builder: (context, child) {
                              return IgnorePointer(
                                ignoring: _closeAnimation.value < 0.2,
                                child: FadeTransition(
                                  opacity: _closeAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: _GlassClose(onTap: _dismiss),
                          ),
                        ),
                        const Spacer(),
                        _TestChip(onTap: _openTester),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10 + bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeUp(
                        child: Text(
                          promise,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.7,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeUp(
                        delay: const Duration(milliseconds: 80),
                        child: Text(
                          name == 'friend'
                              ? 'Bondly stays when a wave comes.'
                              : 'Bondly stays with you, $name.',
                          textAlign: TextAlign.center,
                          style: AppTypography.ui(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeUp(
                        delay: const Duration(milliseconds: 140),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _PlanCard(
                                title: 'Yearly',
                                price: '\$39.99',
                                detail: '\$3.33 / month',
                                badge: 'Save 65%',
                                selected: yearly,
                                onTap: () =>
                                    setState(() => _plan = _PayPlan.yearly),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PlanCard(
                                title: 'Monthly',
                                price: '\$9.99',
                                detail: 'billed monthly',
                                selected: !yearly,
                                onTap: () =>
                                    setState(() => _plan = _PayPlan.monthly),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeUp(
                        delay: const Duration(milliseconds: 220),
                        child: _SubscribeButton(
                          label: _busy
                              ? 'One moment…'
                              : yearly
                              ? 'Start 7 days free'
                              : 'Continue',
                          onPressed: _busy ? null : _buy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeUp(
                        delay: const Duration(milliseconds: 280),
                        child: GestureDetector(
                          onTap: () {
                            if (!_busy) _restore();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                    ],
                  ),
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
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              size: 13,
              color: Color(0xFF5B38AC),
            )
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.34),
                ),
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
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

class _TestChip extends StatelessWidget {
  const _TestChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Test',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.34),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Test',
                      style: AppTypography.ui(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
