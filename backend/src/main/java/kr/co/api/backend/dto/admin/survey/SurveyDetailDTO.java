package kr.co.api.backend.dto.admin.survey;

import lombok.Data;

import java.util.List;

@Data
public class SurveyDetailDTO {
    private Long surveyId;
    private String title;
    private String description;
    private String isActive;
    private Integer questionCount;
    private java.time.LocalDateTime createdAt;
    private String createdBy;
    private java.time.LocalDateTime updatedAt;
    private String updatedBy;
    private List<SurveyQuestionDTO> questions;
}
