package kr.co.api.backend.dto.admin.exchange;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CurrencyDailyAmountDTO {
    private String baseDate;
    private String currency;
    private BigDecimal amountKrw;

}