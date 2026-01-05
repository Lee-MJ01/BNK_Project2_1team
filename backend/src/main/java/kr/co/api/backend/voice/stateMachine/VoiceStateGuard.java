package kr.co.api.backend.voice.stateMachine;

import kr.co.api.backend.voice.domain.EndReason;
import kr.co.api.backend.voice.domain.VoiceIntent;
import kr.co.api.backend.voice.domain.VoiceState;
import kr.co.api.backend.voice.dto.VoiceReqDTO;
import kr.co.api.backend.voice.service.VoiceSessionService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class VoiceStateGuard {

    private final VoiceSessionService sessionService;

    public GuardDecision decide(
            String sessionId,
            VoiceState state,
            VoiceIntent intent,
            VoiceContext ctx,
            VoiceReqDTO req
    ) {

        // 0) 클라이언트에서 TIMEOUT / STT ERROR 감지 시 종료 (프론트가 붙이는 게 맞음)
        if (req.getClientEndReason() != null) {
            return new GuardDecision(
                    true,
                    VoiceState.S5_END,
                    req.getClientEndReason(),
                    "CLIENT_END",
                    null
            );
        }

        // 전역 취소
        if (intent == VoiceIntent.REQ_CANCEL) {
            return new GuardDecision(true, VoiceState.S5_END, EndReason.CANCELED, "CANCELED", null);
        }

        // UNKNOWN INTENT 재시도: 3회 이하면 "다시 말해주세요" 4회째는 ERROR 종료
        if (intent == VoiceIntent.UNKNOWN) {
            int cnt = sessionService.incUnknownCount(sessionId);
            if (cnt >= 4) {
                return new GuardDecision(true, VoiceState.S5_END, EndReason.ERROR, "UNKNOWN_OVER_LIMIT", null);
            }
            return new GuardDecision(true, state, null, "RETRY_UNKNOWN", "다시 말씀해주세요.");
        } else {
            // 정상 입력 들어오면 카운트 리셋
            sessionService.resetUnknownCount(sessionId);
        }

        // productCode : S3 이상부터는 변경 금지
        String sessionProd = sessionService.getProductCode(sessionId);
        if (state.ordinal() >= VoiceState.S3_JOIN_CONFIRM.ordinal()) {
            if (req.getDpstId() != null && sessionProd != null && !req.getDpstId().equals(sessionProd)) {
                return new GuardDecision(true, VoiceState.S5_END, EndReason.ERROR, "PRODUCT_IMMUTABLE_VIOLATION", null);
            }
        }

        // 4) 상품이 필요한 intent인데 상품이 없으면 종료가 아니라 "안내 후 유지"
        // (다이어그램의 invariant는 S2+에서 필요하지만, 실제 UX는 유지+안내가 더 맞음)
        boolean needsProduct =
                (intent == VoiceIntent.REQ_EXPLAIN) ||
                        (intent == VoiceIntent.REQ_JOIN) ||
                        (state.ordinal() >= VoiceState.S2_PROD_EXPLAIN.ordinal());

        if (needsProduct && (sessionProd == null && !ctx.hasProduct())) {
            return new GuardDecision(true, state, null, "NEED_PRODUCT", "먼저 상품을 선택해주세요.");
        }

        return new GuardDecision(false, null, null, null, null);
    }
}
