import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import 'you_body.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

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
              const ExcludeSemantics(child: _NightSky()),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  safe.top + 8,
                  16,
                  10 + safe.bottom,
                ),
                child: const YouBody(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NightSky extends StatelessWidget {
  const _NightSky();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          BunlyYou.nightSky,
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
