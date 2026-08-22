import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import 'talking_title.dart';

class TalkBubble extends StatefulWidget {
  const TalkBubble({
    super.key,
    required this.text,
    required this.onComplete,
    this.highlight,
    this.face = BunlyEmotions.happy,
  });

  final String text;
  final String? highlight;
  final String face;
  final VoidCallback onComplete;

  @override
  State<TalkBubble> createState() => _TalkBubbleState();
}

class _TalkBubbleState extends State<TalkBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drop;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _drop = AnimationController(vsync: this, duration: AppMotion.page);
    final curved = CurvedAnimation(parent: _drop, curve: AppMotion.curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.55),
      end: Offset.zero,
    ).animate(curved);
    _fade = curved;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _drop.value = 1;
        widget.onComplete();
        return;
      }
      _drop.forward();
    });
  }

  @override
  void dispose() {
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Image.asset(
                widget.face,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xCC3C275C),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                    bottomLeft: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: TalkingTitle(
                    text: widget.text,
                    highlight: widget.highlight,
                    fontSize: 24,
                    delay: const Duration(milliseconds: 280),
                    alignment: WrapAlignment.start,
                    color: const Color(0xE6FFFFFF),
                    emphasisColor: Colors.white,
                    shadows: const [
                      Shadow(color: Color(0x66000000), blurRadius: 8),
                    ],
                    onComplete: widget.onComplete,
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
