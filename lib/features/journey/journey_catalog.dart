import 'dart:convert';

import 'package:flutter/services.dart';

class JourneyChoice {
  const JourneyChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class JourneyBeat {
  const JourneyBeat({
    required this.kind,
    required this.title,
    required this.body,
    required this.art,
    this.action = 'Continue',
    this.save = '',
    this.pops = 4,
    this.low = 'Low',
    this.high = 'High',
    this.choices = const [],
    this.popLabels = const [],
  });

  final String kind;
  final String title;
  final String body;
  final String art;
  final String action;
  final String save;
  final int pops;
  final String low;
  final String high;
  final List<JourneyChoice> choices;
  final List<String> popLabels;

  factory JourneyBeat.fromJson(Map<String, dynamic> json) {
    final raw = json['choices'] as List? ?? const [];
    return JourneyBeat(
      kind: json['kind'] as String? ?? 'read',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      art: json['art'] as String? ?? '',
      action: json['action'] as String? ?? 'Continue',
      save: json['save'] as String? ?? '',
      pops: json['pops'] as int? ?? 4,
      low: json['low'] as String? ?? 'Low',
      high: json['high'] as String? ?? 'High',
      popLabels: [
        for (final item in json['popLabels'] as List? ?? const [])
          item.toString(),
      ],
      choices: [
        for (final item in raw)
          if (item is Map)
            JourneyChoice(
              id: '${item['id'] ?? ''}',
              label: '${item['label'] ?? ''}',
            )
          else
            JourneyChoice(id: item.toString(), label: item.toString()),
      ],
    );
  }
}

class JourneySession {
  const JourneySession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.claim,
    required this.beats,
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final String claim;
  final List<JourneyBeat> beats;

  factory JourneySession.fromJson(Map<String, dynamic> json) {
    return JourneySession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 8,
      claim: json['claim'] as String? ?? 'Claim',
      beats: [
        for (final item in json['beats'] as List? ?? const [])
          JourneyBeat.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}

class JourneyReminder {
  const JourneyReminder({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  factory JourneyReminder.fromJson(Map<String, dynamic> json) {
    return JourneyReminder(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class JourneyLessonPage {
  const JourneyLessonPage({required this.title, required this.body});

  final String title;
  final String body;

  factory JourneyLessonPage.fromJson(Map<String, dynamic> json) {
    return JourneyLessonPage(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class JourneyLesson {
  const JourneyLesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.pages,
  });

  final String id;
  final String title;
  final int minutes;
  final List<JourneyLessonPage> pages;

  factory JourneyLesson.fromJson(Map<String, dynamic> json) {
    return JourneyLesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 4,
      pages: [
        for (final item in json['pages'] as List? ?? const [])
          JourneyLessonPage.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}

class JourneyCatalog {
  const JourneyCatalog({
    required this.sessions,
    required this.reminders,
    required this.lessons,
  });

  final List<JourneySession> sessions;
  final List<JourneyReminder> reminders;
  final List<JourneyLesson> lessons;

  static JourneyCatalog? _cache;

  static Future<JourneyCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/journey/path.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = JourneyCatalog(
      sessions: [
        for (final item in json['sessions'] as List? ?? const [])
          JourneySession.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
      reminders: [
        for (final item in json['reminders'] as List? ?? const [])
          JourneyReminder.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
      lessons: [
        for (final item in json['lessons'] as List? ?? const [])
          JourneyLesson.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
    return _cache!;
  }

  JourneySession? session(String id) {
    for (final item in sessions) {
      if (item.id == id) return item;
    }
    return null;
  }

  JourneyLesson? lesson(String id) {
    for (final item in lessons) {
      if (item.id == id) return item;
    }
    return null;
  }

  JourneyReminder reminderForToday() {
    if (reminders.isEmpty) {
      return const JourneyReminder(
        id: 'here',
        title: 'I’m here',
        body: 'Practice while you’re safe.',
      );
    }
    final index = DateTime.now().day % reminders.length;
    return reminders[index];
  }
}
