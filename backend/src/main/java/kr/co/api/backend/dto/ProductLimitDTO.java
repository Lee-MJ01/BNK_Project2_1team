package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ProductLimitDTO {

    private String lmtDpstId;     // 예금상품 ID
    private String lmtCurrency;   // 통화코드 (USD, JPY 등)
    private Integer lmtMinAmt;    // 최소 가입액
    private Integer lmtMaxAmt;    // 최대 가입액

}
