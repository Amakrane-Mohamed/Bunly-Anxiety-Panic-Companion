import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/layout/app_layout.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/readable_width.dart';

class HelpBackdrop extends StatelessWidget {
  const HelpBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF5A3FBE)),
        const Image(
          image: AssetImage(BunlyPanic.helpOffice),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
        child,
      ],
    );
  }
}

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ReadableWidth(
      maxWidth: AppLayout.sheetMax,
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D2B6B).withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
            ...AppColors.lift,
          ],
        ),
        child: child,
      ),
    );
  }
}

class QuietToggle extends StatelessWidget {
  const QuietToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final silent = store.silentMode;
        return Semantics(
          button: true,
          label: silent ? 'Sound on' : 'Silent mode',
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              store.setSilentMode(!silent);
              await AppAudio.syncSilent();
            },
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xF2FFFFFF),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  silent
                      ? CupertinoIcons.speaker_slash_fill
                      : CupertinoIcons.speaker_2_fill,
                  size: 20,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HelpProgress extends StatelessWidget {
  const HelpProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = total == 0 ? 0.0 : ((step + 1) / total).clamp(0.12, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.track),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: t,
                heightFactor: 1,
                child: const ColoredBox(color: AppColors.brand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
