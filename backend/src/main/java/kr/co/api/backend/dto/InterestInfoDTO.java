package kr.co.api.backend.dto;

import lombok.*;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class InterestInfoDTO {
    private String interestCurrency;
    private double interestRate;
    private int interestMonth;
}
