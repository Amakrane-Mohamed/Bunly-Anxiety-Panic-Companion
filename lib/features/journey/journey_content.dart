import 'package:flutter/cupertino.dart';

import '../../core/constants/app_assets.dart';

class JourneyScare {
  const JourneyScare({
    required this.id,
    required this.title,
    required this.hint,
    required this.sip,
    required this.icon,
  });

  final String id;
  final String title;
  final String hint;
  final String sip;
  final IconData icon;
}

class LifeInch {
  const LifeInch({
    required this.id,
    required this.title,
    required this.hint,
    required this.icon,
    required this.steps,
  });

  final String id;
  final String title;
  final String hint;
  final IconData icon;
  final List<String> steps;
}

class AskItem {
  const AskItem({
    required this.prompt,
    required this.choices,
  });

  final String prompt;
  final List<String> choices;
}

enum PlayKind { tap, hold, pops, drag, choice }

class PlayBeat {
  const PlayBeat({
    required this.title,
    required this.body,
    required this.art,
    required this.kind,
    this.action = 'Continue',
    this.pops = 4,
    this.choices = const [],
    this.popLabels = const [],
  });

  final String title;
  final String body;
  final String art;
  final PlayKind kind;
  final String action;
  final int pops;
  final List<String> choices;
  final List<String> popLabels;
}

abstract final class JourneyContent {
  static const scares = [
    JourneyScare(
      id: 'heart',
      title: 'This heartbeat',
      hint: 'Loud. Dramatic. Very extra.',
      sip: 'Sip the heartbeat',
      icon: CupertinoIcons.heart_fill,
    ),
    JourneyScare(
      id: 'breath',
      title: 'This breath',
      hint: 'Like it forgot its job.',
      sip: 'Sip the breath',
      icon: CupertinoIcons.wind,
    ),
    JourneyScare(
      id: 'dizzy',
      title: 'This spinny head',
      hint: 'The room doing a little jazz.',
      sip: 'Find the floor again',
      icon: CupertinoIcons.arrow_2_circlepath,
    ),
    JourneyScare(
      id: 'far',
      title: 'This far-away feeling',
      hint: 'You, behind glass.',
      sip: 'Come back to the edges',
      icon: CupertinoIcons.sparkles,
    ),
  ];

  static const inches = [
    LifeInch(
      id: 'coffee',
      title: 'The coffee I ghosted',
      hint: 'One sip. Not a personality.',
      icon: CupertinoIcons.circle_fill,
      steps: [
        'Stand up. That’s the whole first move.',
        'Pour it, or order it. Stay for the wait.',
        'Take one sip. Then you can leave.',
      ],
    ),
    LifeInch(
      id: 'walk',
      title: 'A tiny walk',
      hint: 'To the corner and back. That’s a country.',
      icon: CupertinoIcons.location_fill,
      steps: [
        'Shoes on. Door in sight.',
        'Walk to the corner, or the end of the hall.',
        'Come back. Same door. You did a loop.',
      ],
    ),
    LifeInch(
      id: 'aisle',
      title: 'One aisle',
      hint: 'Cereal counts as bravery.',
      icon: CupertinoIcons.square_grid_2x2_fill,
      steps: [
        'Go in. You don’t have to buy anything.',
        'Walk one aisle. Read one label if you want.',
        'Leave when you want. That’s allowed.',
      ],
    ),
    LifeInch(
      id: 'text',
      title: 'The text I keep rewriting',
      hint: 'Send the boring version.',
      icon: CupertinoIcons.paperplane_fill,
      steps: [
        'Open the chat. Don’t write yet.',
        'Type the boring version. No essay.',
        'Send it. Or save it. Either is an inch.',
      ],
    ),
  ];

  static const _asks = [
    AskItem(
      prompt: 'When the scare shows up, what do you usually do first?',
      choices: [
        'Scan my body for danger',
        'Leave whatever I’m doing',
        'Wait and hope it passes',
      ],
    ),
    AskItem(
      prompt: 'What would “safe enough” look like for twenty seconds?',
      choices: [
        'Hand on my chest',
        'Feet heavy on the floor',
        'Name one colour in the room',
      ],
    ),
    AskItem(
      prompt: 'If it comes back this week, what’s the plan?',
      choices: [
        'Sip it like today’s practice',
        'Stay one extra minute',
        'Use SOS if I need a voice',
      ],
    ),
    AskItem(
      prompt: 'What have you been skipping because of the next-wave fear?',
      choices: [
        'Leaving the house',
        'Being alone with my body',
        'Plans I already said yes to',
      ],
    ),
    AskItem(
      prompt: 'Which thought is the loudest one today?',
      choices: [
        'What if it happens in public',
        'What if this time it’s real',
        'What if I can’t get back',
      ],
    ),
    AskItem(
      prompt: 'After a wave, what do you need from Bondly?',
      choices: [
        'Just sit here. No pep talk.',
        'Help me name what happened',
        'A tiny next step, not a speech',
      ],
    ),
  ];

  static JourneyScare scareById(String id) {
    return scares.firstWhere(
      (item) => item.id == id,
      orElse: () => scares.first,
    );
  }

  static LifeInch inchById(String id) {
    return inches.firstWhere(
      (item) => item.id == id,
      orElse: () => inches.first,
    );
  }

  static List<AskItem> asksForToday() {
    final seed = DateTime.now().weekday + DateTime.now().day;
    final start = seed % _asks.length;
    return [
      _asks[start % _asks.length],
      _asks[(start + 2) % _asks.length],
      _asks[(start + 4) % _asks.length],
    ];
  }

  static List<PlayBeat> beatsFor(String scareId) {
    return switch (scareId) {
      'breath' => _breath,
      'dizzy' => _dizzy,
      'far' => _far,
      _ => _heart,
    };
  }

  static const _heart = [
    PlayBeat(
      title: 'We’re going to sip it.',
      body:
          'Not wait for it to shout. A little heartbeat, on purpose, while you’re safe.',
      art: BunlyJourney.firstStep,
      kind: PlayKind.tap,
      action: 'I’m ready',
    ),
    PlayBeat(
      title: 'Hand on your chest.',
      body:
          'Hold to breathe in. Let go for a long out. Feel the thump under your palm — loud is allowed.',
      art: BunlyPanic.breathing,
      kind: PlayKind.hold,
    ),
    PlayBeat(
      title: 'Count six beats.',
      body:
          'Tap once per beat. Don’t speed it up. You’re meeting it, not racing it.',
      art: BunlyJourney.growth,
      kind: PlayKind.pops,
      pops: 6,
    ),
    PlayBeat(
      title: 'What did it do?',
      body: 'There’s no right answer. We’re collecting what your body actually does.',
      art: BunlyActivities.thinking,
      kind: PlayKind.choice,
      choices: ['Got louder', 'Stayed the same', 'Quieted a bit'],
    ),
    PlayBeat(
      title: 'You’ve already met it.',
      body:
          'If it comes back tomorrow, it’s the same heartbeat. Not a stranger. Not a test.',
      art: BunlyJourney.encouragement,
      kind: PlayKind.tap,
      action: 'That’s enough for today',
    ),
  ];

  static const _breath = [
    PlayBeat(
      title: 'The breath forgot its job.',
      body:
          'We’re going to give it a tiny one. Not a perfect inhale. Just air that arrives.',
      art: BunlyJourney.firstStep,
      kind: PlayKind.tap,
      action: 'Let’s try',
    ),
    PlayBeat(
      title: 'Breathe with me.',
      body:
          'Hold the circle to breathe in. Let go. The out can be longer than the in. That’s the medicine.',
      art: BunlyPanic.breathing,
      kind: PlayKind.hold,
    ),
    PlayBeat(
      title: 'Four slow puffs.',
      body: 'Tap each one as the air leaves. Soft. No performance.',
      art: BunlyJourney.growth,
      kind: PlayKind.pops,
      pops: 4,
      popLabels: ['One', 'Two', 'Three', 'Four'],
    ),
    PlayBeat(
      title: 'Did air arrive?',
      body: 'Even a little counts. The scare hates evidence.',
      art: BunlyActivities.thinking,
      kind: PlayKind.choice,
      choices: ['Yes', 'A little', 'Not yet'],
    ),
    PlayBeat(
      title: 'Same breath tomorrow.',
      body:
          'If it snags again, you’ve already practiced the un-snag. That’s the whole point.',
      art: BunlyJourney.encouragement,
      kind: PlayKind.tap,
      action: 'That’s enough for today',
    ),
  ];

  static const _dizzy = [
    PlayBeat(
      title: 'The room did a little jazz.',
      body:
          'We’re going to give your eyes and feet a job. Spinny is a feeling. Floor is a fact.',
      art: BunlyJourney.firstStep,
      kind: PlayKind.tap,
      action: 'Find the floor',
    ),
    PlayBeat(
      title: 'Park the star.',
      body: 'Drag it into the circle. One small reorient. That’s a whole nervous system update.',
      art: BunlyPoses.huggingStar,
      kind: PlayKind.drag,
    ),
    PlayBeat(
      title: 'Name four stable things.',
      body: 'A corner. A light. Your sleeve. Me. Tap each one when you see it.',
      art: BunlyPanic.grounding,
      kind: PlayKind.pops,
      pops: 4,
      popLabels: ['Corner', 'Light', 'Sleeve', 'Bondly'],
    ),
    PlayBeat(
      title: 'Is the room still moving?',
      body: 'Honest answer. We’re not arguing with the feeling.',
      art: BunlyActivities.thinking,
      kind: PlayKind.choice,
      choices: ['A bit', 'Mostly still', 'It settled'],
    ),
    PlayBeat(
      title: 'You found still.',
      body:
          'Next time the jazz starts, you’ll remember the floor was here the whole time.',
      art: BunlyJourney.encouragement,
      kind: PlayKind.tap,
      action: 'That’s enough for today',
    ),
  ];

  static const _far = [
    PlayBeat(
      title: 'You, behind glass.',
      body:
          'We’re going to touch three real edges. Colour. Shape. Sound. Un-ghost yourself on purpose.',
      art: BunlyJourney.firstStep,
      kind: PlayKind.tap,
      action: 'Come closer',
    ),
    PlayBeat(
      title: 'Three things that are here.',
      body: 'Tap when you notice each one. Slow is the point.',
      art: BunlyActivities.thinking,
      kind: PlayKind.pops,
      pops: 3,
      popLabels: ['A colour', 'An edge', 'A sound'],
    ),
    PlayBeat(
      title: 'A quiet breath in the body.',
      body: 'Hold to come in. Let go to land. You’re allowed to be in here.',
      art: BunlyPanic.breathing,
      kind: PlayKind.hold,
    ),
    PlayBeat(
      title: 'How far away now?',
      body: 'We’re measuring, not fixing.',
      art: BunlyPoses.sitting,
      kind: PlayKind.choice,
      choices: ['Still behind glass', 'A little closer', 'I’m in the room'],
    ),
    PlayBeat(
      title: 'The glass thins with practice.',
      body:
          'If the far-away feeling comes back, you’ve already found three edges once.',
      art: BunlyJourney.encouragement,
      kind: PlayKind.tap,
      action: 'That’s enough for today',
    ),
  ];
}
