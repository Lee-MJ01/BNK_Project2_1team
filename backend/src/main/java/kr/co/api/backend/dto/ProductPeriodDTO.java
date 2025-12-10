package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ProductPeriodDTO {

    private Integer minMonth;      // 자유형 최소 가입월수
    private Integer maxMonth;      // 자유형 최대 가입월수
    private Integer fixedMonth;    // 고정형 가입기간 1개
    private String dpstId;         // 상품 ID (FK)

}
