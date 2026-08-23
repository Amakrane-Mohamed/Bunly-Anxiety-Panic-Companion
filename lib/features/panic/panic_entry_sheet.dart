import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/app_audio.dart';
import '../../core/motion/app_motion.dart';
import '../../core/platform/native_chrome.dart';
import '../../core/store/app_store.dart';
import 'guide_beats.dart';
import 'guide_screen.dart';
import 'help_picker_screen.dart';

abstract final class PanicEntrySheet {
  static Future<void> sos(BuildContext context) {
    return _open(context, () {
      final episode = AppStore.instance.startPanic(comingOn: false);
      return GuideScreen(
        beats: GuideBooks.withPersonal(
          GuideBooks.sos,
          note: AppStore.instance.futureNote,
          help: AppStore.instance.helpsMe,
        ),
        episode: episode,
        recover: true,
      );
    });
  }

  static Future<void> help(BuildContext context) {
    return _open(context, () => const HelpPickerScreen());
  }

  static Future<void> coming(BuildContext context) {
    return _open(context, () {
      final episode = AppStore.instance.startPanic(comingOn: true);
      return GuideScreen(
        beats: GuideBooks.withPersonal(
          GuideBooks.coming,
          note: AppStore.instance.futureNote,
          help: AppStore.instance.helpsMe,
        ),
        episode: episode,
        recover: true,
      );
    });
  }

  static Future<void> show(
    BuildContext context, {
    bool comingOn = false,
  }) {
    return comingOn ? coming(context) : help(context);
  }

  static Future<void> _open(
    BuildContext context,
    Widget Function() page,
  ) async {
    HapticFeedback.heavyImpact();
    await NativeChrome.hideForPanic();
    await AppAudio.startMusic();
    if (!context.mounted) {
      await NativeChrome.showRoot();
      return;
    }
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(AppMotion.fadeTo(page()));
    await NativeChrome.showRoot();
    await AppAudio.stopMusic();
  }
}
