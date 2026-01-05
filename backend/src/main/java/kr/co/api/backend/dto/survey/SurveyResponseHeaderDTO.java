package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SurveyResponseHeaderDTO {
    private Long respId;
    private Long surveyId;
    private String custCode;
    private String status;
}
