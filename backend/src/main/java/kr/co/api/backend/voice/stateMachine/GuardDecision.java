package kr.co.api.backend.voice.stateMachine;

import kr.co.api.backend.voice.domain.EndReason;
import kr.co.api.backend.voice.domain.VoiceState;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class GuardDecision {
    private boolean blocked;
    private VoiceState nextState;     // blocked일 때도 "유지" 가능
    private EndReason endReason;      // 종료인 경우만 세팅
    private String noticeCode;        // 프론트 스크립트 매핑용
    private String noticeMessage;     // 사용자에게 보여줄 한 줄(선택)
}