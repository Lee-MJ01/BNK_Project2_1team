package kr.co.api.backend.dto.search;

import lombok.Data;

@Data
public class SearchTokenDTO {
    private Long tokNo;      // 순번 (SEQ_SEARCH_TOKEN)
    private String tokTxt;   // 검색어
}