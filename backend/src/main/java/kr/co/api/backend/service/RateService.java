package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class RateService {

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    @Value("${eximbank.api.base-url}")
    private String baseUrl;

    @Value("${eximbank.api.auth-key}")
    private String authKey;

    // =================================================================
    // 1. 조회 페이지용: 입력한 날짜 그대로 조회 (데이터 없으면 빈값 리턴)
    // =================================================================
    public String getRate(String date) {
        String searchDate = date.replace("-", "");
        return fetchRawData(searchDate); // 아래 공통 메서드 사용
    }

    // =================================================================
    // 2. 메인 페이지용: 오늘이 비영업일이면 자동으로 최근 영업일 데이터 조회
    // =================================================================
    public String getMainPageRate() {
        LocalDate targetDate = getTargetDate(); // 영업일 계산

        // 최대 5일 전까지 뒤져서 데이터가 있는 날짜를 찾음
        for (int i = 0; i < 5; i++) {
            String searchDate = targetDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String response = fetchRawData(searchDate);

            if (isValidResponse(response)) {
                return response;
            }
            targetDate = targetDate.minusDays(1);
        }
        return "[]";
    }

    // =================================================================
    // ★ [복구됨] 3. 특정 통화(USD 등) 환율 하나만 가져오기 (계산기 등에서 사용)
    // =================================================================
    public Map<String, Double> getCurrencyRate(String currency) {
        // 1. 최근 영업일 데이터 가져오기 (메인페이지 로직과 동일하게 최신 데이터 탐색)
        String jsonResponse = getMainPageRate();

        if (!isValidResponse(jsonResponse)) {
            return null;
        }

        // 2. JSON 파싱해서 해당 통화 찾기
        try {
            JsonNode root = objectMapper.readTree(jsonResponse);
            if (root.isArray()) {
                for (JsonNode node : root) {
                    String curUnit = node.path("cur_unit").asText();

                    // JPY(100), IDR(100) 등 괄호 처리 포함
                    if (curUnit.equals(currency) || curUnit.startsWith(currency + "(")) {

                        // 매매기준율
                        String dealBasR = node.path("kftc_deal_bas_r").asText().replace(",", "");
                        if (dealBasR.isEmpty() || dealBasR.equals("0")) {
                            dealBasR = node.path("deal_bas_r").asText().replace(",", "");
                        }

                        // 송금 보낼때/받을때
                        String tts = node.path("tts").asText().replace(",", "");
                        String ttb = node.path("ttb").asText().replace(",", "");

                        Map<String, Double> result = new HashMap<>();
                        result.put("rate", dealBasR.isEmpty() ? 0.0 : Double.parseDouble(dealBasR));
                        result.put("tts", tts.isEmpty() ? 0.0 : Double.parseDouble(tts));
                        result.put("ttb", ttb.isEmpty() ? 0.0 : Double.parseDouble(ttb));

                        return result;
                    }
                }
            }
        } catch (Exception e) {
            log.error("JSON 파싱 에러", e);
        }
        return null;
    }


    // -----------------------------------------------------------
    // [내부 공통 메서드] API 호출 및 Redis 캐싱
    // -----------------------------------------------------------
    private String fetchRawData(String searchDate) {
        String redisKey = "fx:" + searchDate;

        // Redis 조회
        String cached = redisTemplate.opsForValue().get(redisKey);
        if (cached != null) {
            return cached;
        }

        // API 호출
        String url = baseUrl +
                "?authkey=" + authKey +
                "&searchdate=" + searchDate +
                "&data=AP01";

        try {
            RestTemplate rest = new RestTemplate();
            String response = rest.getForObject(url, String.class);

            // 유효한 데이터면 Redis 저장
            if (isValidResponse(response)) {
                redisTemplate.opsForValue().set(redisKey, response);
            }
            return response;
        } catch (Exception e) {
            log.error("API 호출 실패: {}", e.getMessage());
            return null;
        }
    }

    // 데이터 유효성 검사 (null 이거나 빈 배열이면 false)
    private boolean isValidResponse(String response) {
        return response != null && !response.equals("[]") && !response.isEmpty() && response.contains("cur_unit");
    }

    // 영업일 계산 로직
    public LocalDate getTargetDate() {
        LocalDateTime now = LocalDateTime.now();
        LocalDate date = now.toLocalDate();
        DayOfWeek dayOfWeek = now.getDayOfWeek();
        int hour = now.getHour();

        if (dayOfWeek == DayOfWeek.SATURDAY) return date.minusDays(1);
        else if (dayOfWeek == DayOfWeek.SUNDAY) return date.minusDays(2);
        else if (dayOfWeek == DayOfWeek.MONDAY && hour < 11) return date.minusDays(3);
        else if (hour < 11) return date.minusDays(1);

        return date;
    }
}