package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SurveyResponseDetailDTO {
    private Long respId;
    private Long qId;
    private Long optId;
    private String answerText;
}
