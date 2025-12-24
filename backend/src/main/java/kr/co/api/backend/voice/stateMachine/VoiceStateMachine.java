package kr.co.api.backend.voice.stateMachine;

import kr.co.api.backend.voice.domain.VoiceIntent;
import kr.co.api.backend.voice.domain.VoiceState;
import org.springframework.stereotype.Component;


@Component
public class VoiceStateMachine {

    public VoiceState transition(
            VoiceState current,
            VoiceIntent intent,
            VoiceContext ctx
    ) {

        return switch (current) {

            case S0_IDLE ->
                    (intent == VoiceIntent.REQ_RECOMMEND)
                            ? (ctx.hasProduct()
                            ? VoiceState.S2_PROD_EXPLAIN
                            : VoiceState.S1_RECOMMEND)
                            : current;

            case S1_RECOMMEND ->
                    switch (intent) {
                        case REQ_OTHER   -> VoiceState.S1_RECOMMEND;
                        case REQ_EXPLAIN -> VoiceState.S2_PROD_EXPLAIN;
                        case REQ_JOIN    -> VoiceState.S3_JOIN_CONFIRM;
                        default          -> current;
                    };

            case S2_PROD_EXPLAIN ->
                    switch (intent) {
                        case REQ_OTHER   -> VoiceState.S1_RECOMMEND;
                        case REQ_JOIN    -> VoiceState.S3_JOIN_CONFIRM;
                        case REQ_EXPLAIN -> VoiceState.S2_PROD_EXPLAIN; // overlay
                        default          -> current;
                    };

            case S3_JOIN_CONFIRM ->
                    switch (intent) {
                        case AFFIRM -> VoiceState.S4_1_TERMS;
                        case DENY   -> VoiceState.S2_PROD_EXPLAIN;
                        default     -> current;
                    };

            case S4_1_TERMS ->
                    switch (intent) {
                        case CONFIRM -> VoiceState.S4_2_INPUT;
                        case REQ_BACK -> VoiceState.S3_JOIN_CONFIRM;
                        default      -> current;
                    };

            case S4_2_INPUT ->
                    switch (intent) {
                        case PROCEED -> VoiceState.S4_3_CONFIRM;
                        case REQ_BACK -> VoiceState.S4_1_TERMS;
                        default      -> current;
                    };

            case S4_3_CONFIRM ->
                    switch (intent) {
                        case CONFIRM -> VoiceState.S4_4_SIGNATURE;
                        case REQ_BACK -> VoiceState.S4_2_INPUT;
                        default      -> current;
                    };

            case S4_4_SIGNATURE ->
                // ✅ 클릭 성공 이벤트로 종료 (classifier 안 탐: req.intent=SUCCESS로 보내면 됨)
                    (intent == VoiceIntent.SUCCESS)
                            ? VoiceState.S5_END
                            : current;

            case S5_END -> VoiceState.S5_END;
        };
    }
}
