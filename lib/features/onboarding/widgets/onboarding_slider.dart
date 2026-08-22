import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingSlider extends StatefulWidget {
  const OnboardingSlider({
    super.key,
    required this.value,
    required this.marks,
    required this.lowLabel,
    required this.highLabel,
    required this.onChanged,
  });

  final double value;
  final List<String> marks;
  final String lowLabel;
  final String highLabel;
  final ValueChanged<double> onChanged;

  @override
  State<OnboardingSlider> createState() => _OnboardingSliderState();
}

class _OnboardingSliderState extends State<OnboardingSlider> {
  static const _thumb = 40.0;
  final _trackKey = GlobalKey();
  var _dragging = false;

  void _setFromGlobal(Offset global, {required bool snap}) {
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final dx = box.globalToLocal(global).dx;
    var t = (dx / box.size.width).clamp(0.0, 1.0);
    if (snap) {
      final last = (widget.marks.length - 1).clamp(1, 100);
      t = (t * last).round() / last;
    }
    if ((t - widget.value).abs() < 0.0001) return;
    if (snap) HapticFeedback.selectionClick();
    widget.onChanged(t);
  }

  void _snap() {
    final last = (widget.marks.length - 1).clamp(1, 100);
    final t = (widget.value * last).round() / last;
    if ((t - widget.value).abs() < 0.0001) return;
    HapticFeedback.selectionClick();
    widget.onChanged(t);
  }

  String get _label {
    final last = (widget.marks.length - 1).clamp(1, 100);
    final i = (widget.value * last).round().clamp(0, widget.marks.length - 1);
    return widget.marks[i];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final travel = (width - _thumb).clamp(0.0, width);
        final x = widget.value * travel;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 108,
              width: width,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) {
                  setState(() => _dragging = true);
                  _setFromGlobal(d.globalPosition, snap: false);
                },
                onPanUpdate: (d) =>
                    _setFromGlobal(d.globalPosition, snap: false),
                onPanEnd: (_) {
                  setState(() => _dragging = false);
                  _snap();
                },
                onPanCancel: () => setState(() => _dragging = false),
                onTapUp: (d) {
                  _setFromGlobal(d.globalPosition, snap: true);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      key: _trackKey,
                      left: _thumb / 2,
                      right: _thumb / 2,
                      top: 62,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD9CDEF), AppColors.brandHi],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand.withValues(alpha: 0.16),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: x,
                      top: 47,
                      child: AnimatedScale(
                        scale: _dragging ? 1.08 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          width: _thumb,
                          height: _thumb,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFFFFF), Color(0xFFF6F1FC)],
                            ),
                            border: Border.all(
                              color: AppColors.brand,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withValues(alpha: 0.22),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (x + _thumb / 2 - 58).clamp(0, width - 116),
                      top: 0,
                      child: _Callout(text: _label, compact: _dragging),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.lowLabel,
                  style: AppTypography.ui(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  widget.highLabel,
                  style: AppTypography.ui(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.text, required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: compact ? 1.05 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: 116,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.lift,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.ui(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
