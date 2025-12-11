package kr.co.api.backend.dto;

import lombok.*;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class FrgnAcctBalanceDTO {

    String balNo;
    String balCurrency;
    double balBalance;
    String balRegDt;

    String balFrgnAcctNo; // 모체 통장 계좌번호
}
