package kr.co.api.backend.dto;


import lombok.Data;

@Data
public class ExchangeRateDTO {
    private String stdDt;      // 기준일자 (STD_DT)
    private String acctCode;   // 통화코드 숫자 (ACCT_CODE)
    private String acctName;   // 통화명 (ACCT_NAME, 예: USD)
    private Double exchRate;   // 환율 (EXCH_RATE, 예: 1308.3)
}
