package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FrgnRemtTranDTO {
    long remtNo;
    String remtAcctNo;
    String remtCustName;
    BigDecimal remtAmount;
    String remtDt;
    String remtRecAccNo;
    String remtRecName;
    String remtRecBkCode;
    String remtCurrency;
    BigDecimal remtAppliedRate;
    BigDecimal remtFee;
    int remtStatus;
    String remtAddr;
    String remtCity;
    String remtState;
    String remtApproveNo;
    String remtEsignYn;
    String remtEsignDt;
    String remtCountry;
}
