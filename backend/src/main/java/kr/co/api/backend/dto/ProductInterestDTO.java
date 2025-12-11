package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ProductInterestDTO {

    private String interestCurrency; // 통화코드 CHAR(3)
    private Integer interestMonth;   // 기간 구분 (NUMBER)
    private Double interestRate;     // 이율 (NUMBER 소수 포함)



}
