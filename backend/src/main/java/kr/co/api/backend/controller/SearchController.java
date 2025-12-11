package kr.co.api.backend.controller;

import kr.co.api.flobankapi.dto.search.SearchLogDTO;
import kr.co.api.flobankapi.dto.search.SearchResultResponseDTO;
import kr.co.api.flobankapi.service.SearchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    //  현재 로그인한 사용자 ID 가져오기
    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null) {
            return null;
        }

        if (!authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return null;
        }
        return authentication.getName(); // 로그인 ID (custCode)
    }

    // 1. 통합 검색 (저장 로직 포함)
    @GetMapping("/integrated")
    public SearchResultResponseDTO integratedSearch(@RequestParam(name = "keyword") String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new SearchResultResponseDTO();
        }

        String custCode = getCurrentUserId();

        searchService.saveSearchKeyword(keyword, custCode);

        return searchService.integratedSearchPreview(keyword);
    }

    // 2. 탭별 상세 검색
    @GetMapping("/tab")
    public SearchResultResponseDTO tabSearch(
            @RequestParam(name = "keyword") String keyword,
            @RequestParam(name = "type") String type,
            @RequestParam(name = "page", defaultValue = "0") int page) {
        return searchService.tabSearch(keyword, type, page);
    }

    // 3. 최근 검색어 조회
    @GetMapping("/keywords/recent")
    public List<SearchLogDTO> getRecentKeywords() {
        String custCode = getCurrentUserId();
        if (custCode == null) return List.of();
        return searchService.getRecentKeywords(custCode);
    }

    // 4. 인기 검색어 조회
    @GetMapping("/keywords/popular")
    public List<SearchLogDTO> getPopularKeywords() {
        return searchService.getPopularKeywords();
    }

    // 🗑5. 최근 검색어 삭제 (개별)
    @DeleteMapping("/keywords")
    public void deleteSearchKeyword(@RequestParam(name = "keyword") String keyword) {
        String custCode = getCurrentUserId();



        if (custCode != null) {
            searchService.deleteSearchKeyword(keyword, custCode);

        } else {

        }
    }

    // 6. 검색어 자동 완성
    @GetMapping("/autocomplete")
    public List<String> getAutoCompletion(@RequestParam(name = "keyword") String keyword) {
        return searchService.getAutoCompletion(keyword);
    }
    
    
}