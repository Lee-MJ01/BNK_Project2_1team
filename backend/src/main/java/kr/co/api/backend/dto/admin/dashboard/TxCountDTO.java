package kr.co.api.backend.dto.admin.dashboard;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TxCountDTO {
    // today -1
    // "건수", "금액"
    private String type;
    private long count;
}
