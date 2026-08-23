import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Full-width scene that washes into the warm home color.
/// A cream veil, not a dissolve — the art stays sharp until the paper takes over.
class SceneHero extends StatelessWidget {
  const SceneHero({
    super.key,
    required this.asset,
    required this.aspectRatio,
  });

  final String asset;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SceneArt(asset: asset),
    );
  }
}

class SceneArt extends StatelessWidget {
  const SceneArt({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
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
                Color(0x00FDF2E6),
                Color(0x00FDF2E6),
                Color(0x40FDF2E6),
                Color(0xAAFDF2E6),
                AppColors.home,
              ],
              stops: [0.0, 0.58, 0.74, 0.88, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
