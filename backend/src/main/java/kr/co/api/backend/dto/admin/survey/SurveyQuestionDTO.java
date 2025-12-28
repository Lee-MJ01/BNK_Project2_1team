package kr.co.api.backend.dto.admin.survey;

import lombok.Data;

import java.util.List;

@Data
public class SurveyQuestionDTO {
    private Long qId;
    private Long surveyId;
    private Integer qNo;
    private String qKey;
    private String qText;
    private String qType;
    private String isRequired;
    private Integer maxSelect;
    private String isActive;
    private String createdBy;
    private String updatedBy;
    private List<SurveyOptionDTO> options;
}
