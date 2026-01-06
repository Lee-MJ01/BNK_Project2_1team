package kr.co.api.backend.dto.reco;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Data
public class AiRecoV2Request {
    private Long surveyId;
    private String custCode;

    // ✅ AI 서버 요구 스펙
    private Map<String, Double> candidateScores;
}
