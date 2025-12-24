import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/end_reason.dart';
import '../core/voice_intent.dart';
import '../core/voice_res_dto.dart';
import '../core/voice_state.dart';
import '../script/voice_script_resolver.dart';
import '../service/voice_api.dart';
import '../service/voice_stt_service.dart';
import '../service/voice_tts_service.dart';
import '../ui/voice_ui_state.dart';

class VoiceSessionController {
  VoiceState _state = VoiceState.s0Idle;

  // 🔹 UI 상태
  final ValueNotifier<VoiceUiState> uiState =
  ValueNotifier(VoiceUiState.idle);

  // 🔹 음성 볼륨 (파형용)
  final ValueNotifier<double> volume =
  ValueNotifier(0.0);

  final VoiceSttService _stt;
  final VoiceTtsService _tts;
  final _uuid = Uuid();
  String _generateSessionId() {
    return _uuid.v4();
  }
  late final String _sessionId;


  VoiceSessionController({
    required VoiceSttService stt,
    required VoiceTtsService tts,
  })  : _stt = stt,
        _tts = tts;

  /// 1️⃣ 음성 세션 시작
  Future<void> start() async {
    _sessionId = _generateSessionId();

    uiState.value = VoiceUiState.speaking;
    await _playScript(initial: true);
    uiState.value = VoiceUiState.idle;
  }

  void startListening() {
    uiState.value = VoiceUiState.listening;

    _stt.startListening(
      onResult: (text) async {
        uiState.value = VoiceUiState.thinking;
        await _sendToServer(text);
      },
      onSoundLevel: (v) {
        volume.value = v;
      },
    );
  }

  void stopListening() {
    _stt.stop();
    uiState.value = VoiceUiState.idle;
  }



  /// 3️⃣ 서버에 전달
  Future<void> _sendToServer(String text) async {
    final res = await VoiceApi.process(
      sessionId: _sessionId,
      text: text,
    );

    await _handleServerResponse(res);
  }

  /// 4️⃣ 서버 응답 처리
  Future<void> _handleServerResponse(VoiceResDTO res) async {
    _state = res.currentState;

    if (res.endReason != null) {
      uiState.value = VoiceUiState.speaking;
      await _playEnd(res);
      _cleanup();
      return;
    }

    final script = VoiceScriptResolver.resolve(
      state: res.currentState,
      intent: res.intent,
      noticeCode: res.noticeCode,
    );

    if (script != null) {
      uiState.value = VoiceUiState.speaking;
      await _tts.speak(script);
    }

    uiState.value = VoiceUiState.idle;
  }


  Future<void> _playScript({bool initial = false}) async {
    final script = VoiceScriptResolver.resolve(
      state: _state,
      intent: null,
      noticeCode: initial ? 'START' : null,
    );
    if (script != null) {
      await _tts.speak(script);
    }
  }

  Future<void> _playEnd(VoiceResDTO res) async {
    String? script;

    switch (res.endReason) {
      case EndReason.completed:
        script = "예금 가입이 완료되었어요. 이용해 주셔서 감사합니다.";
        break;

      case EndReason.canceled:
        script = "진행을 취소했어요. 이용해 주셔서 감사합니다.";
        break;

      case EndReason.timeout:
        script = "시간이 초과되어 종료할게요.";
        break;

      case EndReason.error:
        script = "문제가 발생했어요. 다시 시도해 주세요.";
        break;

      default:
        script = null;
    }

    if (script != null) {
      await _tts.speak(script);
    }
  }


  void _cleanup() {
    _stt.stop();
  }

}
