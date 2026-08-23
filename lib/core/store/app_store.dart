import 'package:flutter/foundation.dart';

import '../constants/app_assets.dart';
import '../platform/widget_bridge.dart';

enum CheckInSlot { morning, evening }

enum DayKind { none, checkIn, difficult, handled, milestone }

class DailyCheckIn {
  DailyCheckIn({
    required this.date,
    required this.mood,
    required this.stress,
    required this.slot,
  });

  final DateTime date;
  final int mood;
  final int stress;
  final CheckInSlot slot;

  String get feelingLine {
    final score = '${mood * 2}/10';
    if (stress >= 4) return 'A little tense · $score';
    final label = switch (mood) {
      1 => 'Heavy',
      2 => 'A little heavy',
      3 => 'Okay',
      4 => 'Calm',
      _ => 'Light',
    };
    return '$label · $score';
  }
}

class ThanksNote {
  ThanksNote({
    required this.id,
    required this.text,
    required this.at,
  });

  final String id;
  final String text;
  final DateTime at;
}

class PanicEpisode {
  PanicEpisode({
    required this.startedAt,
    this.endedAt,
    this.comingOn = false,
    this.intensityAfter,
    this.activity,
    this.avoiding,
    List<String>? toolsUsed,
  }) : toolsUsed = toolsUsed ?? [];

  final DateTime startedAt;
  DateTime? endedAt;
  final bool comingOn;
  int? intensityAfter;
  String? activity;
  String? avoiding;
  final List<String> toolsUsed;

  Duration? get recovery {
    final end = endedAt;
    if (end == null) return null;
    return end.difference(startedAt);
  }
}

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  @override
  void notifyListeners() {
    super.notifyListeners();
    WidgetBridge.sync(
      hearts: hearts,
      streak: checkInStreak,
      line: bunlyLine,
      practicedToday: practicedOn(dateOnly(DateTime.now())),
    );
  }

  final checkIns = <DailyCheckIn>[];
  final episodes = <PanicEpisode>[];
  final completedLessons = <int>{};
  final lessonDates = <int, DateTime>{};
  var handledMoments = 0;
  var groundingCount = 0;
  var toolUses = 0;
  var breathingFirst = true;
  var silentMode = false;
  final bondlyNotes = <String>[];
  var futureNote = '';
  var safePerson = '';
  var helpsMe = '';
  final thanksNotes = <ThanksNote>[];

  static const journeyLength = 4;
  static const _morningHourEnd = 15;

  static CheckInSlot slotFor(DateTime time) {
    return time.hour < _morningHourEnd
        ? CheckInSlot.morning
        : CheckInSlot.evening;
  }

  static bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  CheckInSlot get currentSlot => slotFor(DateTime.now());

  bool get checkedInToday => checkInsToday.isNotEmpty;

  /// Consecutive days with a check-in. Today can still be earned.
  int get checkInStreak {
    if (checkIns.isEmpty) return 0;
    final days = {
      for (final item in checkIns)
        DateTime(item.date.year, item.date.month, item.date.day),
    };
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(day)) {
      day = day.subtract(const Duration(days: 1));
      if (!days.contains(day)) return 0;
    }
    var streak = 0;
    while (days.contains(day)) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static const heartMax = 5;

  /// Hearts you hold right now, like lives. Max [heartMax].
  ///
  /// Each of the last five days holds a heart unless a wave came
  /// that you didn't stay with. Staying through a wave — or a quiet
  /// day — keeps it. Distinct from streak, which is consecutive check-ins.
  int get hearts {
    final today = dateOnly(DateTime.now());
    var held = heartMax;
    for (var i = 0; i < heartMax; i++) {
      final day = today.subtract(Duration(days: i));
      final waves = episodesOn(day);
      if (waves.isEmpty) continue;
      if (waves.any((item) => item.endedAt != null)) continue;
      held -= 1;
    }
    return held.clamp(0, heartMax);
  }

  int get checkInDaysThisWeek {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final days = <DateTime>{};
    for (final item in checkIns) {
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      if (!day.isBefore(weekStart)) days.add(day);
    }
    return days.length;
  }

  List<DailyCheckIn> get checkInsToday {
    final now = DateTime.now();
    return checkIns.where((item) => sameDay(item.date, now)).toList();
  }

  DailyCheckIn? get latestCheckIn {
    if (checkIns.isEmpty) return null;
    return checkIns.last;
  }

  DailyCheckIn? get latestCheckInToday {
    final today = checkInsToday;
    if (today.isEmpty) return null;
    return today.last;
  }

  bool hasSlotCheckIn(CheckInSlot slot, [DateTime? day]) {
    return slotCheckIn(slot, day) != null;
  }

  DailyCheckIn? slotCheckIn(CheckInSlot slot, [DateTime? day]) {
    final target = day ?? DateTime.now();
    for (var i = checkIns.length - 1; i >= 0; i--) {
      final item = checkIns[i];
      if (sameDay(item.date, target) && item.slot == slot) return item;
    }
    return null;
  }

  bool get currentSlotDone => hasSlotCheckIn(currentSlot);

  int get momentsHandledToday {
    final now = DateTime.now();
    return episodes.where((item) {
      return item.endedAt != null && sameDay(item.startedAt, now);
    }).length;
  }

  int get journeyUnlocked {
    if (completedLessons.isEmpty) return 0;
    final next = (completedLessons.reduce((a, b) => a > b ? a : b)) + 1;
    return next.clamp(0, journeyLength - 1);
  }

  int get currentLessonIndex {
    if (completedLessons.length >= journeyLength) return journeyLength - 1;
    return journeyUnlocked;
  }

  double get journeyProgress {
    return claimsToday / 4;
  }

  String? journeyScare;
  String? journeyLifeId;
  var journeyAskAnswer = '';
  final journeyClaims = <String>{};
  final journeyLessons = <String>{};
  final journeyFearOn = <String, int>{};

  static const journeyDailyIds = ['scare', 'life', 'ask', 'reminder'];

  bool claimedToday(String id, [DateTime? day]) {
    return journeyClaims.contains(_claimKey(id, day ?? DateTime.now()));
  }

  bool practicedOn(DateTime day) => claimedToday('scare', day);
  bool lifeOn(DateTime day) => claimedToday('life', day);
  bool askedOn(DateTime day) => claimedToday('ask', day);

  int? fearOn(DateTime day) => journeyFearOn[_dayKey(day)];

  int get claimsToday =>
      journeyDailyIds.where((id) => claimedToday(id)).length;

  int get practicesThisWeek {
    return weekDays.where(practicedOn).length;
  }

  int get lifeThisWeek => weekDays.where(lifeOn).length;

  int get journeyStreak {
    final days = <DateTime>{};
    for (final key in journeyClaims) {
      final parts = key.split(':');
      if (parts.length != 2) continue;
      if (parts[1] != 'scare') continue;
      days.add(_parseDayKey(parts[0]));
    }
    if (days.isEmpty) return 0;
    var day = dateOnly(DateTime.now());
    if (!days.contains(day)) {
      day = day.subtract(const Duration(days: 1));
      if (!days.contains(day)) return 0;
    }
    var streak = 0;
    while (days.contains(day)) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool lessonDone(String id) => journeyLessons.contains(id);

  void setJourneyScare(String id) {
    journeyScare = id;
    notifyListeners();
  }

  void markJourneyClaim(String id) {
    journeyClaims.add(_claimKey(id, DateTime.now()));
    if (id == 'scare') completedLessons.add(1);
    notifyListeners();
  }

  void markJourneyPractice() => markJourneyClaim('scare');

  void markJourneyLife(String id) {
    journeyLifeId = id;
    markJourneyClaim('life');
  }

  void markJourneyAsk(String answer) {
    journeyAskAnswer = answer;
    markJourneyClaim('ask');
  }

  void markLessonRead(String id) {
    journeyLessons.add(id);
    notifyListeners();
  }

  void setJourneyFear(int value) {
    journeyFearOn[_dayKey(DateTime.now())] = value.clamp(1, 5);
    notifyListeners();
  }

  String _claimKey(String id, DateTime day) => '${_dayKey(day)}:$id';

  static DateTime _parseDayKey(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  int get panicThisMonth {
    final now = DateTime.now();
    return episodes.where((e) {
      return e.startedAt.year == now.year && e.startedAt.month == now.month;
    }).length;
  }

  /// True when the latest check-in says this moment is hard.
  /// Panic is then the primary action — not a decorative dashboard button.
  bool get needsSupport {
    final last = latestCheckInToday ?? latestCheckIn;
    if (last == null) return false;
    if (!sameDay(last.date, DateTime.now())) return false;
    return last.mood <= 2 || last.stress >= 4;
  }

  bool get checkInIsPrimary => !needsSupport && !currentSlotDone;

  String get bunlyLine {
    if (needsSupport) return 'I’m here. We can take this slowly.';
    if (latestCheckInToday != null) return 'I’m here with you.';
    return 'I’m here if a wave comes.';
  }

  String? get stateLabel {
    final last = latestCheckInToday;
    if (last == null) return null;
    if (last.stress >= 4) return 'A little tense · ${last.stress}/5';
    return switch (last.mood) {
      1 => 'Heavy · ${last.mood}/5',
      2 => 'A little heavy · ${last.mood}/5',
      3 => 'Okay · ${last.mood}/5',
      _ => 'Calm · ${last.mood}/5',
    };
  }

  String get bunlyArt {
    if (needsSupport) return BunlyActivities.worried;
    final last = latestCheckInToday;
    if (last == null) return BunlyPoses.sitting;
    if (last.mood <= 2 || last.stress >= 4) return BunlyActivities.worried;
    if (last.mood >= 4) return BunlyPoses.proud;
    return BunlyEmotions.content;
  }

  String get insight {
    return noticedPattern ??
        'A check-in today helps Bunly learn your usual days.';
  }

  String get dayFooter {
    final moments = momentsHandledToday;
    final checks = checkInsToday.length;
    if (moments > 0) {
      final word = moments == 1 ? 'moment' : 'moments';
      return '$moments $word logged today. Keep learning your pattern.';
    }
    if (checks > 0) {
      final word = checks == 1 ? 'check-in' : 'check-ins';
      return '$checks $word today. Keep learning your pattern.';
    }
    return 'Two short check-ins help Bunly learn your day.';
  }

  /// Time-of-day pattern, or null until there’s enough to notice something.
  String? get noticedPattern {
    if (checkIns.length < 3 && episodes.length < 2) return null;

    final calmerEvenings = _calmerEveningsThisWeek;
    if (calmerEvenings >= 3) {
      return 'You’ve had $calmerEvenings calmer evenings this week.';
    }

    final eveningShare = _eveningDifficultyShare;
    if (eveningShare != null && eveningShare >= 0.6) {
      return 'Your difficult moments seem more common in the evening.';
    }
    if (eveningShare != null && eveningShare <= 0.35 && episodes.length >= 2) {
      return 'Mornings have been a little heavier lately.';
    }

    if (handledMoments >= 2) {
      return 'You’ve stayed with $handledMoments moments. That’s how the next one gets a little more familiar.';
    }

    if (checkIns.length >= 3) {
      return 'A few more days and evening vs morning will start to show.';
    }
    return null;
  }

  double? get _eveningDifficultyShare {
    final hardChecks = checkIns.where((c) => c.mood <= 2 || c.stress >= 4);
    final hardEpisodes = episodes;
    final hardCount = hardChecks.length + hardEpisodes.length;
    if (hardCount < 2) return null;
    final eveningHard =
        hardChecks.where((c) => c.slot == CheckInSlot.evening).length +
        hardEpisodes.where((e) => e.startedAt.hour >= _morningHourEnd).length;
    return eveningHard / hardCount;
  }

  int get _calmerEveningsThisWeek {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday % 7));
    final weekStart = DateTime(start.year, start.month, start.day);
    return checkIns.where((c) {
      if (c.slot != CheckInSlot.evening) return false;
      if (c.date.isBefore(weekStart)) return false;
      return c.mood >= 3 && c.stress <= 3;
    }).length;
  }

  void addCheckIn({required int mood, required int stress, CheckInSlot? slot}) {
    final now = DateTime.now();
    final resolved = slot ?? slotFor(now);
    checkIns.removeWhere(
      (item) => sameDay(item.date, now) && item.slot == resolved,
    );
    checkIns.add(
      DailyCheckIn(date: now, mood: mood, stress: stress, slot: resolved),
    );
    notifyListeners();
  }

  void addBondlyNote(String text) {
    final note = text.trim();
    if (note.isEmpty) return;
    bondlyNotes.add(note);
    notifyListeners();
  }

  PanicEpisode startPanic({required bool comingOn}) {
    final episode = PanicEpisode(startedAt: DateTime.now(), comingOn: comingOn);
    episodes.add(episode);
    notifyListeners();
    return episode;
  }

  void useTool(PanicEpisode episode, String tool) {
    if (episode.toolsUsed.contains(tool)) return;
    episode.toolsUsed.add(tool);
    toolUses += 1;
    notifyListeners();
  }

  void finishPanic(
    PanicEpisode episode, {
    int? intensityAfter,
    String? activity,
    String? avoiding,
  }) {
    episode.endedAt = DateTime.now();
    episode.intensityAfter = intensityAfter;
    episode.activity = activity;
    episode.avoiding = avoiding;
    handledMoments += 1;
    groundingCount += 1;
    notifyListeners();
  }

  void setBreathingFirst(bool value) {
    breathingFirst = value;
    notifyListeners();
  }

  void setSilentMode(bool value) {
    silentMode = value;
    notifyListeners();
  }

  void setFutureNote(String value) {
    futureNote = value.trim();
    notifyListeners();
  }

  void setSafePerson(String value) {
    safePerson = value.trim();
    notifyListeners();
  }

  void setHelpsMe(String value) {
    helpsMe = value.trim();
    notifyListeners();
  }

  void addThanks(String text) {
    final note = text.trim();
    if (note.isEmpty) return;
    thanksNotes.insert(
      0,
      ThanksNote(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        text: note,
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeThanks(String id) {
    thanksNotes.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  bool get wroteThanksToday {
    final now = DateTime.now();
    return thanksNotes.any((item) => sameDay(item.at, now));
  }

  void completeLesson(int index) {
    completedLessons.add(index);
    lessonDates.putIfAbsent(index, () => DateTime.now());
    notifyListeners();
  }

  bool hasCheckInOn(DateTime day) {
    return checkIns.any((item) => sameDay(item.date, day));
  }

  bool hasPanicOn(DateTime day) {
    return episodes.any((item) => sameDay(item.startedAt, day));
  }

  List<DailyCheckIn> checkInsOn(DateTime day) {
    return checkIns.where((item) => sameDay(item.date, day)).toList();
  }

  List<PanicEpisode> episodesOn(DateTime day) {
    return episodes.where((item) => sameDay(item.startedAt, day)).toList();
  }

  bool hasMilestoneOn(DateTime day) {
    if (lessonDates.values.any((date) => sameDay(date, day))) return true;
    if (checkIns.isNotEmpty && sameDay(checkIns.first.date, day)) return true;
    final handled = episodes.where((item) => item.endedAt != null);
    if (handled.isNotEmpty && sameDay(handled.first.startedAt, day)) {
      return true;
    }
    return false;
  }

  DayKind kindOn(DateTime day) {
    final dayEpisodes = episodesOn(day);
    final handled = dayEpisodes.any((item) => item.endedAt != null);
    if (handled) return DayKind.handled;
    if (dayEpisodes.isNotEmpty) return DayKind.difficult;
    if (hasMilestoneOn(day)) return DayKind.milestone;
    if (hasCheckInOn(day)) return DayKind.checkIn;
    return DayKind.none;
  }

  int get daysNamed {
    final keys = <String>{};
    for (final item in checkIns) {
      keys.add(_dayKey(item.date));
    }
    for (final item in episodes) {
      keys.add(_dayKey(item.startedAt));
    }
    return keys.length;
  }

  DateTime? get firstActivityAt {
    DateTime? first;
    void consider(DateTime date) {
      if (first == null || date.isBefore(first!)) first = date;
    }

    for (final item in checkIns) {
      consider(item.date);
    }
    for (final item in episodes) {
      consider(item.startedAt);
    }
    return first;
  }

  int showedUpDaysInMonth(DateTime month) {
    final keys = <String>{};
    for (final item in checkIns) {
      if (item.date.year == month.year && item.date.month == month.month) {
        keys.add(_dayKey(item.date));
      }
    }
    return keys.length;
  }

  int stayedWithInMonth(DateTime month) {
    return episodes.where((item) {
      return item.endedAt != null &&
          item.startedAt.year == month.year &&
          item.startedAt.month == month.month;
    }).length;
  }

  String? artForDay(DateTime day) {
    switch (kindOn(day)) {
      case DayKind.handled:
        return BunlyPoses.proud;
      case DayKind.difficult:
        return BunlyActivities.worried;
      case DayKind.milestone:
        return BunlyPoses.huggingStar;
      case DayKind.checkIn:
        final last = checkInsOn(day).last;
        if (last.mood <= 2 || last.stress >= 4) {
          return BunlyActivities.worried;
        }
        if (last.mood >= 4) return BunlyEmotions.content;
        return BunlyPoses.sitting;
      case DayKind.none:
        return null;
    }
  }

  DateTime? lastEventAt(DateTime day) {
    final times = <DateTime>[
      ...checkInsOn(day).map((item) => item.date),
      ...episodesOn(day).map((item) => item.startedAt),
    ];
    if (times.isEmpty) return null;
    times.sort();
    return times.last;
  }

  int? scoreOn(DateTime day) {
    final dayEpisodes = episodesOn(day);
    if (dayEpisodes.isNotEmpty) {
      return dayEpisodes.last.intensityAfter;
    }
    final checks = checkInsOn(day);
    if (checks.isEmpty) return null;
    return checks.last.mood;
  }

  int heatOn(DateTime day) {
    var heat = 0;
    if (hasCheckInOn(day)) heat += 1;
    if (episodesOn(day).any((item) => item.comingOn)) heat += 1;
    if (episodesOn(day).any((item) => !item.comingOn)) heat += 1;
    if (episodesOn(day).any((item) => item.endedAt != null)) heat += 1;
    return heat.clamp(0, 4);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get weekMonday {
    final today = dateOnly(DateTime.now());
    return today.subtract(Duration(days: today.weekday - 1));
  }

  List<DateTime> get weekDays {
    final monday = weekMonday;
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Monday-start grid covering [weeks] weeks, ending this week.
  List<DateTime> heatDays({int weeks = 4}) {
    final start = weekMonday.subtract(Duration(days: 7 * (weeks - 1)));
    return List.generate(weeks * 7, (i) => start.add(Duration(days: i)));
  }

  bool stayedWithOn(DateTime day) {
    return episodesOn(day).any((item) => item.endedAt != null);
  }

  bool caughtEarlyOn(DateTime day) {
    return episodesOn(day).any((item) => item.comingOn);
  }

  bool sosWaveOn(DateTime day) {
    return episodesOn(day).any((item) => !item.comingOn);
  }

  double? moodAverageOn(DateTime day) {
    final checks = checkInsOn(day);
    if (checks.isEmpty) return null;
    return checks.map((item) => item.mood).reduce((a, b) => a + b) /
        checks.length;
  }

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
}
