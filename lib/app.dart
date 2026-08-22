import 'package:flutter/material.dart';

import 'core/platform/native_chrome.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class BunlyApp extends StatefulWidget {
  const BunlyApp({super.key});

  @override
  State<BunlyApp> createState() => _BunlyAppState();
}

class _BunlyAppState extends State<BunlyApp> {
  @override
  void initState() {
    super.initState();
    NativeChrome.navigatorKey = appNavigatorKey;
    NativeChrome.bind();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunly',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
