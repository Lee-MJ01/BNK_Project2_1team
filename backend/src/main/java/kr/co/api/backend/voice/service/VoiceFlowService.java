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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class VoiceFlowService {

    private final VoiceSessionService voiceSessionService;
    private final VoiceIntentClassifierService intentService;
    private final VoiceStateMachine stateMachine;
    private final VoiceStateGuard stateGuard;
    private final DepositResolveService depositResolveService;

    public VoiceResDTO handle(String sessionId, VoiceReqDTO req) {

        VoiceState currentState = voiceSessionService.getState(sessionId);
        log.info("🎯 [VOICE] currentState={}", currentState);
        // ✅ 클릭 이벤트는 classifier를 타지 않게 (약관/전자서명 버튼 등)
        VoiceIntent intent = (req.getIntent() != null)
                ? req.getIntent()
                : intentService.classify(req);
        log.info("🎯 [VOICE] resolvedIntent={}", intent);

        if (currentState.ordinal() <= VoiceState.S2_PROD_EXPLAIN.ordinal()
                && req.getText() != null
                && req.getDpstId() == null) {

            depositResolveService.resolveProductCode(req.getText())
                    .ifPresent(productCode -> {
                        voiceSessionService.setProductCode(sessionId, productCode);
                        req.setDpstId(productCode); // 이후 로직 통일
                        log.info("🎇 prodCode : " + productCode);
                    });
        }


        // ✅ productCode는 "req.dpstId 우선, 없으면 세션"으로
        VoiceContext ctx = buildContext(sessionId, req);

        if (currentState == VoiceState.S4_2_INPUT
                && intent != VoiceIntent.PROCEED
                && intent != VoiceIntent.REQ_BACK) {
            return handleInputState(sessionId, req, intent, ctx);
        }

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

        String noticeCode = null;
        if (currentState != VoiceState.S4_2_INPUT
                && nextState == VoiceState.S4_2_INPUT) {
            noticeCode = "INPUT_START";
        }

        voiceSessionService.updateState(sessionId, nextState);

        return buildResponse(intent, nextState, endReason,
                noticeCode, null,
                voiceSessionService.getProductCode(sessionId));
    }

    private VoiceResDTO handleInputState(
            String sessionId,
            VoiceReqDTO req,
            VoiceIntent intent,
            VoiceContext ctx
    ) {
        VoiceResDTO res = new VoiceResDTO();
        res.setCurrentState(VoiceState.S4_2_INPUT);

        String text = req.getText();
        if (text == null || text.isBlank()) {
            res.setIntent(intent);
            return res;
        }

        text = text.replaceAll("\\s+", "");

        /* =========================
         * ① 출금 계좌 타입
         * ========================= */
        if (text.contains("원화")) {
            res.setIntent(VoiceIntent.PROVIDE_VALUE);
            res.setInputField("withdrawAccount");
            res.setInputValue("krw");
            return res;
        }

        if (text.contains("외화")) {
            res.setIntent(VoiceIntent.PROVIDE_VALUE);
            res.setInputField("withdrawAccount");
            res.setInputValue("fx");
            return res;
        }


        /* =========================
         * ③ 신규 통화
         * ========================= */
        if (text.matches(".*(가입통화|신규통화|통화|가입 통화).*")) {
            String currency = parseCurrency(text);
            log.info("📀 가입 통화={}", currency);
            if (currency != null) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("newCurrency");
                res.setInputValue(currency);
                return res;
            }
        }

        /* =========================
         * ② 출금 통화 (USD, JPY 등)
         * ========================= */
        if (text.matches(".*(달러|USD|엔|JPY|유로|EUR).*")) {
            String currency = parseCurrency(text);
            if (currency != null) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("withdrawCurrency");
                res.setInputValue(currency);
                return res;
            }
        }

        /* =========================
         * ④ 신규 금액
         * ========================= */
        if (text.matches(".*(원|만원|백만원|천).*")) {
            String amount = parseAmount(text);
            if (amount != null) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("newAmount");
                res.setInputValue(amount);
                return res;
            }
        }

        /* =========================
         * ⑤ 가입 기간
         * ========================= */
        if (text.matches(".*(개월|달).*")) {
            Integer period = parsePeriod(text);
            if (period != null) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("newPeriod");
                res.setInputValue(period.toString());
                return res;
            }
        }

        /* =========================
         * ⑥ 자동 연장
         * ========================= */
        if (text.contains("연장")) {
            if (text.contains("안") || text.contains("미신청") || text.contains("아니")) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("autoRenew");
                res.setInputValue("false");
                return res;
            }
            if (text.contains("신청") || text.contains("할게") || text.contains("응")) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("autoRenew");
                res.setInputValue("true");
                return res;
            }
        }

        /* =========================
         * ⑦ 만기 시 자동 해지
         * ========================= */
        if (text.contains("해지") || text.contains("자동해지") || text.contains("자동 해지")) {

            if (text.contains("안") || text.contains("아니") || text.contains("미신청")) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("autoTerminate");
                res.setInputValue("false");
                return res;
            }

            if (text.contains("할래") || text.contains("할게") || text.contains("응")) {
                res.setIntent(VoiceIntent.PROVIDE_VALUE);
                res.setInputField("autoTerminate");
                res.setInputValue("true");
                return res;
            }
        }

        /* =========================
         * 기본: 설명 요청
         * ========================= */
        res.setIntent(VoiceIntent.REQ_EXPLAIN);
        return res;
    }

    private String parseCurrency(String text) {
        if (text.contains("달러") || text.contains("USD")) return "USD";
        if (text.contains("엔") || text.contains("JPY")) return "JPY";
        if (text.contains("유로") || text.contains("EUR")) return "EUR";
        if (text.contains("원") || text.contains("KRW")) return "KRW";
        return null;
    }


    private Integer parsePeriod(String text) {
        Matcher m = Pattern.compile("(\\d+)").matcher(text);
        if (m.find()) {
            return Integer.parseInt(m.group(1));
        }
        return null;
    }


    private String parseAmount(String text) {

        // 공백 제거
        text = text.replaceAll("\\s+", "");

        // 1️⃣ 숫자가 그대로 있는 경우 (100만원, 500000)
        String number = text.replaceAll("[^0-9]", "");
        if (!number.isEmpty()) {
            long value = Long.parseLong(number);

            if (text.contains("만")) value *= 10_000;
            if (text.contains("천")) value *= 1_000;
            if (text.contains("백")) value *= 100;

            return String.valueOf(value);
        }

        // 2️⃣ 간단한 한글 숫자 처리
        if (text.contains("십만")) return "100000";
        if (text.contains("백만")) return "1000000";
        if (text.contains("천만")) return "10000000";
        if (text.contains("오백만")) return "5000000";

        // 못 알아먹으면 null
        return null;
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
