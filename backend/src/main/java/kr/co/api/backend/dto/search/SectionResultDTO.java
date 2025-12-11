package kr.co.api.backend.dto.search;

import lombok.Data;

import java.util.List;

@Data
public class SectionResultDTO {
    private String title;       // 탭 제목 (예: "상품", "고객센터")
    private long totalCount;    // 해당 탭의 데이터 총 개수
    private List<SearchResultItemDTO> results; // 검색 결과 리스트
}