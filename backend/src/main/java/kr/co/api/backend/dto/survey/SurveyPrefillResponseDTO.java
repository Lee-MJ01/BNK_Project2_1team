package kr.co.api.backend.dto.survey;

import lombok.Data;

@Data
public class SurveyPrefillResponseDTO {
    private String preferredCurrency;
    private Integer preferredPeriodMonths;
    private Integer preferredAmount;
    private String withdrawType;
    private String preferredKrwAccountType;
}
