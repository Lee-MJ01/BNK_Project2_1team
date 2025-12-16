package kr.co.api.backend.mapper;


import kr.co.api.backend.dto.ExchangeRiskDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface RiskMapper {
    List<ExchangeRiskDTO> selectByDate(String volStdDy);
}
