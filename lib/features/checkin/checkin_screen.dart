import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/bunly_scaffold.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, this.slot});

  final CheckInSlot? slot;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  var _step = 0;
  int? _mood;
  int? _stress;

  CheckInSlot get _slot => widget.slot ?? AppStore.slotFor(DateTime.now());

  String get _title =>
      _slot == CheckInSlot.evening ? 'Evening check-in' : 'Morning check-in';

  String get _prompt {
    if (_step == 0) {
      return _slot == CheckInSlot.evening
          ? 'How does the evening feel?'
          : 'How does this morning feel?';
    }
    return 'How loud is the worry right now?';
  }

  List<String> get _labels {
    return _step == 0
        ? ['Very low', 'Low', 'Okay', 'Good', 'Light']
        : ['Quiet', 'Mild', 'Medium', 'Loud', 'Very loud'];
  }

  void _next() {
    if (_step == 0 && _mood != null) {
      setState(() => _step = 1);
      return;
    }
    if (_mood != null && _stress != null) {
      AppStore.instance.addCheckIn(
        mood: _mood!,
        stress: _stress!,
        slot: _slot,
      );
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _step == 0 ? _mood : _stress;

    return BunlyScaffold(
      title: _title,
      bottom: BunlyPrimaryButton(
        label: _step == 0 ? 'Continue' : 'Save check-in',
        onPressed: selected == null ? null : _next,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                _step == 0 ? BunlyPoses.sitting : BunlyActivities.thinking,
                height: 108,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _prompt,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick what fits. There’s no right number.',
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Column(
                children: [
                  for (var i = 1; i <= 5; i++) ...[
                    if (i > 1) const SizedBox(height: 8),
                    Expanded(
                      child: _MoodRow(
                        value: i,
                        label: _labels[i - 1],
                        selected: selected == i,
                        onTap: () => setState(() {
                          if (_step == 0) {
                            _mood = i;
                          } else {
                            _stress = i;
                          }
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final String label;
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelected : AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.optionLine,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$value',
                style: AppTypography.ui(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.brand : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.ui(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.brand,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
