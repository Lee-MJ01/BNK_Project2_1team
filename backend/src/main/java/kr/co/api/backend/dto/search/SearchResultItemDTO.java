package kr.co.api.backend.dto.search;

import lombok.Data;

@Data
public class SearchResultItemDTO {
    private String title;    // 제목 (상품명, 질문 등)
    private String summary;  // 요약 내용 (본문 앞부분)
    private String url;      // 클릭 시 이동할 링크 URL
    private String extra;    // 추가 정보 (날짜 등, 필요 없으면 null)
}