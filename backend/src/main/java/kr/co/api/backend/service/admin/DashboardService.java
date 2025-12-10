package kr.co.api.backend.service.admin;

import jakarta.annotation.PostConstruct;
import kr.co.api.flobankapi.dto.admin.dashboard.*;
import kr.co.api.flobankapi.mapper.admin.DashboardMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {

    private final DashboardMapper dashboardMapper;

    private DashboardDTO cache;
    private LocalDateTime lastUpdatedAt;

    @PostConstruct
    public void init() {
        refreshStats();
    }

    @Scheduled(fixedRate = 5 * 60 * 1000) // 5분마다 r갱신
    public void refreshStats() {
        log.info("Refreshing dashboard stats...");


        // 1) 거래 건수
        TotalTxSummaryDTO total = dashboardMapper.selectTodayTotalTxSummary();
        int  todayTotalTxCount  = (total != null) ? total.getCount()  : 0;
        long todayTotalTxAmount = (total != null) ? total.getAmount() : 0L;

        List<DailyTxSummaryDTO> last7Days = dashboardMapper.selectLast7DaysTotalTxSummary();

        int remtCount = dashboardMapper.selectTodayFrgnRemtTxCount(); // 외화송금
        int exchCount = dashboardMapper.selectTodayExChangeTxCount(); // 환전

        List<TxCountDTO> todayFxTxCounts = List.of(
                TxCountDTO.builder().type("환전").count(exchCount).build(),
                TxCountDTO.builder().type("외화송금").count(remtCount).build()
        );

        // 2) 가입자 수
        List<JoinStatsDTO> dailyJoin   = dashboardMapper.selectDailyJoinStats();
        List<JoinStatsDTO> weeklyJoin  = dashboardMapper.selectWeeklyJoinStats();
        List<JoinStatsDTO> monthlyJoin = dashboardMapper.selectMonthlyJoinStats();

        log.info("=== monthlyJoin Stats ===");
        if (monthlyJoin == null) {
            log.info("monthlyJoin is null");
        } else {
            log.info("monthlyJoin size = {}", monthlyJoin.size());
            for (JoinStatsDTO s : monthlyJoin) {
                if (s == null) {
                    log.warn("monthlyJoin contains NULL row!!");
                    continue;
                }
                log.info("  baseDate = {}, joinCount = {}", s.getBaseDate(), s.getJoinCount());
            }
        }

        // 3) 연령/성별
        List<AgeStatDTO> ageStats   = dashboardMapper.selectAgeStats();
        List<GenderStatsDTO> genderStats = dashboardMapper.selectgenderStats();

        this.lastUpdatedAt = LocalDateTime.now();

        this.cache = DashboardDTO.builder()
                // 1번 그래프용
                .todayTotalTxCount(todayTotalTxCount)
                .todayTotalTxAmount(todayTotalTxAmount)
                .last7Days(last7Days)

                // 2번 그래프용
                .todayTxCounts(todayFxTxCounts)

                // 가입자 / 연령 / 성별
                .dailyJoinStats(dailyJoin)
                .weeklyJoinStats(weeklyJoin)
                .monthlyJoinStats(monthlyJoin)

                .ageStats(ageStats)

                .genderStats(genderStats)

                .lastUpdatedAt(this.lastUpdatedAt)
                .build();
    }

    public DashboardDTO getStats() {
        if (cache == null) {
            refreshStats();
        }
        return cache;
    }


}
