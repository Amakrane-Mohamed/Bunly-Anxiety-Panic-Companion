import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/theme/app_typography.dart';

/// Round Duolingo-style SOS: a hard 3D lip that sinks on press.
class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  static const _size = 56.0;
  static const _lip = 6.0;
  static const _face = Color(0xFFE85B52);
  static const _lipColor = Color(0xFFB03A4A);

  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'SOS. Help with a panic attack.',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.heavyImpact();
          AppAudio.tap();
          widget.onPressed();
        },
        child: SizedBox(
          width: _size,
          height: _size + _lip,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _lipColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _pressed ? _lip : 0,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: _face,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x44FFFFFF), Color(0x00000000)],
                              stops: [0, 0.45],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              height: 1,
                              color: Colors.white,
                              decoration: TextDecoration.none,
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
        ),
      ),
    );
  }
}
