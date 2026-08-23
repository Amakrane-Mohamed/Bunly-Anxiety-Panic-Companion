import 'package:flutter/foundation.dart';
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
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'hearts': hearts,
        'streak': streak,
        'line': line,
        'practicedToday': practicedToday,
      });
    } on MissingPluginException {
      // Running without the iOS host.
    } catch (_) {
      // Widget update is best-effort.
    }
  }
}
