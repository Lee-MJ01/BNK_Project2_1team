package kr.co.api.backend.controller.admin;

import kr.co.api.backend.dto.admin.exchange.ExchangeStatsDTO;
import kr.co.api.backend.service.admin.ExchangeAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/exchange")
@RequiredArgsConstructor
public class ExchangeAdminController {

    private final ExchangeAdminService exchangeAdminService;

    /**
     * 관리자 > 환전 관리 메인 화면 렌더링
     *
     * 포함 기능:
     * 1) 통계 데이터 (그래프: 통화별 금액 + 일자별 총액)
     * 2) 환전 이력 페이징 + 검색
     * 3) 쿠폰 발급 현황 페이징
     *
     */

    @GetMapping
    public String exchange(@RequestParam(defaultValue = "1") int page,
                           @RequestParam(name = "couponPage", defaultValue = "1") int couponPage,
                           @RequestParam(name = "searchType", required = false) String searchType,
                           @RequestParam(name = "keyword", required = false) String keyword,
                           Model model) {

        // "null" 텍스트나 null이 들어와도 검색어 공백 처리
        if (keyword == null || "null".equalsIgnoreCase(keyword)) {
            keyword = "";
        }

        // 1) 환전 통계 조회 (그래프 데이터 + 기준 시각)
        ExchangeStatsDTO stats = exchangeAdminService.getStats();

        // 2) 환전 이력 페이징 + 검색 결과
        Map<String, Object> exchangeHistory =
                exchangeAdminService.getExchangeHistoryPage(searchType, keyword, page);


        // 3) 환전 수수료 쿠폰 발급 내역 페이징
        Map<String, Object> couponPageData =
                exchangeAdminService.getCouponIssuePage(couponPage);


        // Model 데이터 바인딩
        // - admin/exchange.html에서 사용됨
        // 통계 (그래프에 전달)
        model.addAttribute("stats", stats);
        model.addAttribute("baseTime", LocalDateTime.now());

        // 환전 이력 (목록 + 페이징)
        model.addAttribute("exchangeList", exchangeHistory.get("list"));
        model.addAttribute("exchangePage", exchangeHistory.get("page"));
        model.addAttribute("exchangePageSize", exchangeHistory.get("pageSize"));
        model.addAttribute("exchangeTotalPage", exchangeHistory.get("totalPage"));
        model.addAttribute("exchangeTotalCount", exchangeHistory.get("totalCount"));

        // 쿠폰 발급 현황 (목록 + 페이징)
        model.addAttribute("couponList", couponPageData.get("list"));
        model.addAttribute("couponPage", couponPageData.get("page"));
        model.addAttribute("couponPageSize", couponPageData.get("pageSize"));
        model.addAttribute("couponTotalPage", couponPageData.get("totalPage"));
        model.addAttribute("couponTotalCount", couponPageData.get("totalCount"));

        // 검색 조건 유지
        model.addAttribute("searchType", searchType);
        model.addAttribute("keyword", keyword);

        // 좌측 사이드바 메뉴 하이라이트 처리
        model.addAttribute("activeItem", "exchange");

        // 최종 View 렌더링
        return "admin/exchange";
    }

    /**
     * AJAX 전용 엔드포인트
     * 관리자가 페이지에서 5분마다 또는 날짜 선택할 때 호출됨
     *
     * 반환 데이터:
     *  - currencyDailyAmounts : 통화별 금액 리스트
     *  - dailyTotals : 일자별 총 환전액 리스트
     *  - lastUpdatedAt : 기준 시각
     *
     */

    @GetMapping("/stats")
    @ResponseBody
    public Map<String, Object> getStats(
            @RequestParam(value = "date", required = false) String date
    ) {

        // 날짜 기반 조회 or 최신 조회 분기 처리
        ExchangeStatsDTO stats;

        if (date != null && !date.isEmpty()) {
            // 날짜별 통계 조회
            stats = exchangeAdminService.getExchangeStatsByDate(date);
        } else {
            // 전체 최신 통계 조회
            stats = exchangeAdminService.getStats();
        }

        // 결과가 null이면 완전히 빈 JSON 구조 반환
        if (stats == null) {
            return Map.of(
                    "currencyDailyAmounts", List.of(),
                    "dailyTotals", List.of(),
                    "lastUpdatedAt", null
            );
        }

        // 정상 데이터 반환
        return Map.of(
                "currencyDailyAmounts", stats.getCurrencyDailyAmounts(),
                "dailyTotals", stats.getDailyTotals(),
                "lastUpdatedAt", stats.getLastUpdatedAt()
        );
    }


    @GetMapping("/stats/range")
    @ResponseBody
    public Map<String, Object> getRangeStats(
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate
    ) {

        ExchangeStatsDTO stats = exchangeAdminService.getExchangeStatsByPeriod(startDate, endDate);

        if (stats == null || stats.getCurrencyDailyAmounts() == null || stats.getCurrencyDailyAmounts().isEmpty()) {
            return Map.of(
                    "currencyDailyAmounts", List.of(),
                    "rangeLabel", stats != null ? stats.getRangeLabel() : null,
                    "lastUpdatedAt", stats != null ? stats.getLastUpdatedAt() : null
            );
        }

        return Map.of(
                "currencyDailyAmounts", stats.getCurrencyDailyAmounts(),
                "rangeLabel", stats.getRangeLabel(),
                "lastUpdatedAt", stats.getLastUpdatedAt()
        );
        
    }

}



