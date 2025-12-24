package kr.co.api.backend.voice.dto;

import kr.co.api.backend.voice.domain.EndReason;
import kr.co.api.backend.voice.domain.VoiceIntent;
import kr.co.api.backend.voice.domain.VoiceState;
import lombok.Data;

@Data
public class VoiceResDTO {
    private VoiceIntent intent;
    private VoiceState currentState;
    private EndReason endReason;

    // 프론트 스크립트 매핑용 (재요청/상품필요/오류 등)
    private String noticeCode;
    private String noticeMessage;

    // (선택) 디버깅용
    private String productCode;
}
