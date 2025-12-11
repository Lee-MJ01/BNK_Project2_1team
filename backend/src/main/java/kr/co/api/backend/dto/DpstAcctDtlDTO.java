package kr.co.api.backend.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class DpstAcctDtlDTO {
    private Long dpstDtlNo;
    private Integer dpstDtlType;
    private BigDecimal dpstDtlAmount;
    private LocalDateTime dpstTranDt;
    private String dpstDtlHdrNo;
    private String dpstDtlEsignYn;
    private LocalDateTime dpstDtlEsignDt;
    private BigDecimal dpstDtlAppliedRate;

    // 예금계좌 추가 필드
    private String dpstHdrCustCode;
    private String dpstHdrCurrencyExp;
    private String dpstHdrBalance;
    
    // 계좌해지 추가 필드
    private BigDecimal incomeTax;
    private BigDecimal localTax;
    private BigDecimal totalInterest;



}
