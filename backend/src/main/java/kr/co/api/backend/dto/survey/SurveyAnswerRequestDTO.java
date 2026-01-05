package kr.co.api.backend.dto.survey;

import lombok.Getter;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonProperty;


import java.util.List;

@Getter
@Setter
public class SurveyAnswerRequestDTO {

    @JsonProperty("qId")
    private Long qId;

    @JsonProperty("optIds")
    private List<Long> optIds;

    @JsonProperty("answerText")
    private String answerText;
}
