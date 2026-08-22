import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/fade_up.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, required this.episode});

  final PanicEpisode episode;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int? _intensity;

  void _leave({int? intensity}) {
    AppStore.instance.finishPanic(widget.episode, intensityAfter: intensity);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    NativeChrome.showRoot();
  }

  void _finish() => _leave(intensity: _intensity);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 12 + bottom),
          child: Column(
            children: [
              FadeUp(
                child: Image.asset(
                  BunlyPanic.recovery,
                  height: 140,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 16),
              FadeUp(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'You made it through.',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeUp(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Staying with it is the win. How heavy does it feel now?',
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeUp(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  children: [
                    for (var i = 1; i <= 5; i++) ...[
                      if (i > 1) const SizedBox(width: 8),
                      Expanded(
                        child: _IntensityChip(
                          value: i,
                          selected: _intensity == i,
                          onTap: () => setState(() => _intensity = i),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              BunlyPrimaryButton(
                label: 'I’m okay enough',
                onPressed: _intensity == null ? null : _finish,
              ),
              BunlyTextButton(
                label: 'Skip for now',
                onPressed: () => _leave(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityChip extends StatelessWidget {
  const _IntensityChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.optionFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$value',
          style: AppTypography.ui(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
