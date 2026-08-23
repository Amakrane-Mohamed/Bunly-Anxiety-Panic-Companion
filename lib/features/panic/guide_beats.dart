import '../../core/constants/app_assets.dart';

enum BeatKind { tap, hold, pops, drag, listen }

class GuideBeat {
  const GuideBeat({
    required this.title,
    required this.body,
    required this.art,
    required this.kind,
    this.action = 'Continue',
    this.pops = 4,
  });

  final String title;
  final String body;
  final String art;
  final BeatKind kind;
  final String action;
  final int pops;
}

abstract final class GuideBooks {
  static const sos = <GuideBeat>[
    GuideBeat(
      title: 'I’m here.',
      body: 'This is a body alarm. Loud. Not danger. Stay with my voice.',
      art: BunlyPanic.readyToHelp,
      kind: BeatKind.tap,
      action: 'I’m with you',
    ),
    GuideBeat(
      title: 'Name it.',
      body: 'Say it, even in your head: “This is a panic wave. It will pass.”',
      art: BunlyPanic.staying,
      kind: BeatKind.tap,
      action: 'I named it',
    ),
    GuideBeat(
      title: 'Breathe with me.',
      body: 'Hold the circle to breathe in. Let go for a long out. The out is the medicine.',
      art: BunlyPanic.breathing,
      kind: BeatKind.hold,
    ),
    GuideBeat(
      title: 'Look around.',
      body: 'Tap 5 things you can see. A colour. A corner. My coat. Anything real.',
      art: BunlyPanic.grounding,
      kind: BeatKind.pops,
      pops: 5,
    ),
    GuideBeat(
      title: 'Count with me.',
      body: 'Three slow taps. No rush. I’m counting too.',
      art: BunlyPanic.countingDown,
      kind: BeatKind.pops,
      pops: 3,
    ),
    GuideBeat(
      title: 'Feet on the floor.',
      body: 'Press them down like you’re plugging in. Heavy is good.',
      art: BunlyPanic.grounding,
      kind: BeatKind.tap,
      action: 'They’re on the floor',
    ),
    GuideBeat(
      title: 'Close your eyes.',
      body: 'I’ll keep the music. You don’t have to do anything else for a few seconds.',
      art: BunlyPanic.easing,
      kind: BeatKind.listen,
      action: 'I heard it',
    ),
    GuideBeat(
      title: 'Still here.',
      body: 'The wave peaks. Then it goes. You stayed. That’s the whole trick.',
      art: BunlyPanic.passed,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const coming = <GuideBeat>[
    GuideBeat(
      title: 'I felt it too.',
      body: 'A wave is peeking. We catch it early. Nothing to prove.',
      art: BunlyEmotions.surprised,
      kind: BeatKind.tap,
      action: 'Let’s catch it',
    ),
    GuideBeat(
      title: 'Give your hands a job.',
      body: 'Drag the star into the circle. That’s it. One small move.',
      art: BunlyPoses.huggingStar,
      kind: BeatKind.drag,
    ),
    GuideBeat(
      title: 'Tap what you can see.',
      body: 'Four things. A wall. A light. Your sleeve. Me.',
      art: BunlyActivities.thinking,
      kind: BeatKind.pops,
      pops: 4,
    ),
    GuideBeat(
      title: 'A quiet breath.',
      body: 'Hold to breathe in. Let go to breathe out. We’re not in a hurry.',
      art: BunlyPanic.breathing,
      kind: BeatKind.hold,
    ),
    GuideBeat(
      title: 'Put your hand here.',
      body: 'On your chest, or on the phone. Feel how solid it is. Tap when you feel it.',
      art: BunlyPoses.sitting,
      kind: BeatKind.tap,
      action: 'I feel it',
    ),
    GuideBeat(
      title: 'Close your eyes a second.',
      body: 'Listen to the music. If thoughts show up, let them walk past.',
      art: BunlyEmotions.content,
      kind: BeatKind.listen,
      action: 'I’m back',
    ),
    GuideBeat(
      title: 'See?',
      body: 'We met it early. You’re allowed to feel proud of that.',
      art: BunlyPoses.proud,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const heart = <GuideBeat>[
    GuideBeat(
      title: 'Your heart is being loud.',
      body: 'That’s adrenaline, not a disaster. Hearts do this. They also settle.',
      art: BunlyPanic.readyToHelp,
      kind: BeatKind.tap,
      action: 'Okay, stay',
    ),
    GuideBeat(
      title: 'Longer out than in.',
      body: 'Hold to breathe in. Let go even slower. Tell your chest it’s safe.',
      art: BunlyPanic.breathing,
      kind: BeatKind.hold,
    ),
    GuideBeat(
      title: 'Hand on chest.',
      body: 'Feel the beat. It’s fast. Fast is not broken. Tap when you feel it.',
      art: BunlyActivities.worried,
      kind: BeatKind.tap,
      action: 'I feel it',
    ),
    GuideBeat(
      title: 'Still beating. Still you.',
      body: 'We don’t need it to be quiet yet. We just stay.',
      art: BunlyEmotions.content,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const breath = <GuideBeat>[
    GuideBeat(
      title: 'Air is still here.',
      body: 'Panic makes breath feel small. It isn’t gone. We’ll take a tiny one.',
      art: BunlyPanic.breathing,
      kind: BeatKind.tap,
      action: 'Tiny is fine',
    ),
    GuideBeat(
      title: 'Sip, then a long out.',
      body: 'Hold for a small in. Let go for a bigger out. Repeat with me.',
      art: BunlyInsights.thinking,
      kind: BeatKind.hold,
    ),
    GuideBeat(
      title: 'Count three.',
      body: 'Tap with each easy out. No perfect breathing required.',
      art: BunlyPanic.countingDown,
      kind: BeatKind.pops,
      pops: 3,
    ),
    GuideBeat(
      title: 'That’s air.',
      body: 'You did it in little sips. That’s allowed.',
      art: BunlyPanic.easing,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const dying = <GuideBeat>[
    GuideBeat(
      title: 'You’re not dying.',
      body: 'I know it feels like that. Panic copies danger. It is not danger.',
      art: BunlyPanic.readyToHelp,
      kind: BeatKind.tap,
      action: 'Keep talking',
    ),
    GuideBeat(
      title: 'Say it with me.',
      body: '“This is a false alarm.” Tap when you’ve said it once.',
      art: BunlyPanic.staying,
      kind: BeatKind.tap,
      action: 'I said it',
    ),
    GuideBeat(
      title: 'Come back to the room.',
      body: 'Five things you can see. Real objects beat scary stories.',
      art: BunlyPanic.grounding,
      kind: BeatKind.pops,
      pops: 5,
    ),
    GuideBeat(
      title: 'Still here.',
      body: 'If it was dying, we wouldn’t be having this chat. You’re in it. I’m in it.',
      art: BunlyPanic.passed,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const thoughts = <GuideBeat>[
    GuideBeat(
      title: 'Thoughts are noisy.',
      body: 'We don’t argue with them. We give your hands something else to do.',
      art: BunlyActivities.thinking,
      kind: BeatKind.tap,
      action: 'Give me a job',
    ),
    GuideBeat(
      title: 'Park the star.',
      body: 'Drag it into the circle. One thought can wait while you do this.',
      art: BunlyPoses.huggingStar,
      kind: BeatKind.drag,
    ),
    GuideBeat(
      title: 'Let the music hold you.',
      body: 'Close your eyes. Thoughts can walk by. You don’t have to follow.',
      art: BunlyEmotions.content,
      kind: BeatKind.listen,
      action: 'I’m back',
    ),
    GuideBeat(
      title: 'See? You can pause them.',
      body: 'They may come back. That’s okay. You already came back once.',
      art: BunlyInsights.discovery,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const unreal = <GuideBeat>[
    GuideBeat(
      title: 'The room got weird.',
      body: 'That’s dissociation. You’re not disappearing. You’re just far for a minute.',
      art: BunlyInsights.analyzing,
      kind: BeatKind.tap,
      action: 'Bring me back',
    ),
    GuideBeat(
      title: 'Touch four real things.',
      body: 'Phone. Shirt. Floor. Air. Tap each time you feel one.',
      art: BunlyPanic.grounding,
      kind: BeatKind.pops,
      pops: 4,
    ),
    GuideBeat(
      title: 'Feet. Heavy.',
      body: 'Press down. The floor is not a feeling. It’s a fact.',
      art: BunlyJourney.firstStep,
      kind: BeatKind.tap,
      action: 'I feel the floor',
    ),
    GuideBeat(
      title: 'Welcome back.',
      body: 'A little closer is enough. We can do another round later.',
      art: BunlyEmotions.happy,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static const sit = <GuideBeat>[
    GuideBeat(
      title: 'We can just sit.',
      body: 'No fixing. I’ll stay on this side of the room with you.',
      art: BunlyPoses.sitting,
      kind: BeatKind.tap,
      action: 'Stay',
    ),
    GuideBeat(
      title: 'A small breath if you want.',
      body: 'Only if it feels kind. Hold, then let go.',
      art: BunlyEmotions.content,
      kind: BeatKind.hold,
    ),
    GuideBeat(
      title: 'Listen for a bit.',
      body: 'Close your eyes. I’m not going anywhere.',
      art: BunlyPanic.easing,
      kind: BeatKind.listen,
      action: 'Thank you',
    ),
    GuideBeat(
      title: 'Whenever you’re ready.',
      body: 'Sitting together counts as help. Really.',
      art: BunlyPoses.proud,
      kind: BeatKind.tap,
      action: 'I’m okay now',
    ),
  ];

  static List<GuideBeat> withPersonal(
    List<GuideBeat> beats, {
    required String note,
    required String help,
  }) {
    final extra = <GuideBeat>[];
    final fromYou = note.trim();
    final usual = help.trim();
    if (fromYou.isNotEmpty) {
      extra.add(
        GuideBeat(
          title: 'From you.',
          body: fromYou,
          art: BunlyPoses.huggingStar,
          kind: BeatKind.tap,
          action: 'I hear it',
        ),
      );
    }
    if (usual.isNotEmpty) {
      extra.add(
        GuideBeat(
          title: 'What usually helps.',
          body: usual,
          art: BunlyPanic.staying,
          kind: BeatKind.tap,
          action: 'I’ll try that',
        ),
      );
    }
    if (extra.isEmpty) return beats;
    if (beats.isEmpty) return extra;
    return [beats.first, ...extra, ...beats.skip(1)];
  }
}

class HelpTopic {
  const HelpTopic({
    required this.label,
    required this.beats,
    this.tracksPanic = false,
  });

  final String label;
  final List<GuideBeat> beats;
  final bool tracksPanic;
}

abstract final class HelpMenu {
  static const topics = <HelpTopic>[
    HelpTopic(label: 'My heart is racing', beats: GuideBooks.heart, tracksPanic: true),
    HelpTopic(label: 'I can’t get a full breath', beats: GuideBooks.breath, tracksPanic: true),
    HelpTopic(label: 'I feel like I’m dying', beats: GuideBooks.dying, tracksPanic: true),
    HelpTopic(label: 'My thoughts won’t stop', beats: GuideBooks.thoughts),
    HelpTopic(label: 'I feel far away', beats: GuideBooks.unreal, tracksPanic: true),
    HelpTopic(label: 'Just sit with me', beats: GuideBooks.sit),
  ];
}
