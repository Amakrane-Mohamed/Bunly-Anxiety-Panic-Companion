import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/fade_up.dart';
import '../../shared/widgets/readable_width.dart';
import '../../shared/widgets/talk_bubble.dart';
import 'win_screen.dart';

class DoctorCheckInScreen extends StatefulWidget {
  const DoctorCheckInScreen({super.key});

  @override
  State<DoctorCheckInScreen> createState() => _DoctorCheckInScreenState();
}

class _DoctorCheckInScreenState extends State<DoctorCheckInScreen> {
  static const _beats = [
    (
      text:
          'I see you. You’re fighting panic attacks — and you’re not doing that alone.',
      highlight: 'not doing that alone',
    ),
    (
      text: 'When it hits, does it come on suddenly, like a wave?',
      highlight: 'suddenly',
    ),
    (
      text: 'Do your thoughts start racing when a wave comes?',
      highlight: 'racing',
    ),
    (
      text: 'Would you like me to stay close when it happens?',
      highlight: 'stay close',
    ),
  ];

  var _index = 0;
  var _showChoices = false;

  @override
  void initState() {
    super.initState();
    AppAudio.stopMusic();
  }

  void _onTalkDone() {
    if (!mounted) return;
    setState(() => _showChoices = true);
  }

  void _answer() {
    HapticFeedback.lightImpact();
    if (_index >= _beats.length - 1) {
      Navigator.of(
        context,
      ).pushReplacement(AppMotion.fadeTo(const WinScreen()));
      return;
    }
    setState(() {
      _showChoices = false;
      _index += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final beat = _beats[_index];
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF1E1433),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2A1B45),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(OnboardingArt.doctor),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0x73000000), Color(0x00000000)],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  bottom: false,
                  child: ReadableWidth(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: TalkBubble(
                        key: ValueKey(_index),
                        text: beat.text,
                        highlight: beat.highlight,
                        face: BunlyEmotions.content,
                        onComplete: _onTalkDone,
                      ),
                    ),
                  ),
                ),
              ),
              if (_showChoices)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ReadableWidth(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 22 + bottomInset),
                      child: FadeUp(
                        offset: 18,
                        child: Row(
                          children: [
                            Expanded(
                              child: _ChoiceButton(
                                label: 'No',
                                filled: false,
                                onTap: _answer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _ChoiceButton(
                                label: 'Yes',
                                filled: true,
                                onTap: _answer,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _ChoiceButton extends StatefulWidget {
  const _ChoiceButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
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
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: widget.filled ? AppColors.brand : Colors.white,
            border: widget.filled
                ? null
                : Border.all(color: const Color(0x66FFFFFF), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: (widget.filled ? AppColors.brand : Colors.black)
                    .withValues(alpha: widget.filled ? 0.34 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTypography.ui(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: widget.filled ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
