package kr.co.api.backend.mapper.admin;

import kr.co.api.backend.dto.admin.exchange.CouponIssueDTO;
import kr.co.api.backend.dto.admin.exchange.CurrencyDailyAmountDTO;
import kr.co.api.backend.dto.admin.exchange.DailyExchangeAmountDTO;
import kr.co.api.backend.dto.admin.exchange.ExchangeHistoryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 관리자 환전 관리 페이지 전용 Mapper
 *
 * 제공 기능:
 *  - 일자별 / 통화별 환전 금액 조회 (그래프 1)
 *  - 일자별 총 환전 금액 조회 (그래프 2)
 *  - 환전 이력 조회 (검색 + 페이징)
 *  - 환전 수수료 쿠폰 발급 현황 조회 (페이징)
 *  - 통계 기준 시각 조회
 */
@Mapper
public interface ExchangeAdminMapper {

    /**
     * 일자 + 통화별 환전 총액 조회
     * 그래프 ① "일자별 통화 환전금액"에 사용됨.
     *
     * 반환 DTO:
     *  - baseDate  : yyyy-MM-dd
     *  - currency  : USD / JPY / EUR / GBP / CNH / AUD 등
     *  - amountKrw : KRW 환산 금액 합산
     */
    List<CurrencyDailyAmountDTO> selectDailyCurrencyAmounts();

    /**
     * 일자별 전체 환전 총액 조회
     * 그래프 ② "일자별 환전액"에 사용됨.
     *
     * 반환 DTO:
     *  - baseDate  : yyyy-MM-dd
     *  - amountKrw : KRW 환산 일별 합계
     */
    List<DailyExchangeAmountDTO> selectDailyTotalAmounts();

    /**
     * 통계 기준 시각 조회
     * (5분 단위 스케줄러가 업데이트한 최신 시간)
     */
    LocalDateTime selectStatsBaseTime();

    /**
     * 환전 이력 전체 개수 조회
     * 검색 조건 적용됨.
     *
     * @param searchType (customer / exchange)
     * @param keyword    검색어
     */
    int countExchangeHistory(@Param("searchType") String searchType,
                             @Param("keyword") String keyword);

    /**
     * 환전 이력 목록 조회 (페이징)
     * @param searchType 검색 타입
     * @param keyword    검색어
     * @param start      페이징 시작 번호
     * @param end        페이징 끝 번호
     */
    List<ExchangeHistoryDTO> selectExchangeHistory(@Param("searchType") String searchType,
                                                   @Param("keyword") String keyword,
                                                   @Param("start") int start,
                                                   @Param("end") int end);

    /**
     * 쿠폰 발급 현황 총 개수 조회
     */
    int countCouponIssues();

    /**
     * 쿠폰 발급 현황 조회 (페이징)
     *
     * 반환 DTO:
     *  - custCode   고객번호
     *  - couponNo   쿠폰번호
     *  - issuedDate 발급일자
     *  - coupRate   쿠폰 할인율
     *  - coupStatus 상태 (1: 미사용, 0: 사용)
     */
    List<CouponIssueDTO> selectCouponIssues(@Param("start") int start,
                                            @Param("end") int end);



    List<CurrencyDailyAmountDTO> selectDailyCurrencyAmountsByDate(@Param("date") String date);
    List<DailyExchangeAmountDTO> selectDailyTotalAmountsByDate(@Param("date") String date);

    List<CurrencyDailyAmountDTO> selectCurrencyAmountsByPeriod(@Param("startDate") String startDate,
                                                               @Param("endDate") String endDate);



}