package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BriefingDTO {
    private Long briefingId;
    private String briefingMode;    // oneday, recent5 등
    private LocalDateTime briefingDate;
    private String content;         // CLOB → String
    private LocalDateTime createdAt;
}
