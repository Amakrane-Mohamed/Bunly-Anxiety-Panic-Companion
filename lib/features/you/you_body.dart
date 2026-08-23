import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../journey/journey_look.dart';

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

  static const _headerLines = [
    'This is yours. I wait on the couch.',
    'Thanks live here. Panic notes too.',
    'I don’t read them out loud.',
    'Quiet is allowed in this room.',
  ];

  static const _thanksArt = [
    BunlyActivities.gifting,
    BunlyPoses.huggingStar,
    BunlyJourney.growth,
    BunlyPoses.proud,
    BunlyActivities.gardening,
    BunlyPoses.winking,
  ];

  var _headerLine = 0;
  String? _justWrote;

  Future<void> _afterThanks(String id) async {
    if (!mounted) return;
    AppAudio.win();
    HapticFeedback.mediumImpact();
    setState(() => _justWrote = id);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (mounted && _justWrote == id) {
      setState(() => _justWrote = null);
    }
  }

  Future<void> _writeThanks() async {
    final next = await _lineSheet(
      title: 'A thanks',
      value: '',
      hint: 'Something that was okay. Or kind. Or yours.',
      lines: 4,
      saveLabel: 'Keep it',
    );
    if (next == null || next.trim().isEmpty) return;
    AppStore.instance.addThanks(next);
    final id = AppStore.instance.thanksNotes.first.id;
    await _afterThanks(id);
  }

  Future<void> _openThanks(ThanksNote note) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.home,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + inset),
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
              const SizedBox(height: 16),
              _SheetSave(
                label: 'Keep it',
                onTap: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 4),
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
        );
      },
    );
    if (remove == true) AppStore.instance.removeThanks(note.id);
  }

  Future<void> _editFutureNote() async {
    final next = await _lineSheet(
      title: 'A line for later-you',
      value: AppStore.instance.futureNote,
      hint: 'If a wave comes…',
      lines: 4,
    );
    if (next == null) return;
    AppStore.instance.setFutureNote(next);
  }

  Future<void> _editHelps() async {
    final next = await _lineSheet(
      title: 'What usually helps',
      value: AppStore.instance.helpsMe,
      hint: 'Cold water. A window. Naming five things.',
      lines: 3,
    );
    if (next == null) return;
    AppStore.instance.setHelpsMe(next);
  }

  Future<void> _editPerson() async {
    final next = await _lineSheet(
      title: 'Someone who can know',
      value: AppStore.instance.safePerson,
      hint: 'A name',
      lines: 1,
    );
    if (next == null) return;
    AppStore.instance.setSafePerson(next);
  }

  Future<String?> _lineSheet({
    required String title,
    required String value,
    required String hint,
    required int lines,
    String saveLabel = 'Save',
  }) {
    final controller = TextEditingController(text: value);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.home,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + inset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTypography.ui(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: lines,
                style: AppTypography.ui(fontSize: 16, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.ui(
                    fontSize: 16,
                    color: AppColors.inkMuted,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFDF6EC),
                  contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCC9A8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCC9A8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.brand),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SheetSave(
                label: saveLabel,
                onTap: () => Navigator.of(context).pop(controller.text),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final thanks = store.thanksNotes;
    final weekday = _weekday[DateTime.now().weekday - 1];
    final count = thanks.length;
    final headerLine = _justWrote != null
        ? 'Kept. I put it on the shelf.'
        : _headerLines[_headerLine];
    final headerMeta = count == 0
        ? '$weekday · the shelf is empty. That’s allowed.'
        : '$weekday · $count in here';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            AppAudio.tap();
            setState(
              () => _headerLine = (_headerLine + 1) % _headerLines.length,
            );
          },
          child: JourneyBrandCard(
            claimed: store.wroteThanksToday,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Image.asset(
                    store.wroteThanksToday
                        ? BunlyPoses.proud
                        : BunlyPoses.sitting,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your room',
                          style: AppTypography.ui(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          headerMeta,
                          style: AppTypography.ui(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          headerLine,
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
        const SizedBox(height: 16),
        const JourneySectionLabel('Thanks'),
        const SizedBox(height: 8),
        _RoomRow(
          title: store.wroteThanksToday ? 'Another thanks' : 'Write a thanks',
          subtitle: store.wroteThanksToday
              ? 'Another, if you want. Tiny is allowed.'
              : 'One true thing. It can be small.',
          art: BunlyActivities.gifting,
          chip: 'Write',
          onOpen: _writeThanks,
        ),
        for (var i = 0; i < thanks.length; i++)
          _RoomRow(
          title: thanks[i].text,
          subtitle: _when(thanks[i].at),
          art: _thanksArt[i % _thanksArt.length],
          filled: true,
          keepArt: true,
          celebrate: _justWrote == thanks[i].id,
          onOpen: () => _openThanks(thanks[i]),
        ),
        const SizedBox(height: 8),
        const JourneySectionLabel('If a wave comes'),
        const SizedBox(height: 8),
        _RoomRow(
          title: store.futureNote.isEmpty
              ? 'A line for later-you'
              : 'Later-you has a note',
          subtitle: store.futureNote.isEmpty
              ? 'Leave a sentence. I’ll read it with you if a wave comes.'
              : store.futureNote,
          art: BunlyPanic.staying,
          filled: store.futureNote.isNotEmpty,
          chip: store.futureNote.isEmpty ? 'Write' : 'Open',
          onOpen: _editFutureNote,
        ),
        _RoomRow(
          title: 'What usually helps',
          subtitle: store.helpsMe.isEmpty
              ? 'A real thing your body already knows.'
              : store.helpsMe,
          art: BunlyPanic.grounding,
          filled: store.helpsMe.isNotEmpty,
          chip: store.helpsMe.isEmpty ? 'Write' : 'Open',
          onOpen: _editHelps,
        ),
        _RoomRow(
          title: store.safePerson.isEmpty
              ? 'Someone who can know'
              : store.safePerson,
          subtitle: store.safePerson.isEmpty
              ? 'A name, for after. Not for the peak.'
              : 'Someone who can know.',
          art: BunlyPoses.sitting,
          filled: store.safePerson.isNotEmpty,
          chip: store.safePerson.isEmpty ? 'Name' : 'Open',
          onOpen: _editPerson,
        ),
        const SizedBox(height: 8),
        const JourneySectionLabel('This room'),
        const SizedBox(height: 8),
        _RoomRow(
          title: store.silentMode ? 'Quiet' : 'Sounds on',
          subtitle: store.silentMode
              ? 'Bondly stays quiet in here.'
              : 'Taps and the little music.',
          art: store.silentMode ? BunlyToday.sleeping : BunlyPoses.winking,
          filled: store.silentMode,
          chip: store.silentMode ? 'Sounds' : 'Quiet',
          onOpen: () {
            store.setSilentMode(!store.silentMode);
            AppAudio.syncSilent();
          },
        ),
        const SizedBox(height: 8),
      ],
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

class _SheetSave extends StatelessWidget {
  const _SheetSave({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        AppAudio.tap();
        onTap();
      },
      child: JourneyBrandCard(
        claimed: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.ui(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomRow extends StatefulWidget {
  const _RoomRow({
    required this.title,
    required this.subtitle,
    required this.art,
    required this.onOpen,
    this.chip,
    this.filled = false,
    this.keepArt = false,
    this.celebrate = false,
  });

  final String title;
  final String subtitle;
  final String art;
  final String? chip;
  final bool filled;
  final bool keepArt;
  final bool celebrate;
  final VoidCallback onOpen;

  @override
  State<_RoomRow> createState() => _RoomRowState();
}

class _RoomRowState extends State<_RoomRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.selectionClick();
          AppAudio.tap();
          widget.onOpen();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 80),
          child: JourneyBrandCard(
            claimed: widget.filled,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  JourneyStampCheck(
                    claimed: widget.filled,
                    celebrate: widget.celebrate,
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    widget.filled && !widget.keepArt
                        ? BunlyPoses.proud
                        : widget.art,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.ui(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  if (!widget.filled && widget.chip != null) ...[
                    const SizedBox(width: 8),
                    IgnorePointer(child: JourneyClaimChip(label: widget.chip!)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
