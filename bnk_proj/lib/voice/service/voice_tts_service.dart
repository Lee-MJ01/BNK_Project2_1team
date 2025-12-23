

import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

class VoiceTtsService {
  final FlutterTts _tts = FlutterTts();

  VoiceTtsService() {
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);

    _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void onComplete(VoidCallback cb) {
    _tts.setCompletionHandler(cb);
  }

  Future<void> _configure() async {
    // Android TTS 엔진 지정
    await _tts.setEngine("com.google.android.tts");

    // 한국어
    await _tts.setLanguage("ko-KR");

    await _tts.setVoice({
      "name": "ko-kr-x-ism-network",
      "locale": "ko-KR",
    });

    // 은행/ARS 톤
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
  }


}