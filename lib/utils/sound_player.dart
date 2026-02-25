import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSessionComplete() async {
    try {
      // Standardized to 'ding.mp3' as per user request
      await _audioPlayer.play(AssetSource('sounds/ding.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
