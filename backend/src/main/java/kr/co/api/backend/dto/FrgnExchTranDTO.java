package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FrgnExchTranDTO {
    private long exchNo;
    private String exchAcctNo;
    private String exchFromCurrency;
    private String exchToCurrency;
    private BigDecimal exchAmount;
    private BigDecimal exchAppliedRate;
    private String exchReqDt;
    private String exchExpDy;
    private String exchAddr;
    private BigDecimal exchFee;
    private String exchEsignYn;
    private String exchEsignDt;

    // 추가 필드
    private Long couponNo;
}
