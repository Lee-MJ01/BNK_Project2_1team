package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SurveyResponseRequestDTO {
    private String custCode;
    private List<SurveyAnswerRequestDTO> answers;
}
