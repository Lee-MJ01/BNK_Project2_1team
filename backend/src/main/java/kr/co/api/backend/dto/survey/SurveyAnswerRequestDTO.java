package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SurveyAnswerRequestDTO {
    private Long qId;
    private List<Long> optIds;
    private String answerText;
}
