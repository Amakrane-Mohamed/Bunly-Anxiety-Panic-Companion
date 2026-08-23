import 'package:flutter/material.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'journey_catalog.dart';
import 'journey_look.dart';

class JourneyReadScreen extends StatefulWidget {
  const JourneyReadScreen({
    super.key,
    required this.title,
    required this.pages,
    this.claimId,
    this.lessonId,
  });

  final String title;
  final List<JourneyLessonPage> pages;
  final String? claimId;
  final String? lessonId;

  @override
  State<JourneyReadScreen> createState() => _JourneyReadScreenState();
}

class _JourneyReadScreenState extends State<JourneyReadScreen> {
  var _page = 0;

  void _next() {
    if (_page < widget.pages.length - 1) {
      AppAudio.answer();
      setState(() => _page += 1);
      return;
    }
    final lessonId = widget.lessonId;
    if (lessonId != null) {
      AppStore.instance.markLessonRead(lessonId);
    }
    final claimId = widget.claimId;
    if (claimId != null) {
      AppStore.instance.markJourneyClaim(claimId);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_page];
    final last = _page >= widget.pages.length - 1;
    final total = widget.pages.length;
    final safe = MediaQuery.paddingOf(context);
    final art = last ? BunlyPoses.proud : BunlyJourney.firstStep;

    return ColoredBox(
      color: AppColors.home,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const JourneyBackdrop(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, safe.top + 8, 16, 10 + safe.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JourneyBackButton(),
                const SizedBox(height: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0.06),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: ListView(
                      key: ValueKey(_page),
                      padding: EdgeInsets.zero,
                      children: [
                        JourneyBrandCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    AppAssets.bunlyIcon,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: AppTypography.ui(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_page + 1} of $total',
                                        style: AppTypography.ui(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brand,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Read this. Then Next.',
                                        style: AppTypography.ui(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const JourneySectionLabel('This step'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: JourneyBrandCard(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    art,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          page.title,
                                          style: AppTypography.ui(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          page.body,
                                          style: AppTypography.ui(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                            color: AppColors.ink,
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
                        JourneyPickRow(
                          title: last ? 'That’s the read' : 'Continue',
                          subtitle: last
                              ? 'Stamp it. Then we go home.'
                              : 'When you’re ready.',
                          art: art,
                          chipLabel: last ? 'Done' : 'Next',
                          onPick: _next,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
