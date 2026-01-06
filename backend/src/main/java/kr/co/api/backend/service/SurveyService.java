package kr.co.api.backend.service;

import kr.co.api.backend.client.ai.RecoAiClient;
import kr.co.api.backend.dto.reco.AiRecoV2Request;
import kr.co.api.backend.dto.reco.RecoRerankResponse;
import kr.co.api.backend.dto.survey.*;
import kr.co.api.backend.mapper.SurveyMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SurveyService {

    // “유형 결과”를 TB_SURVEY_RESP_DTL에 저장할 때 쓰는 가상 문항 ID(너희 테이블 설계에 맞춰둔 값)
    private static final Long RESULT_Q_ID = 10L;

    // opt_id(유형) 값들 (네가 준 값 그대로)
    private static final Long TYPE_STABLE = 38L;
    private static final Long TYPE_LIQUID = 39L;
    private static final Long TYPE_FX = 40L;
    private static final Long TYPE_OVERSEAS = 41L;
    private static final Long TYPE_EVENT = 42L;

    // ✅ v3 보너스(유사유저 가입상품 top3)
    private static final int[] V3_BONUS = {5, 4, 3};

    // ✅ AI rerank에 던질 후보 개수(UX는 top3 먼저 보여주고, AI는 후보를 더 넓게 보고 재정렬)
    private static final int V2_CANDIDATE_TOP_N = 7;

    private final SurveyMapper surveyMapper;
    private final RecoAiClient recoAiClient;

    public SurveyDetailResponseDTO getSurveyDetail(Long surveyId) {
        SurveyDetailResponseDTO detail = surveyMapper.selectSurveyById(surveyId);
        if (detail == null) return null;

        List<SurveyQuestionResponseDTO> questions = surveyMapper.selectSurveyQuestions(surveyId);
        for (SurveyQuestionResponseDTO q : questions) {
            q.setOptions(surveyMapper.selectQuestionOptions(q.getQId()));
        }
        detail.setQuestions(questions);
        return detail;
    }

    @Transactional
    public void submitSurveyResponse(Long surveyId, SurveyResponseRequestDTO request) {
        // ===== 0) 요청 기본 검증 =====
        if (request == null) {
            throw new IllegalArgumentException("request body is null");
        }
        if (request.getCustCode() == null || request.getCustCode().isBlank()) {
            throw new IllegalArgumentException("custCode is required");
        }

        List<SurveyAnswerRequestDTO> answers = Optional.ofNullable(request.getAnswers())
                .orElseGet(Collections::emptyList);

        log.info("[SURVEY] submit start surveyId={}, custCode={}, answers.size={}",
                surveyId, request.getCustCode(), answers.size());

        // ===== 1) 요청 answers에서 qId 누락/이상치 즉시 잡기 =====
        for (int i = 0; i < answers.size(); i++) {
            SurveyAnswerRequestDTO a = answers.get(i);
            if (a == null) {
                throw new IllegalArgumentException("answers[" + i + "] is null");
            }
            if (a.getQId() == null) {
                throw new IllegalArgumentException("answers[" + i + "].qId is null");
            }
        }

        // ===== 2) respId 확보 =====
        Long respId = surveyMapper.selectResponseId(surveyId, request.getCustCode());
        if (respId != null) {
            surveyMapper.deleteResponseDetails(respId);
            surveyMapper.updateResponseHeaderStatus(respId, "DONE");
        } else {
            SurveyResponseHeaderDTO header = new SurveyResponseHeaderDTO();
            header.setSurveyId(surveyId);
            header.setCustCode(request.getCustCode());
            header.setStatus("DONE");
            surveyMapper.insertResponseHeader(header);
            respId = header.getRespId();

            if (respId == null) {
                throw new IllegalStateException("respId generation failed (insertResponseHeader returned null respId)");
            }
        }

        // ===== 3) details 생성 (null optId 제거, 텍스트는 blank 제거) =====
        List<SurveyResponseDetailDTO> details = new ArrayList<>();

        for (int i = 0; i < answers.size(); i++) {
            SurveyAnswerRequestDTO answer = answers.get(i);

            // optIds형
            if (answer.getOptIds() != null && !answer.getOptIds().isEmpty()) {
                for (Long optId : answer.getOptIds()) {
                    if (optId == null) {
                        log.warn("[SURVEY] skip null optId: answers[{}].qId={}", i, answer.getQId());
                        continue;
                    }
                    SurveyResponseDetailDTO d = new SurveyResponseDetailDTO();
                    d.setRespId(respId);
                    d.setQId(answer.getQId());
                    d.setOptId(optId);
                    details.add(d);
                }
            }
            // answerText형
            else if (answer.getAnswerText() != null && !answer.getAnswerText().isBlank()) {
                SurveyResponseDetailDTO d = new SurveyResponseDetailDTO();
                d.setRespId(respId);
                d.setQId(answer.getQId());
                d.setAnswerText(answer.getAnswerText());
                details.add(d);
            }
        }

        // ===== 4) 유형 결과 1건 추가 =====
        Long typeOptId = deriveTypeOptId(answers);
        if (typeOptId == null) typeOptId = TYPE_STABLE;

        SurveyResponseDetailDTO result = new SurveyResponseDetailDTO();
        result.setRespId(respId);
        result.setQId(RESULT_Q_ID);
        result.setOptId(typeOptId);
        details.add(result);

        // ===== 5) INSERT 직전 최종 검증 + 로그 =====
        for (int i = 0; i < details.size(); i++) {
            SurveyResponseDetailDTO d = details.get(i);
            if (d.getRespId() == null) {
                throw new IllegalStateException("details[" + i + "].respId is null");
            }
            if (d.getQId() == null) {
                throw new IllegalStateException("details[" + i + "].qId is null (respId=" + d.getRespId()
                        + ", optId=" + d.getOptId() + ", answerText=" + d.getAnswerText() + ")");
            }
            log.info("[SURVEY] details[{}] respId={}, qId={}, optId={}, answerText={}",
                    i, d.getRespId(), d.getQId(), d.getOptId(), d.getAnswerText());
        }

        // ===== 6) 저장 =====
        if (!details.isEmpty()) {
            surveyMapper.insertResponseDetails(details);
        }

        log.info("[SURVEY] submit done surveyId={}, custCode={}, respId={}, insertedRows={}",
                surveyId, request.getCustCode(), respId, details.size());

        // ✅ UX 우선: 저장 직후 "빠른 추천(v1+v3 top3)"만 즉시 저장
        log.info("[RECO][FAST] submit -> refreshRecommendationsFast start surveyId={}, custCode={}",
                surveyId, request.getCustCode());

        refreshRecommendationsFast(surveyId, request.getCustCode());

        log.info("[RECO][FAST] submit -> refreshRecommendationsFast done surveyId={}, custCode={}",
                surveyId, request.getCustCode());
    }

    /**
     * 추천 조회(UX용)
     * - 있으면 바로 반환
     * - 없으면 fast 추천(v1+v3 top3) 생성 후 반환
     */
    @Transactional
    public List<SurveyRecommendationDTO> getRecommendations(Long surveyId, String custCode) {
        validateCustCode(custCode);

        List<SurveyRecommendationDTO> existing = surveyMapper.selectRecommendations(custCode, surveyId);
        if (existing != null && !existing.isEmpty()) {
            return existing;
        }
        return refreshRecommendationsFast(surveyId, custCode);
    }

    /**
     * ✅ FAST 추천 (v1 + v3로 top3 만들어서 저장)
     * - 즉시 화면에 보여주기 위한 용도
     */
    @Transactional
    public List<SurveyRecommendationDTO> refreshRecommendationsFast(Long surveyId, String custCode) {
        validateCustCode(custCode);

        List<String> productIds = surveyMapper.selectActiveProductIds();
        if (productIds == null || productIds.isEmpty()) {
            return Collections.emptyList();
        }

        Long respId = surveyMapper.selectLatestResponseId(surveyId, custCode);
        List<SurveyResponseAnswerDTO> answers =
                respId == null ? Collections.emptyList() : surveyMapper.selectResponseAnswers(respId);

        List<SurveyProductDTO> products = surveyMapper.selectProductSummaries(productIds);

        // ✅ v1+v3 반영된 top3
        List<String> top3 = buildTop3Products(surveyId, custCode, answers, products);
        if (top3.isEmpty()) {
            return Collections.emptyList();
        }

        surveyMapper.deleteRecommendations(custCode, surveyId);

        List<SurveyRecommendationInsertDTO> inserts = new ArrayList<>();
        for (int i = 0; i < top3.size(); i++) {
            SurveyRecommendationInsertDTO dto = new SurveyRecommendationInsertDTO();
            dto.setCustCode(custCode);
            dto.setSurveyId(surveyId);
            dto.setRankNo(i + 1);
            dto.setProductId(top3.get(i));
            inserts.add(dto);
        }
        surveyMapper.insertRecommendations(inserts);

        return surveyMapper.selectRecommendations(custCode, surveyId);
    }

    /**
     * ✅ V2 rerank (AI 서버 호출)
     * - UX: 화면은 이미 fast top3를 보여주고 있음
     * - 이걸 호출하면 AI가 후보를 재정렬해서 top3를 DB에 다시 저장
     */
    @Transactional
    public List<SurveyRecommendationDTO> rerankRecommendationsV2(Long surveyId, String custCode) {
        validateCustCode(custCode);

        List<String> productIds = surveyMapper.selectActiveProductIds();
        if (productIds == null || productIds.isEmpty()) {
            return Collections.emptyList();
        }

        Long respId = surveyMapper.selectLatestResponseId(surveyId, custCode);
        List<SurveyResponseAnswerDTO> answers =
                respId == null ? Collections.emptyList() : surveyMapper.selectResponseAnswers(respId);

        List<SurveyProductDTO> products = surveyMapper.selectProductSummaries(productIds);

        // ✅ 1) v1+v3 점수 기반 후보 TopN -> candidateScores(Map) 생성
        Map<String, Double> candidateScores =
                buildCandidateScoresTopN(surveyId, custCode, answers, products, V2_CANDIDATE_TOP_N);

        if (candidateScores == null || candidateScores.isEmpty()) {
            return surveyMapper.selectRecommendations(custCode, surveyId);
        }

        log.info("[RECO][V2] candidateScores.size={}, sample={}",
                candidateScores.size(),
                candidateScores.entrySet().stream().limit(3).toList());

        // ✅ 2) AI rerank 호출 (AI 서버는 candidateScores 필드를 요구함)
        List<String> top3;
        try {
            AiRecoV2Request req = new AiRecoV2Request();
            req.setSurveyId(surveyId);
            req.setCustCode(custCode);
            req.setCandidateScores(candidateScores);

            RecoRerankResponse res = recoAiClient.rerank(req);

            top3 = Optional.ofNullable(res.getItems()).orElseGet(Collections::emptyList).stream()
                    .sorted(Comparator.comparingInt(RecoRerankResponse.Item::getRank))
                    .map(RecoRerankResponse.Item::getProductId)
                    .filter(Objects::nonNull)
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .distinct()
                    .limit(3)
                    .toList();

            log.info("[RECO][V2] rerank top3={}", top3);

        } catch (Exception e) {
            // AI 실패해도 UX는 살아야 함 -> fast top3로 fallback
            log.warn("[RECO][V2] rerank failed. fallback to fast. surveyId={}, custCode={}",
                    surveyId, custCode, e);

            top3 = buildTop3Products(surveyId, custCode, answers, products);
        }

        if (top3 == null || top3.isEmpty()) {
            return surveyMapper.selectRecommendations(custCode, surveyId);
        }

        // ✅ 3) DB 저장(갱신)
        surveyMapper.deleteRecommendations(custCode, surveyId);

        List<SurveyRecommendationInsertDTO> inserts = new ArrayList<>();
        for (int i = 0; i < top3.size(); i++) {
            SurveyRecommendationInsertDTO dto = new SurveyRecommendationInsertDTO();
            dto.setCustCode(custCode);
            dto.setSurveyId(surveyId);
            dto.setRankNo(i + 1);
            dto.setProductId(top3.get(i));
            inserts.add(dto);
        }
        surveyMapper.insertRecommendations(inserts);

        return surveyMapper.selectRecommendations(custCode, surveyId);
    }

    public SurveyPrefillResponseDTO buildPrefill(Long surveyId, String custCode) {
        validateCustCode(custCode);
        SurveyPrefillResponseDTO response = new SurveyPrefillResponseDTO();
        response.setWithdrawType("krw");
        response.setPreferredKrwAccountType("main");

        Long respId = surveyMapper.selectLatestResponseId(surveyId, custCode);
        if (respId == null) {
            return response;
        }

        List<SurveyResponseAnswerDTO> answers = surveyMapper.selectResponseAnswers(respId);
        Map<Long, List<String>> valuesByQId = new HashMap<>();
        for (SurveyResponseAnswerDTO answer : answers) {
            if (answer.getQId() == null) continue;
            if (answer.getOptValue() == null) continue;
            valuesByQId.computeIfAbsent(answer.getQId(), k -> new ArrayList<>()).add(answer.getOptValue());
        }

        List<String> currencies = valuesByQId.getOrDefault(4L, Collections.emptyList());
        if (!currencies.isEmpty()) {
            response.setPreferredCurrency(currencies.get(0));
        }

        List<String> periodValues = valuesByQId.getOrDefault(6L, Collections.emptyList());
        if (!periodValues.isEmpty()) {
            response.setPreferredPeriodMonths(parseInt(periodValues.get(0)));
        }

        List<String> amountValues = valuesByQId.getOrDefault(5L, Collections.emptyList());
        if (!amountValues.isEmpty()) {
            response.setPreferredAmount(mapAmount(amountValues.get(0)));
        }

        List<String> accountValues = valuesByQId.getOrDefault(9L, Collections.emptyList());
        if (!accountValues.isEmpty()) {
            response.setPreferredKrwAccountType(
                    "ACC_OTHER_KRW".equals(accountValues.get(0)) ? "other" : "main");
        }

        return response;
    }

    private Long deriveTypeOptId(List<SurveyAnswerRequestDTO> answers) {
        List<Long> optIds = answers.stream()
                .filter(Objects::nonNull)
                .flatMap(a -> Optional.ofNullable(a.getOptIds()).orElseGet(Collections::emptyList).stream())
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (optIds.isEmpty()) return TYPE_STABLE;

        List<SurveyOptionValueDTO> optionValues = surveyMapper.selectOptionValues(optIds);

        Map<Long, List<String>> valuesByQId = new HashMap<>();
        for (SurveyOptionValueDTO option : optionValues) {
            if (option == null) continue;
            if (option.getQId() == null) continue;
            valuesByQId.computeIfAbsent(option.getQId(), k -> new ArrayList<>())
                    .add(option.getOptValue());
        }

        if (containsValue(valuesByQId, 3L, "LIQ_NEED")) return TYPE_LIQUID;

        if (containsValue(valuesByQId, 1L, "GOAL_STABLE")) return TYPE_STABLE;
        if (containsValue(valuesByQId, 1L, "GOAL_FX")) return TYPE_FX;
        if (containsValue(valuesByQId, 1L, "GOAL_OVERSEAS")) return TYPE_OVERSEAS;
        if (containsValue(valuesByQId, 1L, "GOAL_EVENT")) return TYPE_EVENT;

        if (containsValue(valuesByQId, 2L, "PRIOR_LIQ")) return TYPE_LIQUID;
        if (containsValue(valuesByQId, 2L, "PRIOR_RATE")) return TYPE_STABLE;
        if (containsValue(valuesByQId, 2L, "PRIOR_FX")) return TYPE_FX;
        if (containsValue(valuesByQId, 2L, "PRIOR_EVENT")) return TYPE_EVENT;

        return TYPE_STABLE;
    }

    private boolean containsValue(Map<Long, List<String>> valuesByQId, Long qId, String target) {
        return valuesByQId.getOrDefault(qId, Collections.emptyList()).contains(target);
    }

    // ============================
    // ✅ v3 bonus map
    // ============================
    private Map<String, Integer> getV3BonusMap(Long surveyId, String custCode) {
        try {
            List<Map<String, Object>> rows = surveyMapper.selectSimilarUsersTopProducts(surveyId, custCode);
            if (rows == null || rows.isEmpty()) {
                log.info("[RECO][V3] similar-users top products empty (no similar users yet). surveyId={}, custCode={}",
                        surveyId, custCode);
                return Collections.emptyMap();
            }

            Map<String, Integer> bonus = new HashMap<>();
            for (int i = 0; i < rows.size() && i < 3; i++) {
                Map<String, Object> row = rows.get(i);

                Object pidObj = row.get("PRODUCTID");
                if (pidObj == null) pidObj = row.get("productId");
                if (pidObj == null) continue;

                String productId = String.valueOf(pidObj).trim();
                if (productId.isEmpty()) continue;

                bonus.put(productId, V3_BONUS[i]);
            }

            log.info("[RECO][V3] bonusMap={}", bonus);
            return bonus;
        } catch (Exception e) {
            log.warn("[RECO][V3] failed to load similar user bonus. surveyId={}, custCode={}. fallback to v1 only.",
                    surveyId, custCode, e);
            return Collections.emptyMap();
        }
    }

    // ============================
    // ✅ buildTop3Products (v1 + v3)
    // ============================
    private List<String> buildTop3Products(Long surveyId,
                                           String custCode,
                                           List<SurveyResponseAnswerDTO> answers,
                                           List<SurveyProductDTO> products) {

        Map<Long, List<String>> valuesByQId = new HashMap<>();
        for (SurveyResponseAnswerDTO answer : answers) {
            if (answer == null || answer.getQId() == null || answer.getOptValue() == null) continue;
            valuesByQId.computeIfAbsent(answer.getQId(), k -> new ArrayList<>()).add(answer.getOptValue());
        }

        String type = resolveSurveyType(valuesByQId);
        List<String> interestCurrencies = valuesByQId.getOrDefault(4L, Collections.emptyList());
        Integer desiredPeriod = parseInt(firstValue(valuesByQId, 6L));

        Map<String, Integer> v3Bonus = getV3BonusMap(surveyId, custCode);

        Map<String, Integer> finalScores = new HashMap<>();
        Map<String, Integer> v1Scores = new HashMap<>();

        for (SurveyProductDTO product : products) {
            if (product == null || product.getDpstId() == null) continue;
            String pid = product.getDpstId();

            int v1 = baseScore(type, product);
            v1 += currencyScore(interestCurrencies, product);
            v1 += periodScore(desiredPeriod, product);

            int bonus = v3Bonus.getOrDefault(pid, 0);
            int total = v1 + bonus;

            v1Scores.put(pid, v1);
            finalScores.put(pid, total);
        }

        List<String> sorted = finalScores.entrySet().stream()
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        if (sorted.isEmpty()) {
            return fallbackRandom(products);
        }

        List<String> top = sorted.stream().limit(3).collect(Collectors.toList());

        log.info("[RECO] type={}, currencies={}, period={}, v3Bonus={}",
                type, interestCurrencies, desiredPeriod, v3Bonus);

        for (int i = 0; i < top.size(); i++) {
            String pid = top.get(i);
            log.info("[RECO] TOP{} pid={} total={} (v1={} + v3={})",
                    i + 1,
                    pid,
                    finalScores.getOrDefault(pid, 0),
                    v1Scores.getOrDefault(pid, 0),
                    v3Bonus.getOrDefault(pid, 0));
        }

        if (top.size() < 3) {
            List<String> fallback = fallbackRandom(products);
            for (String id : fallback) {
                if (top.size() >= 3) break;
                if (!top.contains(id)) top.add(id);
            }
        }
        return top;
    }

    /**
     * ✅ v1+v3 점수 기반 후보 TopN 생성 (AI rerank 입력용)
     * - return: productId -> score (정렬 유지)
     */
    private Map<String, Double> buildCandidateScoresTopN(Long surveyId,
                                                         String custCode,
                                                         List<SurveyResponseAnswerDTO> answers,
                                                         List<SurveyProductDTO> products,
                                                         int topN) {

        Map<Long, List<String>> valuesByQId = new HashMap<>();
        for (SurveyResponseAnswerDTO answer : answers) {
            if (answer == null || answer.getQId() == null || answer.getOptValue() == null) continue;
            valuesByQId.computeIfAbsent(answer.getQId(), k -> new ArrayList<>()).add(answer.getOptValue());
        }

        String type = resolveSurveyType(valuesByQId);
        List<String> interestCurrencies = valuesByQId.getOrDefault(4L, Collections.emptyList());
        Integer desiredPeriod = parseInt(firstValue(valuesByQId, 6L));

        Map<String, Integer> v3Bonus = getV3BonusMap(surveyId, custCode);

        Map<String, Integer> finalScores = new HashMap<>();
        for (SurveyProductDTO product : products) {
            if (product == null || product.getDpstId() == null) continue;
            String pid = product.getDpstId();

            int v1 = baseScore(type, product);
            v1 += currencyScore(interestCurrencies, product);
            v1 += periodScore(desiredPeriod, product);

            int bonus = v3Bonus.getOrDefault(pid, 0);
            int total = v1 + bonus;

            finalScores.put(pid, total);
        }

        return finalScores.entrySet().stream()
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .limit(topN)
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        e -> e.getValue().doubleValue(),
                        (a, b) -> a,
                        LinkedHashMap::new
                ));
    }

    private List<String> fallbackRandom(List<SurveyProductDTO> products) {
        List<String> ids = products.stream()
                .map(SurveyProductDTO::getDpstId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        if (ids.isEmpty()) return Collections.emptyList();
        Collections.shuffle(ids);
        return ids.stream().limit(3).collect(Collectors.toList());
    }

    private String resolveSurveyType(Map<Long, List<String>> valuesByQId) {
        String hidden = firstValue(valuesByQId, RESULT_Q_ID);
        if (hidden != null && hidden.startsWith("TYPE_")) {
            return hidden;
        }

        if (containsValue(valuesByQId, 3L, "LIQ_NEED")) return "TYPE_LIQUID";
        if (containsValue(valuesByQId, 1L, "GOAL_STABLE")) return "TYPE_STABLE";
        if (containsValue(valuesByQId, 1L, "GOAL_FX")) return "TYPE_FX";
        if (containsValue(valuesByQId, 1L, "GOAL_OVERSEAS")) return "TYPE_OVERSEAS";
        if (containsValue(valuesByQId, 1L, "GOAL_EVENT")) return "TYPE_EVENT";
        if (containsValue(valuesByQId, 2L, "PRIOR_LIQ")) return "TYPE_LIQUID";
        if (containsValue(valuesByQId, 2L, "PRIOR_RATE")) return "TYPE_STABLE";
        if (containsValue(valuesByQId, 2L, "PRIOR_FX")) return "TYPE_FX";
        if (containsValue(valuesByQId, 2L, "PRIOR_EVENT")) return "TYPE_EVENT";

        return "TYPE_STABLE";
    }

    private int baseScore(String type, SurveyProductDTO product) {
        int score = 0;
        String name = normalize(product.getDpstName());
        String desc = normalize(product.getDpstDescript());
        String info = normalize(product.getDpstInfo());

        if ("TYPE_LIQUID".equals(type)) {
            if ("Y".equalsIgnoreCase(product.getDpstPartWdrwYn())) score += 3;
            if (periodMin(product) != null && periodMin(product) <= 3) score += 2;
            if (product.getDpstType() != null && product.getDpstType() == 2) score += 1;
        } else if ("TYPE_STABLE".equals(type)) {
            if (product.getDpstType() != null && product.getDpstType() == 1) score += 3;
            if (periodMin(product) != null && periodMin(product) >= 6) score += 2;
            if ("Y".equalsIgnoreCase(product.getDpstAutoRenewYn())) score += 1;
        } else if ("TYPE_FX".equals(type)) {
            if ("Y".equalsIgnoreCase(product.getDpstAddPayYn())) score += 2;
            if (product.getDpstType() != null && product.getDpstType() == 2) score += 2;
            if (currencyCount(product) >= 4) score += 1;
        } else if ("TYPE_OVERSEAS".equals(type)) {
            if (containsAnyCurrency(product, List.of("USD", "JPY"))) score += 2;
            if (name.contains("해외") || desc.contains("해외") || info.contains("해외")) score += 2;
            if (name.contains("유학") || desc.contains("유학") || info.contains("유학")) score += 1;
        } else if ("TYPE_EVENT".equals(type)) {
            if (name.contains("이벤트") || desc.contains("이벤트")) score += 3;
            if (name.contains("특별") || desc.contains("특별")) score += 2;
            if (name.contains("슈카") || desc.contains("슈카")) score += 2;
        }

        return score;
    }

    private int currencyScore(List<String> interestCurrencies, SurveyProductDTO product) {
        if (interestCurrencies == null || interestCurrencies.isEmpty()) return 0;
        List<String> productCurrencies = splitCurrencies(product.getDpstCurrency());
        for (String currency : interestCurrencies) {
            if (productCurrencies.contains(currency)) {
                return 2;
            }
        }
        return 0;
    }

    private int periodScore(Integer desiredPeriod, SurveyProductDTO product) {
        if (desiredPeriod == null) return 0;
        Integer fixed = product.getPeriodFixedMonth();
        if (fixed != null && fixed.equals(desiredPeriod)) {
            return 2;
        }
        Integer min = product.getPeriodMinMonth();
        Integer max = product.getPeriodMaxMonth();
        if (min != null && max != null && desiredPeriod >= min && desiredPeriod <= max) {
            return 2;
        }
        return 0;
    }

    private Integer periodMin(SurveyProductDTO product) {
        Integer min = product.getPeriodMinMonth();
        if (min != null) return min;
        return product.getPeriodFixedMonth();
    }

    private int currencyCount(SurveyProductDTO product) {
        return splitCurrencies(product.getDpstCurrency()).size();
    }

    private boolean containsAnyCurrency(SurveyProductDTO product, List<String> currencies) {
        List<String> productCurrencies = splitCurrencies(product.getDpstCurrency());
        for (String currency : currencies) {
            if (productCurrencies.contains(currency)) return true;
        }
        return false;
    }

    private List<String> splitCurrencies(String raw) {
        if (raw == null || raw.isBlank()) return Collections.emptyList();
        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    private String normalize(String value) {
        return value == null ? "" : value.replace(" ", "");
    }

    private String firstValue(Map<Long, List<String>> valuesByQId, Long qId) {
        List<String> values = valuesByQId.getOrDefault(qId, Collections.emptyList());
        return values.isEmpty() ? null : values.get(0);
    }

    private Integer parseInt(String value) {
        if (value == null) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Integer mapAmount(String amountKey) {
        if (amountKey == null) return null;
        return switch (amountKey) {
            case "AMT_LT_1M" -> 500_000;
            case "AMT_1_5M" -> 3_000_000;
            case "AMT_5_10M" -> 7_500_000;
            case "AMT_GT_10M" -> 12_000_000;
            default -> null;
        };
    }

    private void validateCustCode(String custCode) {
        if (custCode == null || custCode.isBlank()) {
            throw new IllegalArgumentException("custCode is required");
        }
    }
}
