package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExchangeRiskDTO {

    // 1. DB 원본 데이터
    private String volStdDy;       // 기준일자
    private String volCurrency;    // 통화
    private Double volCurrentVal;  // 현재 위험도
    private Double volForecastVal; // 예측 위험도

    // 2. 서비스에서 계산해서 채워줄 데이터
    private String weatherIcon;       // ☀️, ☁️
    private String riskStatus;        // 안전, 주의
    private String predictionComment; // 멘트
}