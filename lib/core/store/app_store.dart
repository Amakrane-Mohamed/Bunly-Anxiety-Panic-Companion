import 'package:flutter/foundation.dart';

class DailyCheckIn {
  DailyCheckIn({required this.date, required this.mood, required this.stress});

  final DateTime date;
  final int mood;
  final int stress;
}

class PanicEpisode {
  PanicEpisode({
    required this.startedAt,
    this.endedAt,
    this.comingOn = false,
    this.intensityAfter,
  });

  final DateTime startedAt;
  DateTime? endedAt;
  final bool comingOn;
  int? intensityAfter;
}

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  final checkIns = <DailyCheckIn>[];
  final episodes = <PanicEpisode>[];
  final completedLessons = <int>{};
  var handledMoments = 0;
  var groundingCount = 0;

  bool get checkedInToday {
    final now = DateTime.now();
    return checkIns.any(
      (item) =>
          item.date.year == now.year &&
          item.date.month == now.month &&
          item.date.day == now.day,
    );
  }

  int get journeyUnlocked {
    if (completedLessons.isEmpty) return 0;
    final next = (completedLessons.reduce((a, b) => a > b ? a : b)) + 1;
    return next.clamp(0, 5);
  }

  int get panicThisMonth {
    final now = DateTime.now();
    return episodes.where((e) {
      return e.startedAt.year == now.year && e.startedAt.month == now.month;
    }).length;
  }

  String get insight {
    if (checkIns.isEmpty && episodes.isEmpty) {
      return 'A check-in today helps Bunly learn your usual days.';
    }
    if (checkedInToday) {
      return 'You checked in. That’s how patterns start to show.';
    }
    if (handledMoments > 0) {
      return 'You’ve stayed with $handledMoments ${handledMoments == 1 ? 'moment' : 'moments'}. That counts.';
    }
    return 'When a wave comes, you don’t have to figure it out alone.';
  }

  void addCheckIn({required int mood, required int stress}) {
    checkIns.removeWhere((item) {
      final now = DateTime.now();
      return item.date.year == now.year &&
          item.date.month == now.month &&
          item.date.day == now.day;
    });
    checkIns.add(
      DailyCheckIn(date: DateTime.now(), mood: mood, stress: stress),
    );
    notifyListeners();
  }

  PanicEpisode startPanic({required bool comingOn}) {
    final episode = PanicEpisode(startedAt: DateTime.now(), comingOn: comingOn);
    episodes.add(episode);
    notifyListeners();
    return episode;
  }

  void finishPanic(PanicEpisode episode, {int? intensityAfter}) {
    episode.endedAt = DateTime.now();
    episode.intensityAfter = intensityAfter;
    handledMoments += 1;
    groundingCount += 1;
    notifyListeners();
  }

  void completeLesson(int index) {
    completedLessons.add(index);
    notifyListeners();
  }

  bool hasCheckInOn(DateTime day) {
    return checkIns.any(
      (item) =>
          item.date.year == day.year &&
          item.date.month == day.month &&
          item.date.day == day.day,
    );
  }

  bool hasPanicOn(DateTime day) {
    return episodes.any(
      (item) =>
          item.startedAt.year == day.year &&
          item.startedAt.month == day.month &&
          item.startedAt.day == day.day,
    );
  }
}
