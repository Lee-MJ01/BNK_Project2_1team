package kr.co.api.backend.dto.admin.dashboard;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TotalTxSummaryDTO {
    // today -2
    // "환전", "외화송금"
    private int count;
    private long amount;
}
