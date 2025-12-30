package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class DpstAcctDraftDTO {
    private Long dpstDraftNo;
    private String dpstDraftDpstId;
    private String dpstDraftCustCode;
    private Integer dpstDraftMonth;
    private Integer dpstDraftStep;
    private String dpstDraftCurrency;
    private String dpstDraftFxWithdrawCcy;
    private String dpstDraftLinkedAcctNo;
    private String dpstDraftAutoRenewYn;
    private Integer dpstDraftAutoRenewTerm;
    private String dpstDraftAutoTermiYn;
    private LocalDateTime dpstDraftUpdatedDt;
    private BigDecimal dpstDraftAmount;
    private BigDecimal dpstDraftAppliedRate;
    private BigDecimal dpstDraftAppliedFxRate;
}
