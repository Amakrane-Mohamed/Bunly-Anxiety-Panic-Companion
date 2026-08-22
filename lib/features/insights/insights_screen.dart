import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final now = DateTime.now();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                'Patterns, not predictions.',
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'This month',
                      value: '${store.panicThisMonth}',
                      hint: 'moments you met',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Metric(
                      label: 'Check-ins',
                      value: '${store.checkIns.length}',
                      hint: 'days named',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _monthName(now.month),
                style: AppTypography.ui(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              _MonthGrid(month: now, onDay: (day) => _openDay(context, day)),
              const SizedBox(height: 18),
              Text(
                store.insight,
                style: AppTypography.ui(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDay(BuildContext context, DateTime day) {
    final store = AppStore.instance;
    final panic = store.hasPanicOn(day);
    final check = store.hasCheckInOn(day);
    HapticFeedback.selectionClick();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            '${day.day} ${_monthName(day.month)}',
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          message: Text(
            panic && check
                ? 'You checked in, and you stayed with a moment.'
                : panic
                ? 'You stayed with a moment this day.'
                : check
                ? 'You checked in this day.'
                : 'Nothing logged this day yet.',
            style: AppTypography.ui(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.inkMuted,
            ),
          ),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        );
      },
    );
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.hint});

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.optionFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.display(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.brand,
            ),
          ),
          Text(
            hint,
            style: AppTypography.ui(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.onDay});

  final DateTime month;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = first.weekday % 7;

    return Column(
      children: [
        Row(
          children: [
            for (final label in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final index = row * 7 + col - startOffset + 1;
                        if (index < 1 || index > daysInMonth) {
                          return const SizedBox(height: 36);
                        }
                        final day = DateTime(month.year, month.month, index);
                        final panic = store.hasPanicOn(day);
                        final check = store.hasCheckInOn(day);
                        return GestureDetector(
                          onTap: () => onDay(day),
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: panic
                                  ? AppColors.brand.withValues(alpha: 0.16)
                                  : check
                                  ? AppColors.optionSelected
                                  : Colors.transparent,
                            ),
                            child: Text(
                              '$index',
                              style: AppTypography.ui(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: panic ? AppColors.brand : AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
