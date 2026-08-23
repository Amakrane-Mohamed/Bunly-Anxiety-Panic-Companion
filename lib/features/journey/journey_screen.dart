import 'package:flutter/material.dart';

import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import 'journey_body.dart';
import 'journey_look.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

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
              const JourneyBackdrop(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  safe.top + 8,
                  16,
                  10 + safe.bottom,
                ),
                child: const JourneyBody(),
              ),
            ],
          ),
        );
      },
    );
  }
}
