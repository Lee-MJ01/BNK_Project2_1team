package kr.co.api.backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class DpstAcctDraftRequestDTO {
    private Integer month;
    private Integer step;
    private String currency;
    private String linkedAccountNo;
    private Boolean autoRenewYn;
    private Integer autoRenewTerm;
    private Boolean autoTerminationYn;
    private BigDecimal amount;
}
