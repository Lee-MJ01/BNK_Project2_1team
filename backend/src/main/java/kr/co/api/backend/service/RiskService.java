package kr.co.api.backend.service;


import kr.co.api.backend.dto.ExchangeRateDTO;
import kr.co.api.backend.dto.ExchangeRiskDTO;
import kr.co.api.backend.mapper.ExchangeRateMapper;
import kr.co.api.backend.mapper.ExchangeRiskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RiskService {

    private final ExchangeRiskMapper riskMapper; // 1. 변동성 매퍼
    private final ExchangeRateMapper rateMapper; // 2. 환율 매퍼

    public Map<String, Object> getRiskInfo(String currency, String date) {

        // 날짜가 없으면 오늘 날짜로 설정
        if (date == null || date.isEmpty()) {
            date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        }
        String searchDate = date.replace("-", "");

        Map<String, Object> result = new HashMap<>();

        // 1. 변동성(%) 가져오기
        ExchangeRiskDTO riskData = riskMapper.selectVolatility(currency, searchDate);

        // 데이터가 없으면 바로 리턴
        if (riskData == null) {
            result.put("status", "error");
            result.put("message", "해당 날짜의 예측 데이터가 없습니다.");
            return result;
        }

        // 2. 환율(₩) 가져오기
        ExchangeRateDTO rateData = rateMapper.selectExchangeRate(currency, searchDate);

        double currentRate = 1300.0; // 기본값 (DB에 없을 경우 대비)
        String rateDate = "";        // 실제 환율 기준일

        if (rateData != null && rateData.getExchRate() != null) {
            currentRate = rateData.getExchRate();
            rateDate = rateData.getStdDt();
        }

        // 3. 계산 (환율 * 변동성 / 100)
        double riskPercent = riskData.getVolForecastVal();
        double expectedGap = currentRate * (riskPercent / 100.0);

        // 4. 날씨 판단 (기상청 컨셉)
        String weatherIcon = "SUNNY";
        String weatherText = "맑음";

        if (riskPercent >= 1.0) {
            weatherIcon = "STORM";
            weatherText = "폭풍우";
        } else if (riskPercent >= 0.5) {
            weatherIcon = "CLOUDY";
            weatherText = "구름조금";
        }

        // 5. 결과 만들기
        result.put("status", "success");
        result.put("currency", currency);
        result.put("target_date", searchDate);      // 사용자가 조회한 날짜
        result.put("rate_date", rateDate);          // 실제 환율 데이터 날짜

        result.put("current_rate", currentRate);    // 기준 환율
        result.put("risk_percent", riskPercent);    // 변동성 (%)
        result.put("expected_gap", String.format("%.1f", expectedGap)); // 예상 변동폭 (원)

        result.put("weather_icon", weatherIcon);
        result.put("weather_text", weatherText);

        // 사용자용 메시지
        String message = String.format("오늘 환율(%,.0f원) 대비 ±%s원 변동이 예상돼요.",
                currentRate, String.format("%.1f", expectedGap));
        result.put("message", message);

        return result;
    }


}