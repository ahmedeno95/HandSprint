import 'dart:async';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  static final Random _random = Random();

  static const List<String> _coinVoices = [
    'coin_1.mp3',
    'coin_2.mp3',
    'coin_3.mp3',
    'coin_4.mp3',
    'coin_5.mp3',
  ];

  static const String _jumpVoice = 'jump.mp3';

  static List<String> get _allVoices => [..._coinVoices, _jumpVoice];

  static Future<void> preload() async {
    for (final voice in _allVoices) {
      try {
        await FlameAudio.audioCache.load(voice);
      } catch (error) {
        debugPrint('Could not preload audio file "$voice": $error');
      }
    }
  }

  static void playRandomCoinVoice() {
    final voice = _coinVoices[_random.nextInt(_coinVoices.length)];
    _play(voice);
  }

  static void playJumpVoice() {
    _play(_jumpVoice);
  }

  static void _play(String voice) {
    unawaited(_playSafely(voice));
  }

  static Future<void> _playSafely(String voice) async {
    try {
      await FlameAudio.play(voice);
    } catch (error) {
      debugPrint('Could not play audio file "$voice": $error');
    }
  }
}