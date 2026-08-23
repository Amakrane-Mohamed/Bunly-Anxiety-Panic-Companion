import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class BunlyPrimaryButton extends StatefulWidget {
  const BunlyPrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<BunlyPrimaryButton> createState() => _BunlyPrimaryButtonState();
}

class _BunlyPrimaryButtonState extends State<BunlyPrimaryButton> {
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
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: enabled ? 1 : 0.38,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.brandHi, AppColors.brand],
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: AppColors.brand.withValues(
                            alpha: _pressed ? 0.16 : 0.30,
                          ),
                          blurRadius: _pressed ? 10 : 22,
                          offset: Offset(0, _pressed ? 4 : 10),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                        stops: [0, 0.45],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.label,
                      style: AppTypography.ui(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: AppColors.onBrand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BunlyTextButton extends StatelessWidget {
  const BunlyTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class RescueButton extends StatefulWidget {
  const RescueButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<RescueButton> createState() => _RescueButtonState();
}

class _RescueButtonState extends State<RescueButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'I need help now',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.heavyImpact();
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Opacity(
                opacity: 0.9 + (_pulse.value * 0.1),
                child: child,
              );
            },
            child: Container(
              height: 64,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.sos, AppColors.sosDeep, AppColors.brandLo],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sos.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'I need help now',
                style: AppTypography.ui(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
