package kr.co.api.backend.dto.admin.dashboard;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardDTO {

    // 오늘 거래 건수 ( 원화)
    private int todayTotalTxCount;
    // 오늘 거래 금액 ( 원화 )
    private long todayTotalTxAmount;
    private List<DailyTxSummaryDTO> last7Days;


    // 오늘 거래 건수 ( 환전 / 외화송금 )
    private List<TxCountDTO> todayTxCounts;


    // 가입자 수 (일/주/월)
    private List<JoinStatsDTO> dailyJoinStats;
    private List<JoinStatsDTO> weeklyJoinStats;
    private List<JoinStatsDTO> monthlyJoinStats;

    // 연령/성별 분포
    private List<AgeStatDTO> ageStats;
    private List<GenderStatsDTO> genderStats;

    // 기준 시각 (5분 단위 갱신 시간)
    private LocalDateTime lastUpdatedAt;

}
