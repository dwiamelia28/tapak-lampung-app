import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Musik latar bernuansa gamolan + efek suara. Semua suara dibuat sendiri
/// (lihat tools/make_audio.py), bukan rekaman lagu tradisional.
class AudioService with WidgetsBindingObserver {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();
  final ValueNotifier<bool> soundOn = ValueNotifier<bool>(true);
  bool _ready = false;
  bool _playing = false;

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      soundOn.value = prefs.getBool('sound_on') ?? true;
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(.30);
      await _sfx.setVolume(.8);
      WidgetsBinding.instance.addObserver(this);
    } catch (e) {
      debugPrint('Audio init gagal: $e');
    }
  }

  Future<void> startMusic() async {
    if (!soundOn.value || _playing) return;
    try {
      await _music.play(AssetSource('audio/gamolan_loop.mp3'));
      _playing = true;
    } catch (e) {
      debugPrint('Musik gagal diputar: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _music.stop();
    } catch (_) {}
    _playing = false;
  }

  Future<void> setSound(bool on) async {
    soundOn.value = on;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_on', on);
    } catch (_) {}
    if (on) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  /// name: sfx_correct | sfx_wrong | sfx_win | sfx_tap
  Future<void> sfx(String name) async {
    if (!soundOn.value) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/$name.mp3'));
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _music.pause();
    } else if (state == AppLifecycleState.resumed && soundOn.value && _playing) {
      _music.resume();
    }
  }
}
