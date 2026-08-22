import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Talks to the real UIKit tab + navigation bars in `ios/Runner/NativeChrome.swift`.
abstract final class NativeChrome {
  static const _channel = MethodChannel('bunly/native_chrome');
  static final tabIndex = ValueNotifier<int>(0);
  static GlobalKey<NavigatorState>? navigatorKey;
  static var _coverCount = 0;

  static const titles = ['Today', 'Insights', 'Journey', 'You'];

  static bool get isCupertino => !kIsWeb && Platform.isIOS;

  static Future<void> bind() async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'tabSelected':
          final index = call.arguments as int? ?? 0;
          tabIndex.value = index;
        case 'back':
          await navigatorKey?.currentState?.maybePop();
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

  static Future<void> setTab(int index) {
    tabIndex.value = index;
    return _invoke('setTab', index);
  }

  static Future<void> setTitle(String title) => _invoke('setTitle', title);

  static Future<void> setVisible({bool nav = true, bool tab = true}) {
    return _invoke('setVisible', {'nav': nav, 'tab': tab});
  }

  static Future<void> setBack(bool visible) => _invoke('setBack', visible);

  static Future<T?> push<T>(
    BuildContext context,
    Route<T> route, {
    required String title,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    await setVisible(nav: true, tab: false);
    await setTitle(title);
    await setBack(true);
    try {
      return await navigator.push(route);
    } finally {
      await setBack(false);
      await setVisible(nav: true, tab: true);
      await setTitle(titles[tabIndex.value]);
    }
  }

  static Future<void> reveal() async {
    if (_coverCount > 0) return;
    await setBack(false);
    await setVisible(nav: true, tab: true);
    await setTitle(titles[tabIndex.value]);
  }

  static Future<void> hideForPanic() {
    _coverCount++;
    return setVisible(nav: false, tab: false);
  }

  static Future<void> showRoot() async {
    if (_coverCount > 0) _coverCount--;
    if (_coverCount > 0) return;
    await setBack(false);
    await setVisible(nav: true, tab: true);
    await setTitle(titles[tabIndex.value]);
  }
}
