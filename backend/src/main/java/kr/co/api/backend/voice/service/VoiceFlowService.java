package kr.co.api.backend.voice.service;

import kr.co.api.backend.voice.domain.EndReason;
import kr.co.api.backend.voice.dto.VoiceReqDTO;
import kr.co.api.backend.voice.dto.VoiceResDTO;
import kr.co.api.backend.voice.stateMachine.GuardDecision;
import kr.co.api.backend.voice.stateMachine.VoiceStateGuard;
import kr.co.api.backend.voice.domain.VoiceIntent;
import kr.co.api.backend.voice.domain.VoiceState;
import kr.co.api.backend.voice.stateMachine.VoiceContext;
import kr.co.api.backend.voice.stateMachine.VoiceStateMachine;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class VoiceFlowService {

    private final VoiceSessionService voiceSessionService;
    private final VoiceIntentClassifierService intentService;
    private final VoiceStateMachine stateMachine;
    private final VoiceStateGuard stateGuard;

    public VoiceResDTO handle(String sessionId, VoiceReqDTO req) {

        VoiceState currentState = voiceSessionService.getState(sessionId);

        // ✅ 클릭 이벤트는 classifier를 타지 않게 (약관/전자서명 버튼 등)
        VoiceIntent intent = (req.getIntent() != null)
                ? req.getIntent()
                : intentService.classify(req);

        // ✅ productCode는 "req.dpstId 우선, 없으면 세션"으로
        VoiceContext ctx = buildContext(sessionId, req);

        // ✅ S0~S2까지만 productCode 세션 저장/갱신 허용 (S3부터 불변)
        if (currentState.ordinal() < VoiceState.S3_JOIN_CONFIRM.ordinal()) {
            if (req.getDpstId() != null) {
                voiceSessionService.setProductCode(sessionId, req.getDpstId());
                ctx = new VoiceContext(req.getDpstId()); // 최신화
            }
        }

        GuardDecision gd = stateGuard.decide(sessionId, currentState, intent, ctx, req);
        if (gd.isBlocked()) {
            return buildResponse(intent, gd.getNextState(), gd.getEndReason(),
                    gd.getNoticeCode(), gd.getNoticeMessage(),
                    voiceSessionService.getProductCode(sessionId));
        }

        VoiceState nextState = stateMachine.transition(currentState, intent, ctx);

        // ✅ 종료(COMPLETED)는 서버에서 붙여서 내려줌
        EndReason endReason = null;
        if (nextState == VoiceState.S5_END) {
            endReason = EndReason.COMPLETED;
        }

        voiceSessionService.updateState(sessionId, nextState);

        return buildResponse(intent, nextState, endReason,
                null, null,
                voiceSessionService.getProductCode(sessionId));
    }

    private VoiceContext buildContext(String sessionId, VoiceReqDTO req) {
        String productCode = (req.getDpstId() != null)
                ? req.getDpstId()
                : voiceSessionService.getProductCode(sessionId);
        return new VoiceContext(productCode);
    }

    private VoiceResDTO buildResponse(
            VoiceIntent intent,
            VoiceState state,
            EndReason endReason,
            String noticeCode,
            String noticeMessage,
            String productCode
    ) {
        VoiceResDTO res = new VoiceResDTO();
        res.setIntent(intent);
        res.setCurrentState(state);
        res.setEndReason(endReason);
        res.setNoticeCode(noticeCode);
        res.setNoticeMessage(noticeMessage);
        res.setProductCode(productCode);
        return res;
    }
}
