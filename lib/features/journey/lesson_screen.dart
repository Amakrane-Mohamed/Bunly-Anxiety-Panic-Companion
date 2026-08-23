import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/bunly_scaffold.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
    required this.takeaway,
  });

  final int index;
  final String title;
  final String takeaway;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  var _picked = false;

  void _complete() {
    AppStore.instance.completeLesson(widget.index);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BunlyScaffold(
      title: 'Journey',
      bottom: BunlyPrimaryButton(
        label: 'Mark as walked',
        onPressed: _picked ? _complete : null,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson ${widget.index + 1}',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: AppTypography.display(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                _picked
                    ? (widget.index >= 5
                          ? BunlyJourney.graduation
                          : BunlyJourney.milestone)
                    : widget.index == 0
                    ? BunlyJourney.firstStep
                    : BunlyJourney.encouragement,
                height: 120,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.takeaway,
              style: AppTypography.ui(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Does this land for you?',
              style: AppTypography.ui(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            _Pick(
              label: 'Yes — I needed this named',
              selected: _picked,
              onTap: () => setState(() => _picked = true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelected : AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.optionLine,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.ui(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
