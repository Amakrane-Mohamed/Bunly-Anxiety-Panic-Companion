import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/scene_hero.dart';
import 'you_body.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  static const _skyAspect = 1.28;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        return ColoredBox(
          color: AppColors.home,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AspectRatio(
                aspectRatio: _skyAspect,
                child: _YouHero(),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: const [YouBody()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _YouHero extends StatelessWidget {
  const _YouHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ExcludeSemantics(child: SceneArt(asset: BunlyYou.nightSky)),
        Align(
          alignment: const Alignment(0, 0.78),
          child: Image.asset(
            BunlyPoses.sitting,
            height: 108,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}
