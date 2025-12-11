package kr.co.api.backend.dto.search;

import lombok.Data;

import java.util.Map;

@Data
public class SearchResultResponseDTO {
    // 전체 검색 건수 (모든 탭 합산)
    private long totalCount;

    // 각 탭별 결과 (Key: "product", "faq" 등)
    private Map<String, SectionResultDTO> sections;
}