// voice_script_resolver.dart


import 'package:test_main/voice/script/voice_ssml_templates.dart';

import '../core/voice_intent.dart';
import '../core/voice_state.dart';

class VoiceScriptResolver {
  static String? resolve({
    required VoiceState state,
    Intent? intent,
    String? noticeCode,
    String? productName,
  }) {
    // 1️⃣ noticeCode 우선 (가드/에러/재요청)
    if (noticeCode != null) {
      switch (noticeCode) {
        case 'RETRY_UNKNOWN':
          return "잘 못 알아들었어요. 다시 말씀해 주세요.";
        case 'NEED_PRODUCT':
          return "먼저 상품을 선택해 주세요.";
        case 'PRODUCT_IMMUTABLE_VIOLATION':
          return "진행 중인 상품이 변경되었어요. 처음부터 다시 진행할게요.";
      }
    }

    // 2️⃣ intent + state 조합
    if (intent != null) {
      switch (intent) {
        case Intent.reqExplain:
          return "추가로 설명드릴게요.";
        case Intent.reqJoin:
          return "이 상품에 가입을 진행할까요?";
        default:
          break;
      }
    }

    // 3️⃣ 기본 state 스크립트 (지금 코드 거의 그대로)
    switch (state) {
      case VoiceState.s0Idle:
        return VoiceSsmlTemplates.greeting();

      case VoiceState.s1Recommend:
        return "원하시는 예금을 추천해 드릴게요.";

      case VoiceState.s2ProductExplain:
        return productName != null
            ? "$productName 상품에 대해 설명드릴게요."
            : "선택하신 상품을 설명해 드릴게요.";

      case VoiceState.s3JoinConfirm:
        return "이 상품에 가입하시겠어요?";

      case VoiceState.s4Terms:
        return "가입을 위해 약관 동의가 필요해요.";

      case VoiceState.s4Input:
        return "가입 금액과 기간을 말씀해 주세요.";

      case VoiceState.s4Confirm:
        return "입력하신 내용을 확인해 주세요.";

      case VoiceState.s4Signature:
        return "전자서명을 진행할게요.";

      case VoiceState.s5End:
        return "이용해 주셔서 감사합니다.";

      default:
        return null;
    }
  }
}
