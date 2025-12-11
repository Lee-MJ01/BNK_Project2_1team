package kr.co.api.backend.dto;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class InterestRateDTO {
    String baseDate;
    String currency;
    BigDecimal rate1M;
    BigDecimal rate2M;
    BigDecimal rate3M;
    BigDecimal rate4M;
    BigDecimal rate5M;
    BigDecimal rate6M;
    BigDecimal rate7M;
    BigDecimal rate8M;
    BigDecimal rate9M;
    BigDecimal rate10M;
    BigDecimal rate11M;
    BigDecimal rate12M;
    String createdAt;
}
