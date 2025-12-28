package kr.co.api.backend.dto.admin.survey;

import lombok.Data;

import java.util.List;

@Data
public class SurveyQuestionRequestDTO {
    private Integer qNo;
    private String qKey;
    private String qText;
    private String qType;
    private String isRequired;
    private Integer maxSelect;
    private String isActive;
    private List<SurveyOptionRequestDTO> options;
}
