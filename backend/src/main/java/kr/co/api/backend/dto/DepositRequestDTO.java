package kr.co.api.backend.dto;


import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class DepositRequestDTO {
    private String withdrawType;     // krw / fx

    // 원화 출금
    private String acctNo;          // 원화 출금 계좌번호 (select name="acctNo")
    private String acctPw;          // 원화 출금 계좌 비밀번호

    // 외화 출금
    private String frgnAcctNo;      // 외화 출금 계좌번호
    private String frgnAcctPw;      // 외화 출금 계좌 비밀번호
    private String balNo;           // 외화통화 잔액 선택 (통화별 선택값)

    // -------------------------------
    // 신규 가입 정보
    // -------------------------------
    private String dpstHdrCurrency; // 신규 가입 통화종류
    private BigDecimal dpstAmount;  // 신규금액 (foreignAmount 입력값)
    private Integer dpstHdrMonth;   // 가입 월수
    private String selectedCurName;

    private String dpstHdrCurrencyExp;

    // 환율 계산 결과 (JS에서 hidden input 추가해야 넘어감)
    private BigDecimal baseRate;        // 송금보낼때 환율
    private BigDecimal appliedRate;     // 우대 적용 환율
    private Integer prefRate;           // 우대율 (%)
    private BigDecimal spreadHalfPref;  // 우대받는 금액 계산에 사용
    private BigDecimal krwAmount;       // 예상 원화 금액

    // -------------------------------
    // 만기자동연장 신청
    // -------------------------------
    private String autoRenewYn;
    private Integer autoRenewTerm;  // 연장 주기 월수


    private String receiveMethod;   // email / sms

    // -------------------------------
    // 정기예금 비밀번호
    // -------------------------------
    private String dpstPw;

    private LocalDate maturityDate;   // 만기일
    private BigDecimal appliedInterest;


    
}
