import 'package:flutter/material.dart';

import '../core/voice_intent.dart';
import '../core/voice_state.dart';
import '../core/voice_state_machine.dart';
import '../intent/voice_intent_classifier.dart';
import '../script/voice_script_resolver.dart';
import '../service/voice_stt_service.dart';
import '../service/voice_tts_service.dart';
import '../ui/voice_ui_state.dart';

class VoiceSessionController {
  final VoiceSttService stt;
  final VoiceTtsService tts;
  VoiceStateMachine fsm;

  final ValueNotifier<VoiceUiState> uiState =
  ValueNotifier(VoiceUiState.idle);
  final ValueNotifier<double> volume =
  ValueNotifier(0.0);

  final bool autoListenAfterTts = true;
  VoiceState _currentState = VoiceState.idle;

  VoiceSessionController({
    required this.stt,
    required this.tts,
    required this.fsm,
  }) {
    tts.onComplete(() async {
      uiState.value = VoiceUiState.idle;
      await Future.delayed(const Duration(milliseconds: 250));
      if (autoListenAfterTts && _shouldAutoListen(_currentState)) {
        startListening(fromAuto: true);
      }
    });

    final originalFsm = fsm;

    fsm = VoiceStateMachine(
      initialState: originalFsm.state,
      productCode: originalFsm.productCode,
      onStateChanged: _onStateChanged,
    );
  }

  void startSession() {
    // 세션 시작 시 FSM을 idle로 "의도적으로" 진입시킴
    fsm.enterInitial();
  }

  Future<void> _onStateChanged(VoiceState state) async {
    _currentState = state;
    final script = VoiceScriptResolver.resolve(state);
    if (script.isNotEmpty) {
      uiState.value = VoiceUiState.speaking; // ✅ 안내 중
      await tts.speak(script);
    }
  }




  void startListening({bool fromAuto = false}) {
    if (!fromAuto) tts.stop();

    stt.startListening(
      onResult: _onSpeechResult,
      onSoundLevel: (rms) {
        volume.value = rms; // ✅ 파형
      },
      onStatus: (s) {
        if (s == 'listening') {
          uiState.value = VoiceUiState.listening; // ✅ 듣고 있어요
        } else if (s == 'done' || s == 'notListening') {
          uiState.value = VoiceUiState.thinking;
        }
      },
      onError: (_) {
        uiState.value = VoiceUiState.idle;
      },
    );
  }

  void stopListening() {
    stt.stop();
    uiState.value = VoiceUiState.thinking;
  }

  void _onSpeechResult(String text) async {

    debugPrint('🎤 [STT RESULT] "$text"');

    // 네트워크 / 서버는 반드시 try-catch
    try {
      final result = await VoiceIntentClassifier.classify(text);

      debugPrint(
        '[INTENT RESULT] intent=${result.intent}, product=${result.productCode}',
      );

      if (result.productCode != null) {
        fsm = fsm.withProduct(result.productCode!);
      }

      fsm.onIntent(result.intent);

    } catch (e, s) {
      // 여기로 오면 네트워크/DNS 실패
      debugPrint('❌ [INTENT ERROR] $e');
      debugPrint('$s');

      // UI 복구
      uiState.value = VoiceUiState.idle;

      // 사용자에게 음성으로 알려주기
      tts.speak('네트워크 연결이 원활하지 않습니다.');
    }
  }


  bool _shouldAutoListen(VoiceState state) {
    return state == VoiceState.idle ||
        state == VoiceState.joinConfirm ||
        state == VoiceState.s4Input;
  }

  void _onVolume(double rms) {
    // overlay waveform 업데이트
  }
}
