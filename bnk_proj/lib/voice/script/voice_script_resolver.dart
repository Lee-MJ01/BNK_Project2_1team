// voice_script_resolver.dart


import 'package:test_main/voice/script/voice_ssml_templates.dart';

import '../core/voice_state.dart';

class VoiceScriptResolver {
  static String resolve(
      VoiceState state, {
        String? productName,
      }) {
    switch (state) {
      case VoiceState.idle:
        return VoiceSsmlTemplates.greeting();
      case VoiceState.recommend:
        return "원하시는 예금을 추천해 드릴게요.";

      case VoiceState.productExplain:
        return productName != null
            ? "$productName 상품에 대해 설명드릴게요."
            : "선택하신 상품을 설명해 드릴게요.";

      case VoiceState.joinConfirm:
        return "이 상품에 가입하시겠어요?";

      case VoiceState.s4Terms:
        return "가입을 위해 약관 동의가 필요해요.";

      case VoiceState.s4Input:
        return "가입 금액과 기간을 말씀해 주세요.";

      case VoiceState.s4Confirm:
        return "입력하신 내용을 확인해 주세요.";

      case VoiceState.s4Signature:
        return "전자서명을 진행할게요.";

      case VoiceState.end:
        return "이용해 주셔서 감사합니다.";

      default:
        return "";
    }
  }
}
