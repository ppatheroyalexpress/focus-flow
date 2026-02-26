import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum WhiteNoiseType { none, forest, rain, waves }

class WhiteNoiseProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  WhiteNoiseType _currentType = WhiteNoiseType.none;
  double _volume = 0.5;

  WhiteNoiseType get currentType => _currentType;
  double get volume => _volume;

  WhiteNoiseProvider() {
    _player.setReleaseMode(ReleaseMode.loop);
    _precacheAssets();
  }

  Future<void> _precacheAssets() async {
    // Audioplayers handles caching automatically for AssetSource,
    // but we can ensure the player is initialized with the current volume.
    await _player.setVolume(_volume);
  }

  Future<void> setSound(WhiteNoiseType type) async {
    if (_currentType == type) return;

    _currentType = type;
    if (type == WhiteNoiseType.none) {
      await _player.stop();
    } else {
      String assetPath = 'sounds/${type.name}.mp3';
      await _player.play(AssetSource(assetPath));
      await _player.setVolume(_volume);
    }
    notifyListeners();
  }

  Future<void> resumeSound() async {
    if (_currentType != WhiteNoiseType.none) {
      String assetPath = 'sounds/${_currentType.name}.mp3';
      await _player.play(AssetSource(assetPath));
    }
  }

  Future<void> pauseSound() async {
    await _player.pause();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _player.setVolume(volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
