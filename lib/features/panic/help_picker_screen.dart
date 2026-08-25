import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../legal/crisis_sheet.dart';
import '../onboarding/widgets/onboarding_option_tile.dart';
import 'guide_beats.dart';
import 'guide_screen.dart';
import 'help_backdrop.dart';

class HelpPickerScreen extends StatelessWidget {
  const HelpPickerScreen({super.key});

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
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12 + bottom),
                  children: [
                    Text(
                      'What do you need?',
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
                      'Pick one. I’ll meet you there.',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final topic in HelpMenu.topics)
                      OnboardingOptionTile(
                        label: topic.label,
                        selected: false,
                        onTap: () {
                          PanicEpisode? episode;
                          if (topic.tracksPanic) {
                            episode = AppStore.instance.startPanic(
                              comingOn: false,
                            );
                          }
                          Navigator.of(context).pushReplacement(
                            AppMotion.fadeTo(
                              GuideScreen(
                                beats: topic.tracksPanic
                                    ? GuideBooks.withPersonal(
                                        topic.beats,
                                        note: AppStore.instance.futureNote,
                                        help: AppStore.instance.helpsMe,
                                      )
                                    : topic.beats,
                                episode: episode,
                                recover: topic.tracksPanic,
                              ),
                            ),
                          );
                        },
                      ),
                    BunlyTextButton(
                      label: 'If this is an emergency',
                      onPressed: () => CrisisSheet.open(context),
                    ),
                    BunlyTextButton(
                      label: 'Not now',
                      onPressed: () => Navigator.of(context).maybePop(),
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
