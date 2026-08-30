import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Talks to the real UIKit tab bar. There is no native navigation bar.
abstract final class NativeChrome {
  static const _channel = MethodChannel('bunly/native_chrome');
  static final tabIndex = ValueNotifier<int>(0);
  static var _coverCount = 0;

  static const titles = ['Today', 'Insights', 'Journey', 'You'];

  static bool get isCupertino => !kIsWeb && Platform.isIOS;

  static Future<void> bind() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'tabSelected') {
        tabIndex.value = call.arguments as int? ?? 0;
      }
    });
  }

  static Future<void> _invoke(String method, [dynamic arguments]) async {
    if (!isCupertino) return;
    try {
      await _channel.invokeMethod(method, arguments);
    } on MissingPluginException {
      // Engine not ready yet, or running without the iOS host.
    }
  }

  static Future<void> attach() => _invoke('attach');

  static Future<void> hideTabs() {
    return _invoke('setVisible', {'nav': false, 'tab': false});
  }

  /// Drops overlay covers and hides chrome. Used after wiping on-device data.
  static Future<void> resetHidden() async {
    _coverCount = 0;
    await hideTabs();
  }

  static Future<void> setTab(int index) {
    tabIndex.value = index;
    return _invoke('setTab', index);
  }

  static Future<void> reveal() {
    if (_coverCount > 0) return Future.value();
    return _invoke('setVisible', {'nav': false, 'tab': true});
  }

  static Future<T?> push<T>(
    BuildContext context,
    Route<T> route, {
    required String title,
  }) async {
    await hideForPanic();
    if (!context.mounted) return null;
    try {
      return await Navigator.of(context, rootNavigator: true).push(route);
    } finally {
      await showRoot();
    }
  }

  static Future<void> hideForPanic() {
    _coverCount++;
    return _invoke('setVisible', {'nav': false, 'tab': false});
  }

  static Future<void> showRoot() async {
    if (_coverCount > 0) _coverCount--;
    if (_coverCount > 0) return;
    await reveal();
  }
}
