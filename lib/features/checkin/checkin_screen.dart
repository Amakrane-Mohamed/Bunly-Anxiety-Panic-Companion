import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  var _step = 0;
  int? _mood;
  int? _stress;

  List<(String, String)> get _prompts {
    final rotate = DateTime.now().weekday % 2 == 0;
    return rotate
        ? [
            ('How does the day feel?', 'mood'),
            ('How loud is the worry right now?', 'stress'),
          ]
        : [
            ('What’s your mood in this moment?', 'mood'),
            ('How heavy is the stress?', 'stress'),
          ];
  }

  void _next() {
    if (_step == 0 && _mood != null) {
      setState(() => _step = 1);
      return;
    }
    if (_mood != null && _stress != null) {
      AppStore.instance.addCheckIn(mood: _mood!, stress: _stress!);
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[_step];
    final selected = _step == 0 ? _mood : _stress;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt.$1,
                style: AppTypography.display(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick what fits. There’s no right number.',
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 1; i <= 5; i++)
                    _MoodChip(
                      value: i,
                      selected: selected == i,
                      onTap: () => setState(() {
                        if (_step == 0) {
                          _mood = i;
                        } else {
                          _stress = i;
                        }
                      }),
                    ),
                ],
              ),
              const Spacer(),
              BunlyPrimaryButton(
                label: _step == 0 ? 'Continue' : 'Save check-in',
                onPressed: selected == null ? null : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  static const _labels = ['Very low', 'Low', 'Okay', 'High', 'Very high'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelected : AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.optionLine,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTypography.ui(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[value - 1],
              style: AppTypography.ui(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
