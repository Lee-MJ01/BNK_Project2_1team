package kr.co.api.backend.dto.admin.dashboard;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class DailyTxSummaryDTO {

    private LocalDate baseDate;   // TRUNC(tran_dt)
    private long count;           // 일별 거래건수
    private BigDecimal amount;    // 일별 거래금액
}
