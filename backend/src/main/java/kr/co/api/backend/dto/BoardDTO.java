package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BoardDTO {
    private Long boardNo;
    private String boardTitle;
    private String boardContent;
    private String boardAdminId;
    private LocalDateTime boardRegDt;
    private Integer boardHit;
    private Integer boardType;
}
