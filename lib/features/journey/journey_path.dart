import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

abstract final class JourneyPathMetrics {
  static const rowHeight = 132.0;
  static const node = 76.0;
  static const lip = 8.0;
  static const topPad = 36.0;
  static const amplitude = 0.28;

  static double sway(int index) {
    const pattern = [0.0, 1.0, 0.0, -1.0];
    return pattern[index % 4];
  }

  static double nodeX(double width, int index) {
    return width / 2 + sway(index) * width * amplitude;
  }

  static double nodeY(int index) {
    return index * rowHeight + topPad + node / 2;
  }
}

class JourneyUnitBanner extends StatelessWidget {
  const JourneyUnitBanner({
    super.key,
    required this.kicker,
    required this.title,
    required this.progress,
    this.color = AppColors.brand,
  });

  final String kicker;
  final String title;
  final String progress;
  final Color color;

  static Color _lip(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.16).clamp(0.08, 1)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final lip = _lip(color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: lip,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kicker,
                            style: AppTypography.ui(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: AppTypography.display(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          progress,
                          style: AppTypography.ui(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JourneyPathNode {
  const JourneyPathNode({
    required this.id,
    required this.title,
    required this.icon,
    required this.done,
    required this.locked,
    required this.onOpen,
    this.gold = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final bool done;
  final bool locked;
  final bool gold;
  final VoidCallback onOpen;
}

class JourneySnake extends StatelessWidget {
  const JourneySnake({
    super.key,
    required this.nodes,
    required this.pathFrom,
    required this.currentId,
  });

  final List<JourneyPathNode> nodes;
  final int pathFrom;
  final String? currentId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return CustomPaint(
          painter: _SnakePainter(
            count: nodes.length,
            width: width,
            pathFrom: pathFrom,
            done: [for (final node in nodes) node.done],
          ),
          child: Column(
            children: [
              for (var i = 0; i < nodes.length; i++)
                _Lane(
                  index: pathFrom + i,
                  width: width,
                  node: nodes[i],
                  current: nodes[i].id == currentId,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SnakePainter extends CustomPainter {
  _SnakePainter({
    required this.count,
    required this.width,
    required this.pathFrom,
    required this.done,
  });

  final int count;
  final double width;
  final int pathFrom;
  final List<bool> done;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    for (var i = 0; i < count - 1; i++) {
      final a = Offset(
        JourneyPathMetrics.nodeX(size.width, pathFrom + i),
        JourneyPathMetrics.nodeY(i),
      );
      final b = Offset(
        JourneyPathMetrics.nodeX(size.width, pathFrom + i + 1),
        JourneyPathMetrics.nodeY(i + 1),
      );
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
      final lit = done[i];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = lit
            ? AppColors.brand.withValues(alpha: 0.55)
            : const Color(0xFFD9CBB3);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.width != width ||
        oldDelegate.pathFrom != pathFrom ||
        oldDelegate.done != done;
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.index,
    required this.width,
    required this.node,
    required this.current,
  });

  final int index;
  final double width;
  final JourneyPathNode node;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final cx = JourneyPathMetrics.nodeX(width, index);
    final sway = JourneyPathMetrics.sway(index);
    final bondlyLeft = sway > 0;
    const bondlyW = 92.0;

    return SizedBox(
      height: JourneyPathMetrics.rowHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (current && !node.done)
            Positioned(
              left: cx - 48,
              top: 0,
              width: 96,
              child: const _StartBubble(),
            ),
          Positioned(
            left: cx - JourneyPathMetrics.node / 2,
            top: JourneyPathMetrics.topPad,
            child: _NodeButton(
              node: node,
              current: current,
            ),
          ),
          if (current)
            Positioned(
              left: bondlyLeft
                  ? cx - JourneyPathMetrics.node / 2 - bondlyW + 6
                  : cx + JourneyPathMetrics.node / 2 - 6,
              top: JourneyPathMetrics.topPad - 18,
              child: IgnorePointer(
                child: _BondlyGuide(
                  art: node.done ? BunlyPoses.proud : BunlyPoses.jumping,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeButton extends StatefulWidget {
  const _NodeButton({required this.node, required this.current});

  final JourneyPathNode node;
  final bool current;

  @override
  State<_NodeButton> createState() => _NodeButtonState();
}

class _NodeButtonState extends State<_NodeButton>
    with SingleTickerProviderStateMixin {
  var _pressed = false;
  AnimationController? _pulse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.current && !widget.node.done) _startPulse();
  }

  @override
  void didUpdateWidget(_NodeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current && !widget.node.done) {
      _startPulse();
    } else {
      _pulse?.stop();
    }
  }

  void _startPulse() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _pulse ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (_pulse?.isAnimating != true) {
      _pulse!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  Color get _fill {
    if (widget.node.locked) return const Color(0xFFE6D9C4);
    if (widget.node.gold && !widget.node.done) return AppColors.gold;
    if (widget.node.done || widget.current) return AppColors.brand;
    return AppColors.brandHi;
  }

  Color get _lip {
    if (widget.node.locked) return const Color(0xFFC9B48F);
    if (widget.node.gold && !widget.node.done) return const Color(0xFFC9841C);
    return AppColors.brandLo;
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final size = JourneyPathMetrics.node;
    final lip = JourneyPathMetrics.lip;
    final fill = _fill;
    final canOpen = !node.locked;
    final pulse = _pulse;

    Widget button = Semantics(
      button: true,
      enabled: canOpen,
      selected: widget.current,
      label: [
        node.title,
        if (node.done) 'done',
        if (node.locked) 'locked',
        if (widget.current && !node.done) 'current',
      ].join(', '),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: canOpen ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          AppAudio.tap();
          if (node.locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Finish the one above first. Bondly is petty like that.',
                ),
              ),
            );
            return;
          }
          node.onOpen();
        },
        child: SizedBox(
          width: size,
          height: size + lip,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: lip,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: _lip, shape: BoxShape.circle),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  top: _pressed ? lip : 0,
                  bottom: _pressed ? 0 : lip,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: widget.current && !node.done
                        ? Border.all(color: Colors.white, width: 3.5)
                        : null,
                    boxShadow: widget.current
                        ? [
                            BoxShadow(
                              color: fill.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      node.locked
                          ? CupertinoIcons.lock_fill
                          : node.done
                          ? Icons.check_rounded
                          : node.icon,
                      size: node.done ? 34 : 28,
                      color: node.locked
                          ? const Color(0xFF8A7A62)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (pulse != null && widget.current && !node.done) {
      button = AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(pulse.value);
          return Transform.scale(scale: 1 + t * 0.05, child: child);
        },
        child: button,
      );
    }

    return button;
  }
}

class _StartBubble extends StatefulWidget {
  const _StartBubble();

  @override
  State<_StartBubble> createState() => _StartBubbleState();
}

class _StartBubbleState extends State<_StartBubble>
    with SingleTickerProviderStateMixin {
  AnimationController? _bob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      _bob = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bob?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bob = _bob;
    Widget bubble = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'START',
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.brand,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _BubbleTailPainter(),
        ),
      ],
    );

    if (bob != null) {
      bubble = AnimatedBuilder(
        animation: bob,
        builder: (context, child) {
          final t = math.sin(bob.value * math.pi);
          return Transform.translate(offset: Offset(0, t * -5), child: child);
        },
        child: bubble,
      );
    }

    return bubble;
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2 - 6, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 6, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BondlyGuide extends StatefulWidget {
  const _BondlyGuide({required this.art});

  final String art;

  @override
  State<_BondlyGuide> createState() => _BondlyGuideState();
}

class _BondlyGuideState extends State<_BondlyGuide>
    with SingleTickerProviderStateMixin {
  AnimationController? _bob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      _bob = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bob?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bob = _bob;
    Widget mascot = Image.asset(
      widget.art,
      width: 92,
      height: 92,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
    if (bob != null) {
      mascot = AnimatedBuilder(
        animation: bob,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(bob.value);
          return Transform.translate(offset: Offset(0, t * -8), child: child);
        },
        child: mascot,
      );
    }
    return mascot;
  }
}
