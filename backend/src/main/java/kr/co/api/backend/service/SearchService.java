package kr.co.api.backend.service;

import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch.core.search.CompletionSuggester;
import co.elastic.clients.elasticsearch.core.search.FieldCollapse;
import co.elastic.clients.elasticsearch.core.search.FieldSuggester;
import co.elastic.clients.elasticsearch.core.search.Suggester;
import kr.co.api.flobankapi.document.*;
import kr.co.api.flobankapi.dto.search.SearchLogDTO;
import kr.co.api.flobankapi.dto.search.SearchResultItemDTO;
import kr.co.api.flobankapi.dto.search.SearchResultResponseDTO;
import kr.co.api.flobankapi.dto.search.SectionResultDTO;
import kr.co.api.flobankapi.mapper.SearchMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.elasticsearch.client.elc.NativeQuery;
import org.springframework.data.elasticsearch.client.elc.NativeQueryBuilder;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.query.Query;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SearchService {

    private final ElasticsearchOperations elasticsearchOperations;
    private final SearchMapper searchMapper;

    private static final int PREVIEW_SIZE = 4;
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy.MM.dd");

    // ======================================================================
    //  검색어 저장
    // ======================================================================
    public void saveSearchKeyword(String keyword, String custCode) {
        if (keyword == null || keyword.trim().isEmpty()) return;

        // 1. 인기 검색어 저장
        searchMapper.insertSearchToken(keyword.trim());

        // 2. 로그인 사용자만 최근 검색어 저장
        if (custCode != null && !custCode.equals("ANONYMOUS") && !custCode.equals("null")) {

            // 기존 검색어 삭제 (중복 방지)
            searchMapper.deleteDuplicateSearchLog(keyword.trim(), custCode);

            // 최신 검색어로 INSERT (한 줄만 유지)
            searchMapper.insertSearchLog(keyword.trim(), custCode);
        }
    }

    // ======================================================================
    // 검색어 조회
    // ======================================================================
    public List<SearchLogDTO> getPopularKeywords() {
        return searchMapper.selectPopularKeywords();
    }

    public List<SearchLogDTO> getRecentKeywords(String custCode) {
        return searchMapper.selectRecentKeywords(custCode);
    }

    // ======================================================================
    //  1. 통합 검색 미리보기
    // ======================================================================
    public SearchResultResponseDTO integratedSearchPreview(String keyword) {
        SearchResultResponseDTO response = new SearchResultResponseDTO();
        response.setSections(new HashMap<>());

        if (keyword == null || keyword.trim().isEmpty()) return response;

        List<Query> queries = new ArrayList<>();
        List<Class<?>> classes = new ArrayList<>();
        List<String> tabKeys = new ArrayList<>();

        // 1) 상품
        queries.add(buildNativeQuery(keyword, PREVIEW_SIZE, "dpstName^10", "dpstInfo^3", "dpstDescript"));
        classes.add(ProductDocument.class);
        tabKeys.add("product");

        // 2) FAQ
        queries.add(buildNativeQuery(keyword, PREVIEW_SIZE, "faqQuestion^5", "faqAnswer"));
        classes.add(FaqDocument.class);
        tabKeys.add("faq");

        // 3) 약관
        NativeQuery termsQuery = NativeQuery.builder()
                .withQuery(q -> q.multiMatch(m -> m
                        .query(keyword)
                        .fields(List.of("termTitle^5", "thistContent"))
                        .operator(Operator.And)
                ))
                .withMaxResults(PREVIEW_SIZE)
                .withFieldCollapse(FieldCollapse.of(f -> f.field("groupKey")))
                .withSort(Sort.by(Sort.Direction.DESC, "thistVersion"))
                .build();

        queries.add(termsQuery);
        classes.add(TermDocument.class);
        tabKeys.add("docs");

        // 4) 공지
        queries.add(buildNativeQuery(keyword, PREVIEW_SIZE, "boardTitle^5", "boardContent"));
        classes.add(NoticeDocument.class);
        tabKeys.add("notice");

        // 5) 이벤트
        queries.add(buildNativeQuery(keyword, PREVIEW_SIZE, "boardTitle^5", "boardContent", "eventBenefit"));
        classes.add(EventDocument.class);
        tabKeys.add("event");

        List<SearchHits<?>> multiHits = elasticsearchOperations.multiSearch(queries, classes);
        long totalCount = 0;

        for (int i = 0; i < multiHits.size(); i++) {
            SearchHits<?> hits = multiHits.get(i);
            String key = tabKeys.get(i);

            SectionResultDTO sectionDTO = mapHitsToSection(hits, key);
            response.getSections().put(key, sectionDTO);
            totalCount += hits.getTotalHits();
        }
        response.setTotalCount(totalCount);
        return response;
    }

    // ======================================================================
    //  2. 탭별 상세 검색
    // ======================================================================
    public SearchResultResponseDTO tabSearch(String keyword, String type, int page) {
        SearchResultResponseDTO response = new SearchResultResponseDTO();
        if (keyword == null || type == null) return response;

        Pageable pageable = PageRequest.of(page, 10);
        Query query;
        Class<?> docClass;

        switch (type) {
            case "product":
                query = buildNativeQuery(keyword, pageable, "dpstName^3", "dpstInfo", "dpstDescript");
                docClass = ProductDocument.class;
                break;
            case "faq":
                query = buildNativeQuery(keyword, pageable, "faqQuestion^3", "faqAnswer");
                docClass = FaqDocument.class;
                break;
            case "docs":
                NativeQueryBuilder queryBuilder = NativeQuery.builder()
                        .withQuery(q -> q.multiMatch(m -> m
                                .query(keyword)
                                .fields(List.of("termTitle^3", "thistContent"))
                                .operator(Operator.And)
                        ));
                queryBuilder.withFieldCollapse(FieldCollapse.of(f -> f.field("groupKey")));
                queryBuilder.withSort(Sort.by(Sort.Direction.DESC, "thistVersion"));
                queryBuilder.withPageable(pageable);
                query = queryBuilder.build();
                docClass = TermDocument.class;
                break;
            case "notice":
                query = buildNativeQuery(keyword, pageable, "boardTitle^3", "boardContent");
                docClass = NoticeDocument.class;
                break;
            case "event":
                query = buildNativeQuery(keyword, pageable, "boardTitle^3", "boardContent", "eventBenefit");
                docClass = EventDocument.class;
                break;
            default:
                return response;
        }

        SearchHits<?> hits = elasticsearchOperations.search(query, docClass);
        SectionResultDTO section = mapHitsToSection(hits, type);
        response.setSections(Map.of(type, section));
        response.setTotalCount(hits.getTotalHits());
        return response;
    }

    // ======================================================================
    // 내부 헬퍼 메서드
    // ======================================================================
    private NativeQuery buildNativeQuery(String keyword, int size, String... fields) {
        return NativeQuery.builder()
                .withQuery(q -> q.multiMatch(m -> m
                        .query(keyword)
                        .fields(List.of(fields))
                        .operator(Operator.And) //  모든 단어가 다 포함되어야 검색됨
                ))
                .withMaxResults(size)
                .build();
    }

    private NativeQuery buildNativeQuery(String keyword, Pageable pageable, String... fields) {
        return NativeQuery.builder()
                .withQuery(q -> q.multiMatch(m -> m
                        .query(keyword)
                        .fields(List.of(fields))
                        .operator(Operator.And) //
                ))
                .withPageable(pageable)
                .build();
    }

    private SectionResultDTO mapHitsToSection(SearchHits<?> hits, String key) {
        SectionResultDTO dto = new SectionResultDTO();
        dto.setTitle(getTabTitle(key));
        dto.setTotalCount((int) hits.getTotalHits());
        List<SearchResultItemDTO> items = hits.getSearchHits().stream()
                .map(hit -> convertDocumentToDTO(hit.getContent(), key))
                .collect(Collectors.toList());
        dto.setResults(items);
        return dto;
    }

    private SearchResultItemDTO convertDocumentToDTO(Object doc, String type) {
        SearchResultItemDTO item = new SearchResultItemDTO();
        try {
            switch (type) {
                case "product":
                    ProductDocument p = (ProductDocument) doc;
                    item.setTitle(p.getDpstName());
                    item.setSummary(safeSummary(p.getDpstInfo()));
                    item.setUrl("/deposit/view?dpstId=" + p.getDpstId());
                    break;
                case "faq":
                    FaqDocument f = (FaqDocument) doc;
                    item.setTitle(f.getFaqQuestion());
                    item.setSummary(safeSummary(f.getFaqAnswer()));
                    item.setUrl("/customer/faq_list");
                    break;
                case "docs":
                    TermDocument t = (TermDocument) doc;
                    item.setTitle(t.getTermTitle() + " (v" + t.getThistVersion() + ")");
                    item.setSummary(safeSummary(t.getThistContent()));

                    String filePath = t.getThistFile();

                    // [수정 2] 순수 파일 경로만 처리
                    if (filePath != null && !filePath.isBlank()) {
                        // DB에 '/uploads'로 시작하지 않는 경우를 대비해 '/'만 붙여줌
                        if (!filePath.startsWith("/")) {
                            item.setUrl("/" + filePath);
                        } else {
                            item.setUrl(filePath);
                        }
                    } else {
                        item.setUrl("#");
                    }

                    if (t.getThistRegDy() != null) item.setExtra(t.getThistRegDy().format(DATE_FMT));
                    break;
                case "notice":
                    NoticeDocument n = (NoticeDocument) doc;
                    item.setTitle("[공지] " + n.getBoardTitle());
                    item.setSummary(safeSummary(n.getBoardContent()));
                    item.setUrl("/customer/notice_view/" + n.getBoardNo());
                    if (n.getBoardRegDt() != null) item.setExtra(n.getBoardRegDt().format(DATE_FMT));
                    break;
                case "event":
                    EventDocument e = (EventDocument) doc;
                    item.setTitle("[이벤트] " + e.getBoardTitle());
                    item.setSummary(safeSummary(e.getBoardContent()));
                    item.setUrl("/customer/event_view/" + e.getBoardNo());
                    if (e.getBoardRegDt() != null) item.setExtra(e.getBoardRegDt().format(DATE_FMT));
                    break;
            }
        } catch (Exception e) {
            log.warn("DTO 매핑 오류: {}", e.getMessage());
        }
        return item;
    }

    private String safeSummary(String content) {
        if (content == null) return "";
        return content.length() > 60 ? content.substring(0, 60) + "..." : content;
    }

    private String getTabTitle(String key) {
        return switch (key) {
            case "product" -> "상품";
            case "faq" -> "FAQ";
            case "docs" -> "약관";
            case "notice" -> "공지사항";
            case "event" -> "이벤트";
            default -> key;
        };
    }

    // 검색어 삭제 기능
    public void deleteSearchKeyword(String keyword, String custCode) {
        if (keyword == null || keyword.trim().isEmpty()) return;
        if (custCode == null) return;

        searchMapper.deleteSearchLog(keyword.trim(), custCode);
    }

    // 자동 완성 기능
    public List<String> getAutoCompletion(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }

        try {
            // 1. Completion Suggester 빌드 (Elasticsearch 8.x / Spring Data ES 5.x 스타일)
            // 'suggest'라는 이름의 필드에서, 사용자가 입력한 keyword로 시작하는 단어를 찾음

            // NativeQuery를 사용해 suggest 쿼리를 직접 구성합니다.
            NativeQuery query = NativeQuery.builder()
                    .withSuggester(new Suggester.Builder()
                            .suggesters("my-suggestion", new FieldSuggester.Builder()
                                    .completion(new CompletionSuggester.Builder()
                                            .field("suggest")        // Document에 정의한 필드명
                                            .size(10)                // 최대 10개 제안
                                            .skipDuplicates(true)    // 중복 제거
                                            .build())
                                    .text(keyword)               // 사용자가 입력한 검색어 접두사
                                    .build())
                            .build())
                    .build();

            // 2. 검색 실행 (Product 인덱스에서 찾기 예시 - 필요하면 여러 인덱스 조회 가능)
            SearchHits<ProductDocument> searchHits = elasticsearchOperations.search(query, ProductDocument.class);

            // 3. 결과 파싱
            List<String> resultList = new ArrayList<>();

            // 응답에서 Suggestion 부분만 꺼내옵니다.
            var suggestions = searchHits.getSuggest().getSuggestion("my-suggestion");

            if (suggestions != null) {
                // 제안된 검색어(text)만 추출해서 리스트에 담음
                suggestions.getEntries().forEach(entry -> {
                    entry.getOptions().forEach(option -> {
                        resultList.add(option.getText());
                    });
                });
            }

            return resultList;

        } catch (Exception e) {
            log.error("자동완성 검색 중 오류: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

}