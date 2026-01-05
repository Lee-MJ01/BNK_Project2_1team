package kr.co.api.backend.dto.survey;

import lombok.Data;

@Data
public class SurveyResponseAnswerDTO {
    private Long qId;
    private Long optId;
    private String optValue;
}
