package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SurveyOptionValueDTO {
    private Long optId;
    private Long qId;
    private String optValue;
}
