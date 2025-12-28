package kr.co.api.backend.dto.admin.survey;

import lombok.Data;

@Data
public class SurveyOptionRequestDTO {
    private String optCode;
    private String optText;
    private String optValue;
    private Integer optOrder;
    private String isActive;
}
