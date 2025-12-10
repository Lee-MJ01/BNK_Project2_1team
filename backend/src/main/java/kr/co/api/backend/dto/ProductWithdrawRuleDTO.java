package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ProductWithdrawRuleDTO {

    private String dpstId;       // 상품 ID (FK)
    private Integer minMonths;   // 인출 가능 시점 (가입 후 N개월)
    private Integer maxCount;    // 최대 인출 횟수

}

