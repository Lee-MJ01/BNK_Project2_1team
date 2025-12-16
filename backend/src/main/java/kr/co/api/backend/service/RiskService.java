package kr.co.api.backend.service;


import kr.co.api.backend.dto.ExchangeRiskDTO;
import kr.co.api.backend.mapper.RiskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RiskService {

    private final RiskMapper riskMapper;

    public List<ExchangeRiskDTO> getRiskDataByDate(String date) {

        // 1. DB에서 DTO로 바로 조회 (이 시점에는 숫자 데이터만 있고, 날씨/멘트는 null임)
        List<ExchangeRiskDTO> dtoList = riskMapper.selectByDate(date);

        // 2. 리스트를 돌면서 비어있는 날씨와 멘트를 채워줌 (Business Logic)
        for (ExchangeRiskDTO dto : dtoList) {
            fillRiskInfo(dto);
        }

        return dtoList;
    }

    // DTO의 숫자를 보고 -> 날씨/멘트를 계산해서 -> DTO에 set 해주는 메서드
    private void fillRiskInfo(ExchangeRiskDTO dto) {
        double current = dto.getVolCurrentVal();
        double next = dto.getVolForecastVal();

        // (1) 날씨 판별
        if (current < 10.0) {
            dto.setWeatherIcon("☀️");
            dto.setRiskStatus("안전");
        } else if (current < 20.0) {
            dto.setWeatherIcon("☁️");
            dto.setRiskStatus("주의");
        } else {
            dto.setWeatherIcon("⛈️");
            dto.setRiskStatus("위험");
        }

        // (2) 예측 멘트 판별
        double diff = next - current;
        if (diff < -0.05) {
            dto.setPredictionComment("내일은 변동성이 줄어들 예정이에요!");
        } else if (diff > 0.05) {
            dto.setPredictionComment("내일은 변동성이 커질 수 있어요!");
        } else {
            dto.setPredictionComment("오늘과 비슷한 흐름이 이어질 거예요!");
        }
    }
}