package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.RateDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;


@Mapper
public interface RateMapper {


     // 오늘 날짜 기준, 해당 통화 환율 저장 돼 있는지 확인

    int existsTodayRate(@Param("currency") String currency,
                        @Param("regDt") LocalDate regDt);

    // 환율 데이터 저장

    int insertRate(RateDTO rateDTO);


    // 통화별 최신 환율 1건 조회
    List<RateDTO> selectLatestRates();

    // 특정 통화 환율 히스토리 조회
    List<RateDTO> selectRateHistory(
            @Param("currency") String currency
    );

}
