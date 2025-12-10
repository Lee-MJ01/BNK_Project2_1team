package kr.co.api.backend.mapper;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CouponMapper {
    void updateCouponStatus(Long couponNo);
}
