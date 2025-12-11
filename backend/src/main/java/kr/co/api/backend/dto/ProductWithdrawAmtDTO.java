package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ProductWithdrawAmtDTO {

    private String dpstId;     // 상품 ID (FK)
    private String currency;   // USD, JPY, EUR ...
    private Integer minAmt;    // 최소 출금 금액

}