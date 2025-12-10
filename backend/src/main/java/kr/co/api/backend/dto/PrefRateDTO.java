package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class PrefRateDTO {
    private String prefCurrency; // 통화 코드 CHAR(3)
    private Double prefRate;     // 우대 환율 NUMBER (소수 가능)
}
