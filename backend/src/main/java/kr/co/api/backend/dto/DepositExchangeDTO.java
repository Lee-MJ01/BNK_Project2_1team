package kr.co.api.backend.dto;

import lombok.Data;
import lombok.ToString;

import java.math.BigDecimal;

@Data
@ToString
public class DepositExchangeDTO {
    private BigDecimal ttsRate;       // 전신환 보낼 때
    private BigDecimal baseRate;  // 기준환율
    private BigDecimal spreadHalfPref; // 우대 적용된 스프레드
    private BigDecimal appliedRate;   // 최종 적용 환율
    private int prefRate;

    private BigDecimal krwAmount;
}
