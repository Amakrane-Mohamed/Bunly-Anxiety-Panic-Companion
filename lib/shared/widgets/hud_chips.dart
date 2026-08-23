import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class HudStatRow extends StatelessWidget {
  const HudStatRow({super.key, required this.hearts, required this.streak});

  final int hearts;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeartsChip(count: hearts),
        const SizedBox(width: 10),
        StreakChip(count: streak),
      ],
    );
  }
}

class HeartsChip extends StatelessWidget {
  const HeartsChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count of ${AppStore.heartMax} hearts',
      child: HudChip(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: count > 0 ? 1 : 0.45,
                child: const CustomPaint(
                  size: Size(18, 18),
                  painter: HeartPainter(),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Streak $count days',
      child: HudChip(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.flame_fill,
                size: 18,
                color: count > 0 ? AppColors.gold : AppColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HudChip extends StatelessWidget {
  const HudChip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE8DFD4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  const HeartPainter();

  static const _fill = Color(0xFFE56B9A);
  static const _shine = Color(0x66FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.32)
      ..cubicTo(w * 0.5, h * 0.08, w * 0.08, h * 0.08, w * 0.08, h * 0.38)
      ..cubicTo(w * 0.08, h * 0.58, w * 0.5, h * 0.82, w * 0.5, h * 0.96)
      ..cubicTo(w * 0.5, h * 0.82, w * 0.92, h * 0.58, w * 0.92, h * 0.38)
      ..cubicTo(w * 0.92, h * 0.08, w * 0.5, h * 0.08, w * 0.5, h * 0.32);

    canvas.drawPath(
      path,
      Paint()
        ..color = _fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * 0.34, h * 0.34),
      w * 0.12,
      Paint()..color = _shine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
