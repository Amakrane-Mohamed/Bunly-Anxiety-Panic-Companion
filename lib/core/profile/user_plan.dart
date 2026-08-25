class UserPlan {
  UserPlan._();
  static final UserPlan instance = UserPlan._();

  String name = '';
  String pronoun = 'they';
  DateTime? birthday;
  List<String> hardest = [];
  List<String> feelsLike = [];
  List<String> wish = [];
  List<String> win = [];
  double heaviness = 0.5;
  double waiting = 0.5;
  var wantsCheckIns = false;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pronoun': pronoun,
      'birthday': birthday?.millisecondsSinceEpoch,
      'hardest': hardest,
      'feelsLike': feelsLike,
      'wish': wish,
      'win': win,
      'heaviness': heaviness,
      'waiting': waiting,
      'wantsCheckIns': wantsCheckIns,
    };
  }

  void readJson(Map<String, dynamic> json) {
    name = json['name'] as String? ?? name;
    pronoun = json['pronoun'] as String? ?? pronoun;
    final birthdayMs = json['birthday'];
    if (birthdayMs is int) {
      birthday = DateTime.fromMillisecondsSinceEpoch(birthdayMs);
    }
    hardest = _strings(json['hardest']);
    feelsLike = _strings(json['feelsLike']);
    wish = _strings(json['wish']);
    win = _strings(json['win']);
    heaviness = (json['heaviness'] as num?)?.toDouble() ?? heaviness;
    waiting = (json['waiting'] as num?)?.toDouble() ?? waiting;
    wantsCheckIns = json['wantsCheckIns'] as bool? ?? wantsCheckIns;
  }

  void reset() {
    name = '';
    pronoun = 'they';
    birthday = null;
    hardest = [];
    feelsLike = [];
    wish = [];
    win = [];
    heaviness = 0.5;
    waiting = 0.5;
    wantsCheckIns = false;
  }

  static List<String> _strings(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  String get displayName {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'friend' : trimmed;
  }

  String get firstName {
    if (displayName == 'friend') return displayName;
    return displayName.split(RegExp(r'\s+')).first;
  }

  String get hardestLine => _join(hardest, 'Stopping panic when it starts');
  String get wishLine => _join(wish, 'You’re safe. This will pass.');
  String get winLine => _join(win, 'More peace and calm');
  String get feelLine => _join(feelsLike, 'Panic or sudden fear');

  String get startFocus {
    final key = hardest.isNotEmpty ? hardest.first : '';
    return switch (key) {
      'Stopping panic when it starts' =>
        'A short calm the moment a wave starts',
      'Calming my thoughts' => 'Slowing the mind, one breath at a time',
      'Feeling safe in my body' => 'Grounding, so your body can feel safer',
      'Handling stress' => 'Small resets when stress starts to build',
      'Feeling like myself again' => 'Coming back to yourself, gently',
      _ => 'A short calm when a wave starts',
    };
  }

  String get breathCue {
    if (wish.contains('Breathe with me.')) return 'Breathe with me.';
    return wishLine;
  }

  String get paywallPromise {
    final key = win.isNotEmpty ? win.first : '';
    return switch (key) {
      'Fewer panic waves' => 'Fewer waves — and a friend when they come',
      'More peace and calm' => 'More peace, in the moments that matter',
      'Feeling in control of my body' =>
        'A body that can feel like yours again',
      'A little more energy' => 'A little more energy, without forcing it',
      'Feeling like myself' => 'Coming back to yourself, one calm at a time',
      _ => 'A companion that stays when a wave hits',
    };
  }

  String _join(List<String> items, String fallback) {
    if (items.isEmpty) return fallback;
    if (items.length == 1) return items.first;
    return '${items.first} · ${items[1]}';
  }
}
