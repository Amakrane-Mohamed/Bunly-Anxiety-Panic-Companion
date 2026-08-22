import '../../core/constants/app_assets.dart';

enum OnboardingKind { multi, slider, peek, cheer, journey, generating }

enum PeekSide { left, right }

class OnboardingStep {
  const OnboardingStep({
    required this.kind,
    required this.pose,
    this.prompt = '',
    this.highlight,
    this.speech,
    this.options = const [],
    this.lowLabel,
    this.highLabel,
    this.sliderMarks = const [],
    this.peekSide = PeekSide.right,
    this.continueLabel = 'Continue',
  });

  final OnboardingKind kind;
  final String pose;
  final String prompt;
  final String? highlight;
  final String? speech;
  final List<String> options;
  final String? lowLabel;
  final String? highLabel;
  final List<String> sliderMarks;
  final PeekSide peekSide;
  final String continueLabel;
}

abstract final class OnboardingContent {
  static const intensityMarks = [
    'Very little',
    'A little',
    'A lot',
    'Too much',
  ];

  static const agreeMarks = ['Not at all', 'Sort of', 'Totally'];

  static const steps = <OnboardingStep>[
    OnboardingStep(
      kind: OnboardingKind.peek,
      pose: BunlyPoses.winking,
      peekSide: PeekSide.right,
      prompt: 'Hi. I’m Bunly — and I’m staying with you through this.',
      highlight: 'staying with you',
      continueLabel: 'Hi, Bunly',
    ),
    OnboardingStep(
      kind: OnboardingKind.multi,
      pose: BunlyActivities.worried,
      prompt: 'What’s been hardest for you lately?',
      highlight: 'hardest',
      options: [
        'Stopping panic when it starts',
        'Calming my thoughts',
        'Feeling safe in my body',
        'Handling stress',
        'Feeling like myself again',
      ],
    ),
    OnboardingStep(
      kind: OnboardingKind.cheer,
      pose: BunlyPoses.jumping,
      prompt: 'That’s brave.',
      highlight: 'brave',
      speech: 'Thank you for telling me. I know that wasn’t easy.',
      continueLabel: 'Let’s keep going',
    ),
    OnboardingStep(
      kind: OnboardingKind.slider,
      pose: BunlyEmotions.wow,
      prompt: 'How heavy does it feel right now?',
      highlight: 'right now',
      lowLabel: 'Very little',
      highLabel: 'Too much',
      sliderMarks: intensityMarks,
    ),
    OnboardingStep(
      kind: OnboardingKind.multi,
      pose: BunlyActivities.thinking,
      prompt: 'When it shows up, what does it feel like most?',
      highlight: 'feel like most',
      options: [
        'Panic or sudden fear',
        'Racing thoughts',
        'Dread, like danger is near',
        'A body that doesn’t feel safe',
        'Exhaustion',
      ],
    ),
    OnboardingStep(
      kind: OnboardingKind.slider,
      pose: BunlyActivities.worried,
      prompt: 'A part of me is always waiting for the next wave.',
      highlight: 'waiting',
      lowLabel: 'Not at all',
      highLabel: 'Totally',
      sliderMarks: agreeMarks,
    ),
    OnboardingStep(
      kind: OnboardingKind.peek,
      pose: BunlyPoses.sitting,
      peekSide: PeekSide.left,
      prompt: 'You’re not doing this alone. I’m right here.',
      highlight: 'not doing this alone',
      continueLabel: 'I hear you',
    ),
    OnboardingStep(
      kind: OnboardingKind.multi,
      pose: BunlyEmotions.content,
      prompt: 'When a wave hits, what do you wish someone would say?',
      highlight: 'wish someone would say',
      options: [
        'You’re safe. This will pass.',
        'I’m right here. You don’t have to explain.',
        'Breathe with me.',
        'Nothing is wrong with you.',
        'We can get through this together.',
      ],
    ),
    OnboardingStep(
      kind: OnboardingKind.cheer,
      pose: BunlyPoses.delighted,
      prompt: 'I’ll remember that.',
      highlight: 'remember',
      speech: 'When it hits, you won’t have to face it by yourself.',
      continueLabel: 'Thank you',
    ),
    OnboardingStep(
      kind: OnboardingKind.multi,
      pose: BunlyEmotions.happy,
      prompt: 'What would feel like a win, even a small one?',
      highlight: 'a win',
      options: [
        'Fewer panic waves',
        'More peace and calm',
        'Feeling in control of my body',
        'A little more energy',
        'Feeling like myself',
      ],
    ),
    OnboardingStep(
      kind: OnboardingKind.cheer,
      pose: BunlyPoses.proud,
      prompt: 'I can already see a path for us.',
      highlight: 'a path for us',
      speech: 'We’ll take this one calm moment at a time.',
      continueLabel: 'I’m with you',
    ),
    OnboardingStep(
      kind: OnboardingKind.journey,
      pose: BunlyPoses.huggingStar,
      prompt: 'Your journey to feeling steadier starts here.',
      highlight: 'steadier',
      speech: 'I’ll be beside you for every step.',
      continueLabel: 'Start together',
    ),
    OnboardingStep(
      kind: OnboardingKind.generating,
      pose: BunlyEmotions.excited,
      prompt: 'Creating your plan…',
    ),
  ];
}
