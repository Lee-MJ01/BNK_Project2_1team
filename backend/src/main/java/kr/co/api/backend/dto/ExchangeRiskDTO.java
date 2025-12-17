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
    private Double volCurrentVal;  // 현재 변동성
    private Double volForecastVal; // 내일 변동성
    
}