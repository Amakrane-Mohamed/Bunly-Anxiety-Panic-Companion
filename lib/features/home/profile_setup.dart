import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/constants/app_assets.dart';
import '../../core/motion/app_motion.dart';
import '../../core/profile/user_plan.dart';
import '../../core/store/local_disk.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/bunly_button.dart';
import '../../shared/widgets/talk_bubble.dart';
import 'doctor_checkin_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.washTop,
                    Color(0xFFF8F3FC),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            ProfileSetupOverlay(
              onDone: () {
                Navigator.of(context).pushReplacement(
                  AppMotion.fadeTo(const DoctorCheckInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _ProfileStep { birthday, pronouns, name }

class _StepCopy {
  const _StepCopy({required this.title, required this.highlight});

  final String title;
  final String highlight;
}

class ProfileSetupOverlay extends StatefulWidget {
  const ProfileSetupOverlay({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ProfileSetupOverlay> createState() => _ProfileSetupOverlayState();
}

class _ProfileSetupOverlayState extends State<ProfileSetupOverlay>
    with SingleTickerProviderStateMixin {
  static const _copy = {
    _ProfileStep.birthday: _StepCopy(
      title: 'When’s your birthday?',
      highlight: 'birthday',
    ),
    _ProfileStep.pronouns: _StepCopy(
      title: 'How should I talk about you?',
      highlight: 'talk about you',
    ),
    _ProfileStep.name: _StepCopy(
      title: 'What should I call you?',
      highlight: 'call you',
    ),
  };

  static const _pronouns = [
    (label: 'she', value: 'she', pose: BunlyPoses.delighted, hint: 'Female'),
    (label: 'he', value: 'he', pose: BunlyPoses.proud, hint: 'Male'),
    (
      label: 'they',
      value: 'they',
      pose: BunlyPoses.winking,
      hint: 'Non-binary',
    ),
  ];

  late final AnimationController _sheet;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  var _step = _ProfileStep.birthday;
  var _closing = false;
  final _day = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();
  final _name = TextEditingController();
  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();
  final _nameFocus = FocusNode();
  String? _pronoun;

  @override
  void initState() {
    super.initState();
    _sheet = AnimationController(vsync: this, duration: AppMotion.page);
    final curved = CurvedAnimation(parent: _sheet, curve: AppMotion.curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(curved);
    _fade = curved;

    _day.addListener(_onChanged);
    _month.addListener(_onChanged);
    _year.addListener(_onChanged);
    _name.addListener(_onChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _sheet.value = 1;
      }
    });
  }

  @override
  void dispose() {
    _sheet.dispose();
    _day.dispose();
    _month.dispose();
    _year.dispose();
    _name.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  DateTime? get _birthday {
    final day = int.tryParse(_day.text);
    final month = int.tryParse(_month.text);
    final year = int.tryParse(_year.text);
    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > DateTime.now().year) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    if (date.isAfter(DateTime.now())) return null;
    return date;
  }

  bool get _oldEnough {
    final born = _birthday;
    if (born == null) return false;
    final now = DateTime.now();
    var age = now.year - born.year;
    if (now.month < born.month ||
        (now.month == born.month && now.day < born.day)) {
      age -= 1;
    }
    return age >= 13;
  }

  bool get _canContinue {
    switch (_step) {
      case _ProfileStep.birthday:
        return _oldEnough;
      case _ProfileStep.pronouns:
        return _pronoun != null;
      case _ProfileStep.name:
        return _name.text.trim().isNotEmpty;
    }
  }

  void _onMessageDone(_ProfileStep step) {
    if (!mounted || _closing || _step != step) return;
    _showSheet();
  }

  void _showSheet() {
    if (!mounted || _closing) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.value = 1;
      return;
    }
    _sheet.forward();
    if (_step == _ProfileStep.name) {
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (mounted) _nameFocus.requestFocus();
      });
    }
  }

  Future<void> _continue() async {
    if (!_canContinue || _closing) return;
    FocusScope.of(context).unfocus();

    switch (_step) {
      case _ProfileStep.birthday:
        await _sheet.reverse();
        if (!mounted) return;
        setState(() => _step = _ProfileStep.pronouns);
      case _ProfileStep.pronouns:
        await _sheet.reverse();
        if (!mounted) return;
        setState(() => _step = _ProfileStep.name);
      case _ProfileStep.name:
        _closing = true;
        final plan = UserPlan.instance;
        plan.name = _name.text.trim();
        plan.pronoun = _pronoun ?? 'they';
        plan.birthday = _birthday;
        unawaited(LocalDisk.writePlan());
        if (MediaQuery.disableAnimationsOf(context)) {
          widget.onDone();
          return;
        }
        await _sheet.reverse();
        if (mounted) widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final step = _step;
    final copy = _copy[step]!;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Color(0x66000000), Color(0x00000000)],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TalkBubble(
                key: ValueKey(step),
                text: copy.title,
                highlight: copy.highlight,
                onComplete: () => _onMessageDone(step),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Material(
                  color: const Color(0xFFFFF7F0),
                  elevation: 20,
                  shadowColor: const Color(0x663C275C),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedSize(
                    duration: AppMotion.page,
                    curve: AppMotion.curve,
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        26,
                        24,
                        18 + bottomInset,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            switchInCurve: AppMotion.curve,
                            switchOutCurve: AppMotion.curve,
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _bodyForStep(),
                            ),
                          ),
                          const SizedBox(height: 22),
                          BunlyPrimaryButton(
                            label: 'Continue',
                            onPressed: _canContinue ? _continue : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bodyForStep() {
    switch (_step) {
      case _ProfileStep.birthday:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateBox(
                    controller: _day,
                    focusNode: _dayFocus,
                    hint: 'DD',
                    maxLength: 2,
                    onFilled: () => _monthFocus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateBox(
                    controller: _month,
                    focusNode: _monthFocus,
                    hint: 'MM',
                    maxLength: 2,
                    onFilled: () => _yearFocus.requestFocus(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _DateBox(
                    controller: _year,
                    focusNode: _yearFocus,
                    hint: 'YYYY',
                    maxLength: 4,
                    onFilled: () => _yearFocus.unfocus(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'You need to be 13 or older to use Bunly. If you’re a minor, a parent or guardian should say yes first.',
              textAlign: TextAlign.center,
              style: AppTypography.ui(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        );
      case _ProfileStep.pronouns:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _pronouns.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _GenderCard(
                  label: _pronouns[i].label,
                  hint: _pronouns[i].hint,
                  pose: _pronouns[i].pose,
                  selected: _pronoun == _pronouns[i].value,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    AppAudio.answer();
                    setState(() => _pronoun = _pronouns[i].value);
                  },
                ),
              ),
            ],
          ],
        );
      case _ProfileStep.name:
        return TextField(
          controller: _name,
          focusNode: _nameFocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          cursorColor: AppColors.brand,
          style: AppTypography.ui(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          onSubmitted: (_) => _continue(),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: AppTypography.ui(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.inkMuted.withValues(alpha: 0.55),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
            ),
          ),
        );
    }
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.maxLength,
    required this.onFilled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int maxLength;
  final VoidCallback onFilled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      cursorColor: AppColors.brand,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      style: AppTypography.ui(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      onChanged: (value) {
        if (value.length >= maxLength) onFilled();
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.ui(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.inkMuted.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.hint,
    required this.pose,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String pose;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$hint, $label',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF0E4) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? AppColors.brand.withValues(alpha: 0.45)
                    : AppColors.optionLine,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  pose,
                  height: 92,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: AppTypography.ui(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.ink,
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
