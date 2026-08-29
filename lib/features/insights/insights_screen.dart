import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/readable_width.dart';
import 'insights_body.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final safe = MediaQuery.paddingOf(context);

        return ColoredBox(
          color: AppColors.home,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ExcludeSemantics(child: _Horizon()),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  safe.top + 8,
                  16,
                  10 + safe.bottom,
                ),
                child: const ReadableWidth(child: InsightsBody()),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sunset stays visible under the HUD and heatmap; cream takes over near the tab bar.
class _Horizon extends StatelessWidget {
  const _Horizon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          BunlyInsights.horizon,
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
                Color(0x14FDF2E6),
                Color(0x66FDF2E6),
                Color(0xCCFDF2E6),
                AppColors.home,
              ],
              stops: [0.0, 0.28, 0.55, 0.82, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
