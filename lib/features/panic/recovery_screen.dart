import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import 'help_backdrop.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, required this.episode});

  final PanicEpisode episode;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int? _intensity;
  String? _activity;
  String? _avoiding;

  static const _doing = ['Home', 'Work', 'Commute', 'Social', 'Alone', 'Other'];
  static const _avoid = [
    'A call',
    'A conversation',
    'Leaving',
    'Being judged',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppAudio.win();
    });
  }

  void _leave({bool save = true}) {
    if (save) {
      AppStore.instance.finishPanic(
        widget.episode,
        intensityAfter: _intensity,
        activity: _activity,
        avoiding: _avoiding,
      );
    } else {
      AppStore.instance.finishPanic(widget.episode);
    }
    HapticFeedback.mediumImpact();
    AppAudio.answer();
    Navigator.of(context).pop();
    NativeChrome.showRoot();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF5A3FBE),
      body: HelpBackdrop(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 8),
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: QuietToggle(),
              ),
            ),
            const Spacer(),
            HelpSheet(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.62,
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(22, 20, 22, 12 + bottom),
                  children: [
                    Text(
                      'You stayed.',
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'If you want, tell me a little. Or skip. Both count.',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const _RoomEcho(),
                    const SizedBox(height: 18),
                    Text(
                      'How intense was it?',
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++) ...[
                          if (i > 1) const SizedBox(width: 8),
                          Expanded(
                            child: _Chip(
                              label: '$i',
                              selected: _intensity == i,
                              onTap: () => setState(() => _intensity = i),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'What were you doing?',
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in _doing)
                          _Chip(
                            label: item,
                            selected: _activity == item,
                            onTap: () => setState(() => _activity = item),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'What were you trying to avoid?',
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in _avoid)
                          _Chip(
                            label: item,
                            selected: _avoiding == item,
                            onTap: () => setState(() => _avoiding = item),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    BunlyPrimaryButton(
                      label: 'Save',
                      onPressed: () => _leave(),
                    ),
                    BunlyTextButton(
                      label: 'Skip',
                      onPressed: () => _leave(save: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomEcho extends StatelessWidget {
  const _RoomEcho();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final note = store.futureNote.trim();
    final help = store.helpsMe.trim();
    final person = store.safePerson.trim();
    if (note.isEmpty && help.isEmpty && person.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From your room',
                style: AppTypography.ui(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                ),
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note,
                  style: AppTypography.ui(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.ink,
                  ),
                ),
              ],
              if (help.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Usually helps: $help',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: AppColors.ink,
                  ),
                ),
              ],
              if (person.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'You can tell $person later.',
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
        AppAudio.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.optionSelected : AppColors.optionFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.optionLine,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
