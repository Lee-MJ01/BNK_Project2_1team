package kr.co.api.backend.service.admin;

import jakarta.annotation.PostConstruct;
import kr.co.api.flobankapi.dto.admin.exchange.*;
import kr.co.api.flobankapi.mapper.admin.ExchangeAdminMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExchangeAdminService {

    private final ExchangeAdminMapper exchangeAdminMapper;

    /**
     * 환전 통계 캐싱 객체
     * - 통화별 일자 환전액
     * - 일자별 총 환전액
     * - 기준 시각
     *
     * 성능 최적화를 위해 즉시 DB 조회하지 않고 캐시에서 제공
     */
    private ExchangeStatsDTO statsCache;

    /**
     * 서버 구동 직후 1회 호출
     * 초기 통계 캐시 로드
     */
    @PostConstruct
    public void init() {
        refreshStats();
    }

    /**
     * 5분마다 자동으로 환전 통계 업데이트 (스케줄러)
     *
     * fixedRate = 300,000ms (5분)
     *
     * synchronized: 동시 실행 방지 (멀티쓰레드에서 안전하게 캐시 갱신)
     */
    @Scheduled(fixedRate = 5 * 60 * 1000)
    public synchronized void refreshStats() {
        log.info("Refreshing exchange admin stats...");

        // 통계 기반 시각 조회 (환전 요청 테이블 기준)
        LocalDateTime baseTime = exchangeAdminMapper.selectStatsBaseTime();

        // 캐시 재생성
        statsCache = ExchangeStatsDTO.builder()
                .currencyDailyAmounts(exchangeAdminMapper.selectDailyCurrencyAmounts())
                .dailyTotals(exchangeAdminMapper.selectDailyTotalAmounts())
                .lastUpdatedAt(baseTime != null ? baseTime : LocalDateTime.now())
                .build();
    }

    /**
     * 관리자 페이지에서 사용하는 통계 조회
     * - 캐시가 없으면 즉시 로드
     */
    public ExchangeStatsDTO getStats() {
        if (statsCache == null) {
            refreshStats(); // fallback
        }
        return statsCache;
    }

    /**
     * 환전 이력 조회 서비스 (검색 + 페이징)
     *
     * @param searchType 검색 타입 (customer / exchange)
     * @param keyword    검색어
     * @param page       현재 페이지
     *
     * @return Map (list, page, pageSize, totalPage, totalCount)
     */
    public Map<String, Object> getExchangeHistoryPage(String searchType, String keyword, int page) {

        int pageSize = 10;  // 한 페이지당 노출 개수

        // 총 개수 조회
        int totalCount = exchangeAdminMapper.countExchangeHistory(searchType, keyword);

        // 총 페이지 계산
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;

        // 현재 페이지 보정
        int currentPage = Math.min(Math.max(page, 1), totalPage);

        // 데이터 조회 범위 계산 (Oracle 기준 1 ~ n 방식)
        int start = (currentPage - 1) * pageSize + 1;
        int end = currentPage * pageSize;

        // 환전 데이터 조회
        List<ExchangeHistoryDTO> list =
                exchangeAdminMapper.selectExchangeHistory(searchType, keyword, start, end);

        if (list == null) list = Collections.emptyList();

        // 결과 구성
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", currentPage);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        return result;
    }

    /**
     * 쿠폰 발급 현황 조회 서비스 (페이징)
     *
     * @param page 쿠폰 페이지 번호
     * @return Map (list, page, pageSize, totalPage, totalCount)
     */
    public Map<String, Object> getCouponIssuePage(int page) {

        int pageSize = 5;  // 쿠폰 테이블은 한 페이지 5개 노출

        // 전체 개수 조회
        int totalCount = exchangeAdminMapper.countCouponIssues();

        // 총 페이지 수
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;

        // 현재 페이지 보정
        int currentPage = Math.min(Math.max(page, 1), totalPage);

        // Oracle 페이징 범위
        int start = (currentPage - 1) * pageSize + 1;
        int end = currentPage * pageSize;

        // 쿠폰 조회
        List<CouponIssueDTO> list = exchangeAdminMapper.selectCouponIssues(start, end);
        if (list == null) list = Collections.emptyList();

        // 결과 구성
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", currentPage);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        return result;
    }


    public List<CurrencyDailyAmountDTO> getDailyCurrencyAmountsByDate(String date) {
        return exchangeAdminMapper.selectDailyCurrencyAmountsByDate(date);
    }

    public List<DailyExchangeAmountDTO> getDailyTotalAmountsByDate(String date) {
        return exchangeAdminMapper.selectDailyTotalAmountsByDate(date);
    }

    public ExchangeStatsDTO getExchangeStatsByDate(String date) {

        return ExchangeStatsDTO.builder()
                .currencyDailyAmounts(exchangeAdminMapper.selectDailyCurrencyAmountsByDate(date))
                .dailyTotals(exchangeAdminMapper.selectDailyTotalAmountsByDate(date))
                .lastUpdatedAt(exchangeAdminMapper.selectStatsBaseTime())
                .build();
    }


    public ExchangeStatsDTO getExchangeStatsByPeriod(String startDate, String endDate) {

        List<CurrencyDailyAmountDTO> amounts = exchangeAdminMapper.selectCurrencyAmountsByPeriod(startDate, endDate);
        if (amounts == null) {
            amounts = Collections.emptyList();
        }

        return ExchangeStatsDTO.builder()
                .currencyDailyAmounts(amounts)
                // 오른쪽 그래프는 기간 조회에 영향을 받지 않도록 빈 리스트 유지
                .dailyTotals(Collections.emptyList())
                .lastUpdatedAt(exchangeAdminMapper.selectStatsBaseTime())
                .rangeLabel(String.format("%s ~ %s", startDate, endDate))
                .build();
    }





}
