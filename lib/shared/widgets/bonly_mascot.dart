import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

enum BonlyMood { calm, worried, guiding, proud, sleepy, explorer }

class BonlyMascot extends StatelessWidget {
  const BonlyMascot({
    super.key,
    required this.mood,
    this.height = 140,
  });

  final BonlyMood mood;
  final double height;

  String get asset {
    return switch (mood) {
      BonlyMood.calm => BunlyPoses.sitting,
      BonlyMood.worried => BunlyActivities.worried,
      BonlyMood.guiding => BunlyPanic.readyToHelp,
      BonlyMood.proud => BunlyPoses.proud,
      BonlyMood.sleepy => BunlyToday.sleeping,
      BonlyMood.explorer => BunlyJourney.pathAhead,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
