package kr.co.api.backend.dto;


import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
public class DepositRateDTO {
    private Date baseDate;

    // 통화 코드 (USD, JPY, EUR 등)
    private String currency;
    private BigDecimal rate1M;
    private BigDecimal rate2M;
    private BigDecimal rate3M;
    private BigDecimal rate4M;
    private BigDecimal rate5M;
    private BigDecimal rate6M;
    private BigDecimal rate7M;
    private BigDecimal rate8M;
    private BigDecimal rate9M;
    private BigDecimal rate10M;
    private BigDecimal rate11M;
    private BigDecimal rate12M;
}

