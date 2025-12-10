package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class QnaDTO {
    private Long qnaNo;
    private String qnaCustCode;
    private String qnaTitle;
    private String qnaContent;
    private String qnaDraft;
    private String qnaReply;
    private String qnaStatus;
    private LocalDateTime qnaDt;
    private Integer qnaViewCnt;

    // 추가 표시용 필드
    private String qnaCustName;
}
