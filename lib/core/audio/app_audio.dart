import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

abstract final class AppAudio {
  static final AudioPlayer _click = AudioPlayer();
  static final AudioPlayer _music = AudioPlayer();

  static var _ready = false;
  static var _musicOn = false;

  static Future<void> _ensure() async {
    if (_ready) return;
    final ctx = AudioContextConfig(
      respectSilence: false,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    await AudioPlayer.global.setAudioContext(ctx);
    await _click.setAudioContext(ctx);
    await _music.setAudioContext(ctx);
    await _click.setReleaseMode(ReleaseMode.stop);
    await _music.setReleaseMode(ReleaseMode.loop);
    await _click.setVolume(1);
    await _music.setVolume(0.18);
    _ready = true;
  }

  static Future<void> answer() async {
    try {
      await _ensure();
      await _click.setVolume(1);
      await _click.stop();
      await _click.play(AssetSource('audio/answer.mp3'));
    } catch (error) {
      debugPrint('Answer sound failed: $error');
    }
  }

  static Future<void> startMusic() async {
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
}
