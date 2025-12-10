package kr.co.api.backend.dto;


import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChatbotBadTypeDTO {
    private Integer btNo;
    private String btAnswer;
    private LocalDateTime btUpdDt;
}
