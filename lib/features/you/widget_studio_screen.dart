import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_card.dart';
import '../../shared/widgets/bunly_scaffold.dart';

class WidgetStudioScreen extends StatefulWidget {
  const WidgetStudioScreen({super.key});

  @override
  State<WidgetStudioScreen> createState() => _WidgetStudioScreenState();
}

class _WidgetStudioScreenState extends State<WidgetStudioScreen> {
  late final TextEditingController _custom;
  var _preview = 0;

  @override
  void initState() {
    super.initState();
    _custom = TextEditingController(text: AppStore.instance.widgetCustomLine);
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _select() {
    HapticFeedback.selectionClick();
    AppAudio.tap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        return BunlyScaffold(
          title: 'Widgets',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                'Bondly, on your Home Screen',
                style: AppTypography.display(fontSize: 26, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                'A quiet face on the Home Screen. SOS on the Lock Screen, if a wave comes.',
                style: AppTypography.ui(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 18),
              _PreviewTabs(
                index: _preview,
                onPick: (i) {
                  _select();
                  setState(() => _preview = i);
                },
              ),
              const SizedBox(height: 14),
              Center(child: WidgetLivePreview(kind: _preview)),
              const SizedBox(height: 22),
              const _Section('Look'),
              const SizedBox(height: 10),
              const _LookRow(),
              const SizedBox(height: 22),
              const _Section('Bondly'),
              const SizedBox(height: 10),
              const _PoseRow(),
              const SizedBox(height: 22),
              const _Section('What Bondly says'),
              const SizedBox(height: 10),
              const _VoiceColumn(),
              if (store.widgetVoice == 'yours') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _custom,
                  minLines: 2,
                  maxLines: 3,
                  style: AppTypography.ui(fontSize: 16, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'A sentence for later-you.',
                    hintStyle: AppTypography.ui(
                      fontSize: 16,
                      color: AppColors.inkMuted,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: store.setWidgetCustomLine,
                ),
              ],
              const SizedBox(height: 22),
              const _Section('On the widget'),
              const SizedBox(height: 10),
              _ToggleTile(
                title: 'Hearts',
                body: 'How many you still have.',
                value: store.widgetShowHearts,
                onChanged: store.setWidgetShowHearts,
              ),
              const SizedBox(height: 8),
              _ToggleTile(
                title: 'Streak',
                body: 'Days you checked in, in a row.',
                value: store.widgetShowStreak,
                onChanged: store.setWidgetShowStreak,
              ),
              const SizedBox(height: 22),
              const _Section('SOS'),
              const SizedBox(height: 10),
              const _SosRow(),
              const SizedBox(height: 22),
              const _Section('How to add them'),
              const SizedBox(height: 10),
              const _HowToCard(),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.ui(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.inkMuted,
      ),
    );
  }
}

class _PreviewTabs extends StatelessWidget {
  const _PreviewTabs({required this.index, required this.onPick});

  final int index;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Lock', 'SOS'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onPick(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: i == index ? AppColors.brand : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.ui(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: i == index ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LookRow extends StatelessWidget {
  const _LookRow();

  static const looks = [
    ('cream', 'Cream', Color(0xFFFDF2E6), Color(0xFFF3EEFC)),
    ('lilac', 'Lilac', Color(0xFFE8DFFC), Color(0xFFF7F3FF)),
    ('night', 'Night', Color(0xFF2A1C4A), Color(0xFF180E2E)),
    ('gold', 'Gold', Color(0xFFF7E2BA), Color(0xFFFFF8EA)),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Row(
      children: [
        for (final look in looks) ...[
          if (look != looks.first) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                AppAudio.tap();
                store.setWidgetLook(look.$1);
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [look.$4, look.$3],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: store.widgetLook == look.$1
                            ? AppColors.brand
                            : AppColors.optionLine,
                        width: store.widgetLook == look.$1 ? 2.4 : 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    look.$2,
                    style: AppTypography.ui(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: store.widgetLook == look.$1
                          ? AppColors.brand
                          : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PoseRow extends StatelessWidget {
  const _PoseRow();

  static const poses = [
    ('sitting', 'Here', BunlyPoses.sitting),
    ('hug', 'With you', BunlyPoses.huggingStar),
    ('calm', 'Calm', BunlyEmotions.content),
    ('proud', 'Proud', BunlyPoses.proud),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Row(
      children: [
        for (final pose in poses) ...[
          if (pose != poses.first) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                AppAudio.tap();
                store.setWidgetPose(pose.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: store.widgetPose == pose.$1
                        ? AppColors.brand
                        : AppColors.optionLine,
                    width: store.widgetPose == pose.$1 ? 2.2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(pose.$3, height: 56, filterQuality: FilterQuality.high),
                    const SizedBox(height: 6),
                    Text(
                      pose.$2,
                      style: AppTypography.ui(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VoiceColumn extends StatelessWidget {
  const _VoiceColumn();

  static const voices = [
    ('bondly', 'Bondly', 'A line for how today actually is.'),
    ('note', 'Later-you', 'The sentence you left for a wave.'),
    ('yours', 'Yours', 'Write the line yourself.'),
    ('calm', 'Time of day', 'Morning, evening, night — quietly.'),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Column(
      children: [
        for (final voice in voices) ...[
          if (voice != voices.first) const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AppAudio.tap();
              store.setWidgetVoice(voice.$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: store.widgetVoice == voice.$1
                    ? AppColors.optionSelected
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: store.widgetVoice == voice.$1
                      ? AppColors.brand
                      : AppColors.optionLine,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice.$2,
                    style: AppTypography.ui(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    voice.$3,
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SosRow extends StatelessWidget {
  const _SosRow();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Row(
      children: [
        Expanded(
          child: _SosChoice(
            selected: store.widgetSosStyle != 'here',
            title: 'SOS',
            body: 'Clear. Fast. For a wave.',
            color: AppColors.sos,
            onTap: () => store.setWidgetSosStyle('sos'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SosChoice(
            selected: store.widgetSosStyle == 'here',
            title: "I'm here",
            body: 'Softer. Still one tap.',
            color: AppColors.brand,
            onTap: () => store.setWidgetSosStyle('here'),
          ),
        ),
      ],
    );
  }
}

class _SosChoice extends StatelessWidget {
  const _SosChoice({
    required this.selected,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String body;
  final Color color;
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : AppColors.optionLine,
            width: selected ? 2.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: AppTypography.ui(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return BunlyCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.ui(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    body,
                    style: AppTypography.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeTrackColor: AppColors.brand,
              onChanged: (next) {
                HapticFeedback.selectionClick();
                onChanged(next);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  const _HowToCard();

  @override
  Widget build(BuildContext context) {
    return BunlyCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home Screen',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Touch and hold the Home Screen. Tap Edit, then Add Widget. Search Bunly. Choose Bondly, SOS, or Check-in.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lock Screen',
              style: AppTypography.ui(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Touch and hold the Lock Screen. Tap Customize, then a widget area. Add SOS for a wave, or Bondly for hearts.',
              style: AppTypography.ui(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetLivePreview extends StatelessWidget {
  const WidgetLivePreview({super.key, required this.kind});

  final int kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      1 => const _LockPreview(),
      2 => const _SosPreview(),
      _ => const _HomePreview(),
    };
  }
}

class WidgetLookTheme {
  const WidgetLookTheme({
    required this.top,
    required this.bottom,
    required this.ink,
    required this.muted,
    required this.chip,
    required this.glow,
  });

  final Color top;
  final Color bottom;
  final Color ink;
  final Color muted;
  final Color chip;
  final Color glow;

  static WidgetLookTheme of(String id) {
    return switch (id) {
      'lilac' => const WidgetLookTheme(
          top: Color(0xFFF7F3FF),
          bottom: Color(0xFFE8DFFC),
          ink: Color(0xFF3D2B6B),
          muted: Color(0x8C3D2B6B),
          chip: Color(0xB8FFFFFF),
          glow: Color(0x386C4FD0),
        ),
      'night' => const WidgetLookTheme(
          top: Color(0xFF2A1C4A),
          bottom: Color(0xFF180E2E),
          ink: Color(0xFFF4F0EA),
          muted: Color(0x9EF4F0EA),
          chip: Color(0x1FFFFFFF),
          glow: Color(0x47B9A4F0),
        ),
      'gold' => const WidgetLookTheme(
          top: Color(0xFFFFF8EA),
          bottom: Color(0xFFF7E2BA),
          ink: Color(0xFF3D2B6B),
          muted: Color(0x8C3D2B6B),
          chip: Color(0xB3FFFFFF),
          glow: Color(0x47F2A93B),
        ),
      _ => const WidgetLookTheme(
          top: Color(0xFFF3EEFC),
          bottom: Color(0xFFFDF2E6),
          ink: Color(0xFF3D2B6B),
          muted: Color(0x8C3D2B6B),
          chip: Color(0xC7FFFFFF),
          glow: Color(0x296C4FD0),
        ),
    };
  }
}

String widgetPoseAsset(String pose) {
  return switch (pose) {
    'hug' => BunlyPoses.huggingStar,
    'calm' => BunlyEmotions.content,
    'proud' => BunlyPoses.proud,
    _ => BunlyPoses.sitting,
  };
}

class _HomePreview extends StatelessWidget {
  const _HomePreview();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final look = WidgetLookTheme.of(store.widgetLook);
    return _PhoneWidget(
      width: 168,
      height: 168,
      look: look,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Bondly',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: look.muted,
                  ),
                ),
                const Spacer(),
                if (store.widgetShowHearts)
                  _MiniChip(
                    look: look,
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFE56B9A),
                    text: '${store.hearts}',
                  ),
              ],
            ),
            const Spacer(),
            Image.asset(
              widgetPoseAsset(store.widgetPose),
              height: 72,
              filterQuality: FilterQuality.high,
            ),
            const Spacer(),
            Text(
              store.widgetDisplayLine,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: look.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockPreview extends StatelessWidget {
  const _LockPreview();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1230),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            'Lock Screen',
            style: AppTypography.ui(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LockCircle(
                icon: Icons.favorite_rounded,
                label: '${store.hearts}',
              ),
              const SizedBox(width: 12),
              _LockCircle(
                icon: Icons.favorite_rounded,
                label: store.widgetSosStyle == 'here' ? 'Here' : 'SOS',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SosPreview extends StatelessWidget {
  const _SosPreview();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final look = WidgetLookTheme.of(store.widgetLook);
    final soft = store.widgetSosStyle == 'here';
    return _PhoneWidget(
      width: 168,
      height: 168,
      look: look,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: soft ? AppColors.brand : AppColors.sos,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                  Text(
                    soft ? 'Here' : 'SOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              soft ? 'If a wave is here' : 'A wave is here',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: look.ink,
              ),
            ),
            Text(
              "Tap. I'm with you.",
              style: TextStyle(fontSize: 11, color: look.muted),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _PhoneWidget extends StatelessWidget {
  const _PhoneWidget({
    required this.width,
    required this.height,
    required this.look,
    required this.child,
  });

  final double width;
  final double height;
  final WidgetLookTheme look;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [look.top, look.bottom],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.look,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final WidgetLookTheme look;
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: look.chip,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: look.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockCircle extends StatelessWidget {
  const _LockCircle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
