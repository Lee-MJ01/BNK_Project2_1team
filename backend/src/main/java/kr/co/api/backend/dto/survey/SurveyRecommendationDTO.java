package kr.co.api.backend.dto.survey;

import lombok.Data;

@Data
public class SurveyRecommendationDTO {
    private String dpstId;
    private String dpstName;
    private String dpstInfo;
    private String dpstDescript;
    private String dpstCurrency;
    private Integer rankNo;
}
