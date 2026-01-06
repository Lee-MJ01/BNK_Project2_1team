package kr.co.api.backend.dto.survey;

import lombok.Data;

@Data
public class SurveyRecommendationInsertDTO {
    private String custCode;
    private Long surveyId;
    private Integer rankNo;
    private String productId;
}
