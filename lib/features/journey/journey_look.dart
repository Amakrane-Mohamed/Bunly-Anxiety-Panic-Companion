import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Night path + cream wash — the Journey home backdrop.
class JourneyBackdrop extends StatelessWidget {
  const JourneyBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(child: _PathNight()),
      ],
    );
  }
}

class _PathNight extends StatelessWidget {
  const _PathNight();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          BunlyJourney.pathNight,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xE6FDF2E6),
                Color(0xB3FDF2E6),
                Color(0x99FDF2E6),
                Color(0xE6FDF2E6),
                AppColors.home,
              ],
              stops: [0.0, 0.18, 0.42, 0.72, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class JourneyBrandCard extends StatelessWidget {
  const JourneyBrandCard({super.key, required this.child, this.claimed = false});

  final Widget child;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: claimed ? const Color(0xFFE7DFF8) : const Color(0xFFFDF6EC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: claimed ? AppColors.brand : const Color(0xFFDCC9A8),
          width: claimed ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: claimed ? 0.16 : 0.08),
            blurRadius: claimed ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class JourneySectionLabel extends StatelessWidget {
  const JourneySectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF2FDF2E6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            text,
            style: AppTypography.ui(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class JourneyClaimChip extends StatelessWidget {
  const JourneyClaimChip({super.key, this.label = 'Claim'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.ui(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class JourneyStampCheck extends StatefulWidget {
  const JourneyStampCheck({
    super.key,
    required this.claimed,
    required this.celebrate,
  });

  final bool claimed;
  final bool celebrate;

  @override
  State<JourneyStampCheck> createState() => _JourneyStampCheckState();
}

class _JourneyStampCheckState extends State<JourneyStampCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    if (widget.claimed) _pop.value = 1;
  }

  @override
  void didUpdateWidget(JourneyStampCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _pop
        ..value = 0
        ..forward();
    } else if (widget.claimed && _pop.value == 0) {
      _pop.forward();
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimed = widget.claimed;

    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final t = Curves.elasticOut.transform(_pop.value.clamp(0.0, 1.0));
        return Transform.scale(
          scale: claimed ? 0.86 + (t * 0.14) : 1,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: claimed ? AppColors.brand : const Color(0xFFFDF2E6),
          border: Border.all(
            color: claimed
                ? AppColors.brand
                : AppColors.ink.withValues(alpha: 0.28),
            width: 2,
          ),
        ),
        child: claimed
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class JourneyClaimRow extends StatefulWidget {
  const JourneyClaimRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.claimed,
    required this.onClaim,
    this.meta,
    this.celebrate = false,
    this.enabled = true,
    this.chipLabel = 'Claim',
  });

  final String title;
  final String subtitle;
  final String? meta;
  final String art;
  final bool claimed;
  final bool celebrate;
  final bool enabled;
  final String chipLabel;
  final VoidCallback onClaim;

  @override
  State<JourneyClaimRow> createState() => _JourneyClaimRowState();
}

class _JourneyClaimRowState extends State<JourneyClaimRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.enabled && !widget.claimed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: GestureDetector(
          onTapDown: canTap ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: canTap
              ? (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.selectionClick();
                  AppAudio.tap();
                  widget.onClaim();
                }
              : null,
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: const Duration(milliseconds: 80),
            child: JourneyBrandCard(
              claimed: widget.claimed,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    JourneyStampCheck(
                      claimed: widget.claimed,
                      celebrate: widget.celebrate,
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      widget.claimed ? BunlyPoses.proud : widget.art,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.claimed
                                ? 'Done · ${widget.title}'
                                : widget.title,
                            style: AppTypography.ui(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.claimed
                                ? 'Claimed. You may take a bow. A small one.'
                                : widget.subtitle,
                            style: AppTypography.ui(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: AppColors.ink,
                            ),
                          ),
                          if (!widget.claimed && widget.meta != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.meta!,
                              style: AppTypography.ui(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brand,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!widget.claimed)
                      JourneyClaimChip(label: widget.chipLabel),
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

/// Same cream card as home, but it is a pick — not a claim.
/// Sinks on press, stamps on select, never says Claim.
class JourneyPickRow extends StatefulWidget {
  const JourneyPickRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.onPick,
    this.selected = false,
    this.dimmed = false,
    this.enabled = true,
    this.chipLabel = 'This one',
  });

  final String title;
  final String subtitle;
  final String art;
  final bool selected;
  final bool dimmed;
  final bool enabled;
  final String chipLabel;
  final VoidCallback onPick;

  @override
  State<JourneyPickRow> createState() => _JourneyPickRowState();
}

class _JourneyPickRowState extends State<JourneyPickRow> {
  static const _lip = 6.0;
  var _pressed = false;

  bool get _sunk => _pressed || widget.selected;
  bool get _canTap => widget.enabled && !widget.selected && !widget.dimmed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: widget.dimmed ? 0.42 : 1,
        child: GestureDetector(
          onTapDown: _canTap
              ? (_) {
                  setState(() => _pressed = true);
                  HapticFeedback.selectionClick();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: _canTap
              ? (_) {
                  HapticFeedback.mediumImpact();
                  AppAudio.tap();
                  widget.onPick();
                }
              : null,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: _lip,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? AppColors.brandLo
                        : const Color(0xFFC9B089),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  top: _sunk ? _lip : 0,
                  bottom: _sunk ? 0 : _lip,
                ),
                child: JourneyBrandCard(
                  claimed: widget.selected,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Row(
                      children: [
                        JourneyStampCheck(
                          claimed: widget.selected,
                          celebrate: widget.selected,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          widget.art,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTypography.ui(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.selected
                                    ? 'That’s the one.'
                                    : widget.subtitle,
                                style: AppTypography.ui(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!widget.selected)
                          IgnorePointer(
                            child: JourneyClaimChip(label: widget.chipLabel),
                          ),
                      ],
                    ),
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

class JourneyBackButton extends StatelessWidget {
  const JourneyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xF2FDF6EC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.chevron_back,
            size: 20,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
