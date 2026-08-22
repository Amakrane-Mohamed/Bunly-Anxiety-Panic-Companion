import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/platform/native_chrome.dart';
import '../../core/theme/app_colors.dart';
import '../insights/insights_screen.dart';
import '../journey/journey_screen.dart';
import '../today/today_screen.dart';
import '../you/you_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.chromeReady = true});

  final bool chromeReady;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _attached = false;

  @override
  void initState() {
    super.initState();
    NativeChrome.tabIndex.addListener(_onNativeTab);
    _attachChrome();
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chromeReady && !oldWidget.chromeReady) {
      NativeChrome.reveal();
    }
  }

  @override
  void dispose() {
    NativeChrome.tabIndex.removeListener(_onNativeTab);
    super.dispose();
  }

  void _attachChrome() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NativeChrome.attach();
      if (!mounted) return;
      if (widget.chromeReady) {
        await NativeChrome.reveal();
      }
    });
  }

  void _onNativeTab() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ColoredBox(
        color: AppColors.canvas,
        child: IndexedStack(
          index: NativeChrome.tabIndex.value,
          children: const [
            TodayScreen(),
            InsightsScreen(),
            JourneyScreen(),
            YouScreen(),
          ],
        ),
      ),
    );
  }
}
