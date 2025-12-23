import 'package:flutter/material.dart' hide Intent;
import 'package:test_main/voice/core/voice_intent.dart';
import 'package:test_main/voice/core/voice_state.dart';

import 'end_reason.dart';

class VoiceStateMachine {
  VoiceState _state;
  EndReason? _endReason;
  final String? productCode;

  final void Function(VoiceState state)? onStateChanged;

  VoiceStateMachine({
    VoiceState initialState = VoiceState.idle,
    this.productCode,
    this.onStateChanged,
  }) : _state = initialState;


  VoiceState get state => _state;
  EndReason? get endReason => _endReason;

  VoiceStateMachine withProduct(String productCode) {
    return VoiceStateMachine(
      initialState: _state,          // 현재 상태 유지
      productCode: productCode,      // 새 상품 컨텍스트
      onStateChanged: onStateChanged,
    );
  }

  bool _inputDone = false;
  void markInputDone(bool done) => _inputDone = done;

  // 상태 변경 공통 처리
  void _setState(VoiceState next) {
    _state = next;
    debugPrint('[VoiceState] -> $next');
    onStateChanged?.call(next);
  }

  void enterInitial() {
    _setState(_state); // 강제로 onStateChanged 발생
  }

  // 세션 종료
  void _end(EndReason reason) {
    _endReason = reason;
    _setState(VoiceState.end);
  }

  // 외부에서 호출하는 진입점
  void onIntent(Intent intent) {
    debugPrint('[Intent] $intent @ $_state');

    ////////////////////////////////
    // Global transitions
    ////////////////////////////////
    if (intent == Intent.reqCancel) {
      _end(EndReason.canceled);
      return;
    }

    switch (_state) {
      case VoiceState.idle:
        _handleIdle(intent);
        break;

      case VoiceState.recommend:
        _handleRecommend(intent);
        break;

      case VoiceState.productExplain:
        _handleProductExplain(intent);
        break;

      case VoiceState.joinConfirm:
        _handleJoinConfirm(intent);
        break;

      case VoiceState.s4Terms:
        _handleS4Terms(intent);
        break;

      case VoiceState.s4Input:
        _handleS4Input(intent);
        break;

      case VoiceState.s4Confirm:
        _handleS4Confirm(intent);
        break;

      case VoiceState.s4Signature:
        _handleS4Signature(intent);
        break;

      case VoiceState.end:
      // 종료 상태에서는 아무 것도 안 함
        break;
    }
  }



  // S0
  void _handleIdle(Intent intent) {
    if (intent == Intent.reqRecommend) {
      if (productCode != null) {
        _setState(VoiceState.productExplain); // 상품 컨텍스트 시작
      } else {
        _setState(VoiceState.recommend);
      }
    }
  }

  // S1
  void _handleRecommend(Intent intent) {
    switch (intent) {
      case Intent.reqExplain:
        _setState(VoiceState.productExplain);
        break;

      case Intent.reqJoin:
        _setState(VoiceState.joinConfirm);
        break;

      case Intent.reqOther:
      case Intent.reqRecommend:
      // 같은 상태 유지 (다음 추천)
        break;

      default:
        break;
    }
  }

  // S2
  void _handleProductExplain(Intent intent) {
    switch (intent) {
      case Intent.reqJoin:
        _setState(VoiceState.joinConfirm);
        break;

      case Intent.reqRecommend:
        _setState(VoiceState.recommend);
        break;

      case Intent.reqExplain:
      // 설명 반복 (상태 유지)
        break;

      default:
        break;
    }
  }

  // S3
  void _handleJoinConfirm(Intent intent) {
    switch (intent) {
      case Intent.affirm:
      case Intent.reqJoin:
        _setState(VoiceState.s4Terms);
        break;

      case Intent.deny:
      // 종료 아님 → 이전 단계로
        _setState(VoiceState.productExplain);
        break;

      case Intent.reqExplain:
        _setState(VoiceState.productExplain);
        break;

      default:
        break;
    }
  }


  // S4_term
  void _handleS4Terms(Intent intent) {
    switch (intent) {
      case Intent.confirm:
        _setState(VoiceState.s4Input);
        break;

      case Intent.deny:
      // 약관 동의 거절 → 가입 확인 단계로
        _setState(VoiceState.joinConfirm);
        break;

      case Intent.reqExplain:
      // 설명 오버레이 (상태 유지)
        break;

      default:
        break;
    }
  }

  // S4_input
  void _handleS4Input(Intent intent) {
    switch (intent) {
      case Intent.reqBack:
      // 포커스 이동만 (상태 유지)
        break;

      case Intent.proceed:
        if (_inputDone) {
          _setState(VoiceState.s4Confirm);
        }
        // else: 상태 유지 + UI에 "금액/기간을 먼저 말씀해 주세요" 안내
        break;

      case Intent.reqExplain:
      // 설명 오버레이 (상태 유지)
        break;

      default:
        break;
    }
  }

  // S4_confirm
  void _handleS4Confirm(Intent intent) {
    switch (intent) {
      case Intent.reqBack:
        _setState(VoiceState.s4Input);
        break;

      case Intent.confirm:
        _setState(VoiceState.s4Signature);
        break;

      default:
        break;
    }
  }

  // S4_signiture
  void _handleS4Signature(Intent intent) {
    if (intent == Intent.success) {
      _end(EndReason.completed);
    }
  }

}

