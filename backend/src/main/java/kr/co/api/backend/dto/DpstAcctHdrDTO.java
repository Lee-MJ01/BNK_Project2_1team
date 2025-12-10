package kr.co.api.backend.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class DpstAcctHdrDTO {
    private String dpstHdrAcctNo;
    private String dpstHdrDpstId;
    private String dpstHdrPw;            // 예금 비밀번호 (BCrypt 암호화 저장)
    private String dpstHdrCustCode;
    private Integer dpstHdrMonth;

    private String dpstHdrStartDy;
    private String dpstHdrFinDy;

    private String dpstHdrCurrency;
    private String dpstHdrCurrencyExp;
    private BigDecimal dpstHdrBalance;

    private BigDecimal dpstHdrInterest;  // 적용된 금리
    private Integer dpstHdrStatus;       // 상태 (1: 정상)

    private String dpstHdrLinkedAcctNo;  // 출금 계좌번호 (원화 또는 외화)
    private String dpstHdrExpAcctNo;
    private int dpstHdrLinkedAcctType;

    private String dpstHdrAutoRenewYn;   // 자동연장 여부 (Y/N)
    private Integer dpstHdrAutoRenewCnt; // 자동연장 횟수
    private Integer dpstHdrAutoRenewTerm;// 자동연장 주기 (개월)

    private String dpstHdrAutoTermiYn;
    private BigDecimal dpstHdrRate;

    private Integer dpstHdrAddPayCnt;
    private Integer dpstHdrPartWdrwCnt;

    private String dpstHdrInfoAgreeYn;
    private LocalDateTime dpstHdrInfoAgreeDt;
    private LocalDateTime dpstHdrContractDt;

    private BigDecimal dpstHdrLinkedAcctBal;

    public String getFormattedCurrency() {
        String symbol = switch (dpstHdrCurrencyExp) {
            case "KRW" -> "₩";
            case "USD", "AUD" -> "$";
            case "CNH", "CNY", "JPY" -> "¥";
            case "GBP" -> "£";
            case "EUR" -> "€";
            default -> "?";
        };
        return symbol;
    }
}
