package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.CouponDTO;
import kr.co.api.flobankapi.dto.FrgnExchTranDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ExchangeMapper {
    List<CouponDTO> selectAllCoupon(String custCode);

    // 환전 내역 삽입
    void insertExchange(FrgnExchTranDTO transDTO);

}
