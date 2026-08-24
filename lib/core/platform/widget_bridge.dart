import 'package:flutter/services.dart';

/// iOS home-screen / Lock Screen widgets, via WidgetKit.
abstract final class WidgetBridge {
  static const _channel = MethodChannel('bunly/widget');
  static var _bound = false;
  static String? pending;
  static ValueChanged<String>? onOpened;

  static void bind() {
    if (_bound) return;
    _bound = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'opened') {
        final host = call.arguments as String? ?? '';
        pending = host;
        onOpened?.call(host);
      }
    });
  }

  static Future<void> sync({
    required int hearts,
    required int streak,
    required String line,
    required bool practicedToday,
    bool checkedInToday = false,
    String look = 'cream',
    String pose = 'sitting',
    String voice = 'bondly',
    bool showHearts = true,
    bool showStreak = true,
    String customLine = '',
    String futureNote = '',
    String sosStyle = 'sos',
    String name = '',
    String week = '0000000',
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'hearts': hearts,
        'streak': streak,
        'line': line,
        'practicedToday': practicedToday,
        'checkedInToday': checkedInToday,
        'look': look,
        'pose': pose,
        'voice': voice,
        'showHearts': showHearts,
        'showStreak': showStreak,
        'customLine': customLine,
        'futureNote': futureNote,
        'sosStyle': sosStyle,
        'name': name,
        'week': week,
      });
    } on MissingPluginException {
      // Running without the iOS host.
    } catch (_) {
      // Widget update is best-effort.
    }
  }
}
