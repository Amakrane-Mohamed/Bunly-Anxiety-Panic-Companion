import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../convert/paywall_screen.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import 'account_screen.dart';
import 'widget_studio_screen.dart';
import 'you_look.dart';

class YouBody extends StatefulWidget {
  const YouBody({super.key});

  @override
  State<YouBody> createState() => _YouBodyState();
}

class _YouBodyState extends State<YouBody> {
  static const _weekday = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late final PageController _faces;
  var _face = 0;

  @override
  void initState() {
    super.initState();
    _faces = PageController(viewportFraction: 0.74);
  }

  @override
  void dispose() {
    _faces.dispose();
    super.dispose();
  }

  Future<void> _writeThanks() async {
    final next = await YouWriteSheet.open(
      context,
      title: 'A thanks',
      hint: 'Something that was okay. Or kind. Or yours.',
      lines: 4,
      saveLabel: 'Keep it',
    );
    if (next == null || next.trim().isEmpty) return;
    AppStore.instance.addThanks(next);
    AppAudio.win();
    HapticFeedback.mediumImpact();
  }

  Future<void> _openThanks(ThanksNote note) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.home,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _when(note.at),
                  style: AppTypography.ui(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.text,
                  style: AppTypography.ui(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    AppAudio.tap();
                    Navigator.of(context).pop(false);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Keep it',
                        textAlign: TextAlign.center,
                        style: AppTypography.ui(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    AppAudio.tap();
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Let this one go',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (remove == true) AppStore.instance.removeThanks(note.id);
  }

  Future<void> _openFace(YouFace face) async {
    HapticFeedback.selectionClick();
    AppAudio.tap();
    if (!Access.instance.unlocked) {
      await PaywallScreen.require(context);
      return;
    }
    final thanks = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: face.name,
      barrierColor: kYouNight.withValues(alpha: 0.72),
      pageBuilder: (context, _, _) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: YouGlow(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    YouCardArt(face: face, height: 420),
                    const SizedBox(height: 16),
                    Text(
                      face.name,
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      face.line,
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    if (face.thanksHint) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Text(
                              'Write a thanks',
                              style: AppTypography.ui(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (thanks == true && mounted) await _writeThanks();
  }

  Future<void> _editFutureNote() async {
    final next = await YouWriteSheet.open(
      context,
      title: 'A line for later-you',
      hint: 'If a wave comes…',
      lines: 4,
      value: AppStore.instance.futureNote,
    );
    if (next == null) return;
    AppStore.instance.setFutureNote(next);
  }

  Future<void> _editHelps() async {
    final next = await YouWriteSheet.open(
      context,
      title: 'What usually helps',
      hint: 'Cold water. A window. Naming five things.',
      lines: 3,
      value: AppStore.instance.helpsMe,
    );
    if (next == null) return;
    AppStore.instance.setHelpsMe(next);
  }

  Future<void> _editPerson() async {
    final next = await YouWriteSheet.open(
      context,
      title: 'Someone who can know',
      hint: 'A name',
      lines: 1,
      value: AppStore.instance.safePerson,
    );
    if (next == null) return;
    AppStore.instance.setSafePerson(next);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppStore.instance, Access.instance]),
      builder: (context, _) {
        final store = AppStore.instance;
        final locked = !Access.instance.unlocked;
        final thanks = store.thanksNotes;
        final face = YouFace.all[_face];
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        final pageW = MediaQuery.sizeOf(context).width - 40;
        final cardH = (pageW * 0.74 * 444 / 322).clamp(260.0, 340.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your space',
              style: AppTypography.display(fontSize: 28, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              'Thanks live here. Panic notes too.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: cardH,
              child: PageView.builder(
                controller: _faces,
                itemCount: YouFace.all.length,
                onPageChanged: (index) => setState(() => _face = index),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _faces,
                    builder: (context, child) {
                      var scale = 1.0;
                      if (_faces.hasClients && !reduceMotion) {
                        final page = _faces.page ?? _face.toDouble();
                        scale = (1 - ((page - index).abs() * 0.08)).clamp(
                          0.9,
                          1,
                        );
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GestureDetector(
                      onTap: () => _openFace(YouFace.all[index]),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                        child: YouCardArt(
                          face: YouFace.all[index],
                          locked: locked,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              face.name,
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              face.line,
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < YouFace.all.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _face
                            ? AppColors.brand
                            : AppColors.brand.withValues(alpha: 0.22),
                      ),
                      child: SizedBox(
                        width: i == _face ? 8 : 6,
                        height: i == _face ? 8 : 6,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thanks',
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _writeThanks,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Write one',
                            style: AppTypography.ui(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (thanks.isEmpty)
              BunlyCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    children: [
                      Image.asset(
                        BunlyActivities.gifting,
                        width: 52,
                        height: 52,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The shelf is empty. That’s allowed. One true thing is enough.',
                          style: AppTypography.ui(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < thanks.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    YouNoteCard(
                      text: thanks[i].text,
                      when: _when(thanks[i].at),
                      onOpen: () => _openThanks(thanks[i]),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 22),
            Text(
              'If a wave comes',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            YouKitTile(
              title: store.futureNote.isEmpty
                  ? 'A line for later-you'
                  : 'Later-you has a note',
              body: store.futureNote.isEmpty
                  ? 'Leave a sentence. I’ll read it with you if a wave comes.'
                  : store.futureNote,
              art: BunlyPanic.staying,
              onOpen: _editFutureNote,
            ),
            const SizedBox(height: 8),
            YouKitTile(
              title: 'What usually helps',
              body: store.helpsMe.isEmpty
                  ? 'A real thing your body already knows.'
                  : store.helpsMe,
              art: BunlyPanic.grounding,
              onOpen: _editHelps,
            ),
            const SizedBox(height: 8),
            YouKitTile(
              title: store.safePerson.isEmpty
                  ? 'Someone who can know'
                  : store.safePerson,
              body: store.safePerson.isEmpty
                  ? 'A name, for after. Not for the peak.'
                  : 'Someone who can know.',
              art: BunlyPoses.sitting,
              onOpen: _editPerson,
            ),
            const SizedBox(height: 22),
            Text(
              'On your iPhone',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            YouKitTile(
              title: 'Home & Lock Screen',
              body:
                  'Put Bondly on your Home Screen. SOS on the Lock Screen, if a wave comes.',
              art: BunlyPoses.huggingStar,
              onOpen: () async {
                if (!await PaywallScreen.require(context)) return;
                if (!context.mounted) return;
                NativeChrome.push(
                  context,
                  AppMotion.fadeTo(const WidgetStudioScreen()),
                  title: 'Widgets',
                );
              },
            ),
            const SizedBox(height: 22),
            YouQuietBar(
              quiet: store.silentMode,
              onChanged: (value) {
                store.setSilentMode(value);
                AppAudio.syncSilent();
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Account',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            YouKitTile(
              title: 'Account & privacy',
              body: 'Sign out, delete account, Privacy Policy, Terms.',
              art: BunlyPoses.delighted,
              trailing: CupertinoIcons.chevron_forward,
              onOpen: () {
                NativeChrome.push(
                  context,
                  AppMotion.fadeTo(const AccountScreen()),
                  title: 'Account',
                );
              },
            ),
          ],
        );
      },
    );
  }

  static String _when(DateTime at) {
    final now = DateTime.now();
    final day = DateTime(at.year, at.month, at.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _weekday[at.weekday - 1];
  }
}
