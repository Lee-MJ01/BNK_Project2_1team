package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.CustInfoDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MobileCustInfoMapper {
    int countingDeviceId(String deviceId);
    String selectDeviceIdByCustInfo(String deviceId);
    void updateDeviceIdByCustInfo(String deviceId, String custId);
    CustInfoDTO selectUserIdByCustInfo(String custId);
    void updateCustInfoByPIN(String custId, String custPin);
    void updateCustInfoByBIO(String custId, String bioAuthYn);
}
