package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SurveyDetailResponseDTO {
    private Long surveyId;
    private String title;
    private String description;
    private List<SurveyQuestionResponseDTO> questions;
}
