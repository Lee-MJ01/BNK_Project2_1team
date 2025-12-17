package kr.co.api.backend.mapper;


import kr.co.api.backend.dto.ExchangeRateDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ExchangeRateMapper {
    ExchangeRateDTO selectExchangeRate(@Param("currency") String currency, @Param("searchDate") String searchDate);

}
