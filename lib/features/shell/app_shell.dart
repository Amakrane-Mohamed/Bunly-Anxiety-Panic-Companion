import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/access/access.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/platform/widget_bridge.dart';
import '../../core/store/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../checkin/checkin_screen.dart';
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
    Access.instance.addListener(_onAccess);
    WidgetBridge.onOpened = _openFromWidget;
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  @override
  void dispose() {
    if (WidgetBridge.onOpened == _openFromWidget) {
      WidgetBridge.onOpened = null;
    }
    Access.instance.removeListener(_onAccess);
    NativeChrome.tabIndex.removeListener(_onTab);
    super.dispose();
  }

  Future<void> _attach() async {
    if (_attached) return;
    _attached = true;
    await NativeChrome.attach();
    await NativeChrome.reveal();
    final store = AppStore.instance;
    store.syncWidgets();
    final pending = WidgetBridge.pending;
    if (pending != null) {
      WidgetBridge.pending = null;
      _openFromWidget(pending);
    }
  }

  void _openFromWidget(String host) {
    NativeChrome.setTab(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (host == 'sos') {
        PanicEntrySheet.sos(context);
        return;
      }
      if (host == 'checkin') {
        NativeChrome.push(
          context,
          AppMotion.fadeTo(const CheckInScreen()),
          title: 'Check-in',
        );
      }
    });
  }

  void _onAccess() {
    if (mounted) setState(() {});
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
