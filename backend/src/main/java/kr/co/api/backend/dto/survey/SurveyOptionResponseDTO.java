package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SurveyOptionResponseDTO {
    private Long optId;
    private String optCode;
    private String optText;
    private String optValue;
    private Integer optOrder;
}
