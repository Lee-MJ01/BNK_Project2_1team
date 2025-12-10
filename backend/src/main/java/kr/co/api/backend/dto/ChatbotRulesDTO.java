package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChatbotRulesDTO {
    private Integer ruleId;
    private String ruleTxt;
    private String ruleUseYn;
    private LocalDateTime ruleRegDt;
}
