import 'package:flutter/material.dart' hide Intent;
import 'package:uuid/uuid.dart';

import '../core/end_reason.dart';
import '../core/voice_intent.dart';
import '../core/voice_res_dto.dart';
import '../core/voice_state.dart';
import '../script/voice_script_resolver.dart';
import '../service/voice_api.dart';
import '../service/voice_stt_service.dart';
import '../service/voice_tts_service.dart';
import '../ui/voice_nav_command.dart';
import '../ui/voice_ui_state.dart';

class VoiceSessionController {


  VoiceState _state = VoiceState.s0Idle;
  String? _sessionId;
  bool _started = false; // idle 최초 진입 여부

  bool get isSessionActive => _sessionId != null && _started;

  final VoidCallback? onSessionEnded;



  /// UI 관련 ///

  final ValueNotifier<VoiceUiState> uiState = ValueNotifier(VoiceUiState.idle);
  final ValueNotifier<double> volume = ValueNotifier(0.0); // 음성 볼륨 (파형용)
  final ValueNotifier<VoiceNavCommand?> navCommand = ValueNotifier(null);
  ValueNotifier<VoiceResDTO?> lastResponse = ValueNotifier(null); // step2 (s4Input)용 콜백



  /// tts, stt 가져오기 ///
  
  final VoiceSttService _stt;
  final VoiceTtsService _tts;

  final _uuid = Uuid();

  String _generateSessionId() {
    return _uuid.v4();
  }

  VoiceSessionController({
    required VoiceSttService stt,
    required VoiceTtsService tts,
    this.onSessionEnded
  })  : _stt = stt,
        _tts = tts;



  /// 세션 관련 ///
  
  void attachOverlay() {
    debugPrint("### attachOverlay called started=$_started sessionId=$_sessionId state=$_state");
    if (_started) return;

    _started = true;
    _startInternal();
  }

  Future<void> _startInternal() async {
    if (_sessionId != null) return;
    _sessionId = _generateSessionId();

    uiState.value = VoiceUiState.speaking;
    await _playScript(initial: true);
    uiState.value = VoiceUiState.idle;
  }

  Future<void> endSession() async {
    _cleanup();
    onSessionEnded?.call();
  }





  /// 클라이언트 ==> 서버 ///

  Future<void> _sendToServer(String text) async {
    final res = await VoiceApi.process(
      sessionId: _sessionId!,
      text: text,
    );
    await _handleServerResponse(res);
  }

  // text 없이 intent만 보냄
  Future<void> sendClientIntent({
    required Intent intent,
    String? productCode,
    EndReason? clientEndReason,
  }) async {
    if (_sessionId == null) {
      debugPrint("### sendClientIntent ignored: no active session");
      return;
    }

    uiState.value = VoiceUiState.thinking;

    final res = await VoiceApi.process(
      sessionId: _sessionId!,
      text: "",
      intent: intent,
      productCode: productCode,
    );

    await _handleServerResponse(res);
  }



  /// 서버 ==> 클라이언트 ///

  Future<void> _handleServerResponse(VoiceResDTO res) async {
    _state = res.currentState;

    final nav = _resolveNav(res);
    if (nav != null) {
      navCommand.value = nav;
    }
    if (res.endReason != null) {
      uiState.value = VoiceUiState.speaking;
      await _playEnd(res);
      endSession();
      return;
    }
    debugPrint("### server res state=${res.currentState} intent=${res.intent} product=${res.productCode}");
    final script = VoiceScriptResolver.resolve(
      state: res.currentState,
      intent: res.intent,
      noticeCode: res.noticeCode,
    );
     debugPrint("### resolved script=$script");

    if (script != null) {
      uiState.value = VoiceUiState.speaking;
      await _tts.speak(script);
    }

    uiState.value = VoiceUiState.idle;

    lastResponse.value = res;
  }


  /// 화면 이동 ///

  VoiceNavCommand? _resolveNav(VoiceResDTO res) {
    switch (res.currentState) {
      case VoiceState.s2ProductExplain:
        if (res.productCode == null) return null;
        return VoiceNavCommand(
          type: VoiceNavType.openDepositView,
          productCode: res.productCode,
        );

      case VoiceState.s4Terms:
        if (res.productCode == null) return null;
        return VoiceNavCommand(
          type: VoiceNavType.openJoinFlow,
          productCode: res.productCode,
        );

      case VoiceState.s4Input:
        if (res.productCode == null) return null;
        return VoiceNavCommand(
          type: VoiceNavType.openInput,
          productCode: res.productCode,
        );

      case VoiceState.s4Signature:
        return VoiceNavCommand(
          type: VoiceNavType.openSignature,
        );

      default:
        return null;
    }
  }


  
  /// tts, stt 컨트롤 ///

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

  Future<void> speakClientGuide(String text) async {
    uiState.value = VoiceUiState.speaking;
    await _tts.speak(text);
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
