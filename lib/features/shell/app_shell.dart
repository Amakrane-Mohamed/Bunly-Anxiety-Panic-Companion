import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/platform/native_chrome.dart';
import '../../core/platform/widget_bridge.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../insights/insights_screen.dart';
import '../journey/journey_screen.dart';
import '../panic/panic_entry_sheet.dart';
import '../today/today_screen.dart';
import '../you/you_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _attached = false;

  @override
  void initState() {
    super.initState();
    NativeChrome.tabIndex.addListener(_onTab);
    WidgetBridge.onOpened = _openFromWidget;
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  @override
  void dispose() {
    if (WidgetBridge.onOpened == _openFromWidget) {
      WidgetBridge.onOpened = null;
    }
    NativeChrome.tabIndex.removeListener(_onTab);
    super.dispose();
  }

  Future<void> _attach() async {
    if (_attached) return;
    _attached = true;
    await NativeChrome.hideTabs();
    await NativeChrome.attach();
    final store = AppStore.instance;
    await WidgetBridge.sync(
      hearts: store.hearts,
      streak: store.checkInStreak,
      line: store.bunlyLine,
      practicedToday: store.practicedOn(AppStore.dateOnly(DateTime.now())),
    );
    final pending = WidgetBridge.pending;
    if (pending != null) {
      WidgetBridge.pending = null;
      _openFromWidget(pending);
    }
  }

  void _openFromWidget(String host) {
    NativeChrome.setTab(0);
    if (host != 'sos') return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PanicEntrySheet.sos(context);
    });
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.home,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ColoredBox(
        color: AppColors.home,
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
