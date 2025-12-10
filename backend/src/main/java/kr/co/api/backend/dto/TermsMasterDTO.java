package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class TermsMasterDTO {
    private Integer termCate;       // 카테고리
    private Integer termOrder;      // 트리거 자동 생성
    private String termTitle;       // 제목
    private String termRegDy;       // 등록일

    // 최신 버전 정보 + 화면 표시용
    private Integer latestVersion;
    private String latestRegDy;
}
