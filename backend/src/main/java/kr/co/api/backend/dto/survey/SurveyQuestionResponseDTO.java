package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SurveyQuestionResponseDTO {
    private Long qId;
    private Integer qNo;
    private String qKey;
    private String qText;
    private String qType;
    private String isRequired;
    private Integer maxSelect;
    private List<SurveyOptionResponseDTO> options;
}
