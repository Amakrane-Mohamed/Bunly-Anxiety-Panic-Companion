import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';
import 'journey_content.dart';

class JourneyLifeScreen extends StatefulWidget {
  const JourneyLifeScreen({super.key});

  @override
  State<JourneyLifeScreen> createState() => _JourneyLifeScreenState();
}

class _JourneyLifeScreenState extends State<JourneyLifeScreen> {
  String? _pick;
  var _step = 0;

  LifeInch? get _inch {
    final id = _pick;
    if (id == null) return null;
    return JourneyContent.inchById(id);
  }

  void _choose(String id) {
    HapticFeedback.selectionClick();
    AppAudio.tap();
    setState(() {
      _pick = id;
      _step = 0;
    });
  }

  void _doStep() {
    final inch = _inch;
    if (inch == null) return;
    AppAudio.tap();
    HapticFeedback.mediumImpact();
    if (_step + 1 >= inch.steps.length) {
      AppStore.instance.markJourneyLife(inch.id);
      AppAudio.win();
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step += 1);
  }

  @override
  Widget build(BuildContext context) {
    final inch = _inch;

    return BunlyScaffold(
      title: 'One inch of life',
      bottom: inch == null
          ? null
          : BunlyPrimaryButton(
              label: _step + 1 >= inch.steps.length
                  ? 'I did this'
                  : 'I did this step',
              onPressed: _doStep,
            ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: inch == null ? _picker() : _task(inch),
      ),
    );
  }

  Widget _picker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reclaim one inch you dropped because of the next-wave fear.',
          style: AppTypography.ui(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < JourneyContent.inches.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                Expanded(
                  child: _InchTile(
                    inch: JourneyContent.inches[i],
                    onTap: () => _choose(JourneyContent.inches[i].id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _task(LifeInch inch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          inch.title,
          style: AppTypography.display(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          inch.hint,
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
              for (var i = 0; i < inch.steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Expanded(
                  child: _StepCard(
                    index: i,
                    text: inch.steps[i],
                    state: i < _step
                        ? _StepState.done
                        : i == _step
                        ? _StepState.now
                        : _StepState.wait,
                  ),
                ),
              ],
            ],
          ),
        ),
        BunlyTextButton(
          label: 'Pick a different inch',
          onPressed: () => setState(() {
            _pick = null;
            _step = 0;
          }),
        ),
      ],
    );
  }
}

class _InchTile extends StatefulWidget {
  const _InchTile({required this.inch, required this.onTap});

  final LifeInch inch;
  final VoidCallback onTap;

  @override
  State<_InchTile> createState() => _InchTileState();
}

class _InchTileState extends State<_InchTile> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 80),
        child: BunlyCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(widget.inch.icon, size: 18, color: AppColors.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.inch.title,
                        style: AppTypography.ui(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        widget.inch.hint,
                        style: AppTypography.ui(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _StepState { wait, now, done }

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.text,
    required this.state,
  });

  final int index;
  final String text;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final now = state == _StepState.now;
    final done = state == _StepState.done;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: state == _StepState.wait ? 0.4 : 1,
      child: BunlyCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.brand : AppColors.optionFill,
                  border: Border.all(
                    color: now ? AppColors.brand : AppColors.optionLine,
                    width: now ? 2 : 1,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: AppTypography.ui(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: now ? AppColors.brand : AppColors.inkMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.ui(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
