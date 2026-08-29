import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/access/access.dart';
import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/profile/user_plan.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/bunly_card.dart';
import '../convert/paywall_screen.dart';
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

  var _face = 0;

  YouFace get _selected => YouFace.all[_face];

  @override
  void initState() {
    super.initState();
    final current = AppStore.instance.youFaceId;
    final index = YouFace.all.indexWhere((face) => face.id == current);
    if (index >= 0) _face = index;
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

  Future<void> _selectFace(int index) async {
    HapticFeedback.selectionClick();
    AppAudio.tap();
    setState(() => _face = index);
  }

  Future<void> _claimSelected() async {
    if (!Access.instance.unlocked) {
      await PaywallScreen.require(context);
      if (!Access.instance.unlocked || !mounted) return;
    }
    final face = _selected;
    final store = AppStore.instance;
    final alreadyToday = store.claimedFaceToday && store.youFaceId == face.id;
    if (alreadyToday) return;

    HapticFeedback.mediumImpact();
    AppAudio.win();
    store.claimFace(
      id: face.id,
      pose: face.widgetPose,
      art: face.fallback,
      line: face.line,
    );
    if (!mounted) return;
    await _afterClaim(face);
  }

  Future<void> _afterClaim(YouFace face) async {
    final store = AppStore.instance;
    if (face.claimKind == YouClaimKind.thanks && store.thanksNotes.isEmpty) {
      await _writeThanks();
    } else if (face.claimKind == YouClaimKind.laterYou &&
        store.futureNote.isEmpty) {
      await _editFutureNote();
    } else if (face.claimKind == YouClaimKind.helps && store.helpsMe.isEmpty) {
      await _editHelps();
    } else if (face.claimKind == YouClaimKind.person &&
        store.safePerson.isEmpty) {
      await _editPerson();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppStore.instance, Access.instance]),
      builder: (context, _) {
        final store = AppStore.instance;
        final locked = !Access.instance.unlocked;
        final thanks = store.thanksNotes;
        final face = _selected;
        final owned = store.hasClaimedFace(face.id);
        final today = store.claimedFaceToday && store.youFaceId == face.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _YouHeader(),
            const SizedBox(height: 22),
            Text(
              'Today',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            YouCardArt(
              face: face,
              height: 280,
              locked: locked && !owned,
              claimed: owned,
            ),
            const SizedBox(height: 12),
            Text(
              face.name,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                fontSize: 24,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              face.line,
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 14),
            if (today)
              const _ClaimedBanner()
            else
              BunlyPrimaryButton(
                label: owned ? 'Claim for today' : 'Claim this',
                onPressed: _claimSelected,
              ),
            const SizedBox(height: 22),
            Text(
              'Your cards',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Claim one. Bondly keeps it on Today and on your widgets.',
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: YouFace.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final item = YouFace.all[index];
                final isOwned = store.hasClaimedFace(item.id);
                final isSelected = index == _face;
                return _FaceCell(
                  face: item,
                  selected: isSelected,
                  claimed: isOwned,
                  locked: locked && !isOwned,
                  onTap: () => _selectFace(index),
                );
              },
            ),
            const SizedBox(height: 26),
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
                      child: Text(
                        'Write one',
                        style: AppTypography.ui(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
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
              'On this device',
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
              trailing: CupertinoIcons.chevron_forward,
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

class _YouHeader extends StatelessWidget {
  const _YouHeader();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final name = UserPlan.instance.firstName;
    final face = YouFace.byId(store.youFaceId);
    final claimedToday = store.claimedFaceToday;
    final count = store.claimedFaces.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          claimedToday && face != null ? face.fallback : BunlyPoses.sitting,
          width: 72,
          height: 72,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name == 'friend' ? 'You' : name,
                style: AppTypography.display(
                  fontSize: 28,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                claimedToday && face != null
                    ? 'Claimed today · ${face.name}'
                    : count == 0
                    ? 'Claim a card. That’s how Bondly knows you today.'
                    : '$count of ${YouFace.all.length} claimed. Pick today.',
                style: AppTypography.ui(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClaimedBanner extends StatelessWidget {
  const _ClaimedBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.optionSelected,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const YouClaimStamp(size: 22),
            const SizedBox(width: 8),
            Text(
              'Claimed for today',
              style: AppTypography.ui(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceCell extends StatelessWidget {
  const _FaceCell({
    required this.face,
    required this.selected,
    required this.claimed,
    required this.locked,
    required this.onTap,
  });

  final YouFace face;
  final bool selected;
  final bool claimed;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: claimed ? '${face.name}, claimed' : face.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.brand : const Color(0x00000000),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YouCardArt(
                    face: face,
                    locked: locked,
                    claimed: claimed,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                face.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.ui(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.ink : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
