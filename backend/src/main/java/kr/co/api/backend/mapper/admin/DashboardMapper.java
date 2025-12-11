package kr.co.api.backend.mapper.admin;

import kr.co.api.flobankapi.dto.admin.dashboard.*;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface DashboardMapper {

    //오늘 거래금액 + 수
    TotalTxSummaryDTO selectTodayTotalTxSummary();
    List<DailyTxSummaryDTO> selectLast7DaysTotalTxSummary();

    // 오늘 거래 건수들
    int selectTodayFrgnRemtTxCount();   // 해외송금 테이블
    int selectTodayExChangeTxCount();   //ㅎㅈ


    // 가입수 통계
    List<JoinStatsDTO> selectDailyJoinStats();
    List<JoinStatsDTO> selectWeeklyJoinStats();
    List<JoinStatsDTO> selectMonthlyJoinStats();

    // 연령/성별 분포
    List<AgeStatDTO> selectAgeStats();
    List<GenderStatsDTO> selectgenderStats();




}
