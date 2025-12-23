// voice_stt_service.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSttService {
  final SpeechToText _stt = SpeechToText();

  bool get isListening => _stt.isListening;
  bool _initialized = false;



  Future<void> startListening({
    required Function(String text) onResult,
    required Function(double rms) onSoundLevel,
    Function(String status)? onStatus,
    Function(Object error)? onError,
    Duration listenFor = const Duration(seconds: 8), // 최대 듣기
    Duration pauseFor = const Duration(seconds: 5),  // 침묵 종료
  }) async {
    debugPrint('[STT] startListening called');
    // 🔴 핵심 1: initialize 보장
    if (!_initialized) {

      debugPrint('[STT] initializing...');

      _initialized = await _stt.initialize(
        onStatus: onStatus,
        onError: (e) => onError?.call(e), );
      debugPrint('[STT] initialized=$_initialized');


      if (!_initialized) return; // 권한 거부 등
    }

    // 🔴 핵심 2: 그 다음에 listen
    debugPrint('[STT] listen() start');
    _stt.listen(
      localeId: 'ko_KR',
      listenFor: listenFor,
      pauseFor: pauseFor,
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      onSoundLevelChange: onSoundLevel,
    );
  }

  void stop() {
    _stt.stop();
  }
}
