import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../store/app_store.dart';

abstract final class AppAudio {
  static final AudioPlayer _click = AudioPlayer();
  static final AudioPlayer _music = AudioPlayer();
  static final AudioPlayer _win = AudioPlayer();

  static var _ready = false;
  static var _musicOn = false;

  static bool get _muted => AppStore.instance.silentMode;

  static Future<void> _ensure() async {
    if (_ready) return;
    final ctx = AudioContextConfig(
      respectSilence: false,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    await AudioPlayer.global.setAudioContext(ctx);
    await _click.setAudioContext(ctx);
    await _music.setAudioContext(ctx);
    await _win.setAudioContext(ctx);
    await _click.setReleaseMode(ReleaseMode.stop);
    await _win.setReleaseMode(ReleaseMode.stop);
    await _music.setReleaseMode(ReleaseMode.loop);
    await _click.setVolume(1);
    await _win.setVolume(0.85);
    await _music.setVolume(0.18);
    _ready = true;
  }

  static Future<void> _playClick(String path, {double volume = 1}) async {
    if (_muted) return;
    try {
      await _ensure();
      await _click.setVolume(volume);
      await _click.stop();
      await _click.play(AssetSource(path));
    } catch (error) {
      debugPrint('Click sound failed: $error');
    }
  }

  static Future<void> answer() => _playClick('audio/answer.mp3');

  static Future<void> tap() => _playClick('audio/tap.mp3', volume: 0.7);

  static Future<void> win() async {
    if (_muted) return;
    try {
      await _ensure();
      await _win.stop();
      await _win.play(AssetSource('audio/win.mp3'));
    } catch (error) {
      debugPrint('Win sound failed: $error');
    }
  }

  static Future<void> startMusic() async {
    if (_muted) return;
    try {
      await _ensure();
      if (_musicOn) return;
      _musicOn = true;
      await _music.play(AssetSource('audio/calm.mp3'));
    } catch (error) {
      _musicOn = false;
      debugPrint('Calm music failed: $error');
    }
  }

  static Future<void> stopMusic() async {
    if (!_musicOn) return;
    _musicOn = false;
    try {
      await _music.stop();
    } catch (error) {
      debugPrint('Calm music stop failed: $error');
    }
  }

  static Future<void> syncSilent() async {
    if (_muted) {
      await stopMusic();
    } else {
      await startMusic();
    }
  }
}
