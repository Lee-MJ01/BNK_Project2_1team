package kr.co.api.backend.voice.service;

import kr.co.api.backend.voice.dto.VoiceReqDTO;
import kr.co.api.backend.service.QTypeClassifierService;
import kr.co.api.backend.voice.domain.VoiceIntent;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class VoiceIntentClassifierService {
    private final QTypeClassifierService gptService;

    public VoiceIntent classify(VoiceReqDTO req) {
        String text = req.getText() == null ? "" : req.getText().trim();
        String dpstId = req.getDpstId();

        VoiceIntent ruleIntent = classifyByRule(text, dpstId);
        if (ruleIntent != null) return ruleIntent;

        return classifyByGPT(text);
    }

    private VoiceIntent classifyByRule(String text, String dpstId) {

        // 1) 제어 intent 우선
        if (containsAny(text, "취소", "그만", "종료")) return VoiceIntent.REQ_CANCEL;
        if (containsAny(text, "뒤로", "돌아가", "이전")) return VoiceIntent.REQ_BACK;

        // 2) 긍/부정
        if (isAnyOf(text, "응", "그래", "네", "예", "맞아", "확인")) return VoiceIntent.AFFIRM;
        if (isAnyOf(text, "아니", "싫어", "아냐", "그건아냐", "거절")) return VoiceIntent.DENY;

        // 3) 업무 intent
        if (containsAny(text, "추천", "추천해", "추천해줘")) return VoiceIntent.REQ_RECOMMEND;
        if (containsAny(text, "다른", "다른거", "다른상품")) return VoiceIntent.REQ_OTHER;

        if (containsAny(text, "설명", "뭐야", "알려줘", "자세히")) return VoiceIntent.REQ_EXPLAIN;
        if (containsAny(text, "가입", "신청", "개설")) return VoiceIntent.REQ_JOIN;

        return null;
    }

    private VoiceIntent classifyByGPT(String text) {
        try {
            return gptService.detectVoiceIntent(text);
        } catch (Exception e) {
            return VoiceIntent.UNKNOWN;
        }
    }

    private boolean containsAny(String text, String... keys) {
        for (String k : keys) {
            if (text.contains(k)) return true;
        }
        return false;
    }

    private boolean isAnyOf(String text, String... exact) {
        for (String k : exact) {
            if (text.equals(k)) return true;
        }
        return false;
    }
}
