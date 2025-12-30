package kr.co.api.backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
public class DpstAcctDraftResponseDTO {
    private Long draftNo;
    private String dpstId;
    private String customerCode;
    private String currency;
    private Integer month;
    private Integer step;
    private String linkedAccountNo;
    private String autoRenewYn;
    private Integer autoRenewTerm;
    private String autoTerminationYn;
    private BigDecimal amount;
    private LocalDateTime updatedAt;
}
