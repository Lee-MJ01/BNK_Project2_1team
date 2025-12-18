package kr.co.api.backend.service;

import kr.co.api.backend.controller.MobileMemberController;
import kr.co.api.backend.dto.CustInfoDTO;
import kr.co.api.backend.mapper.MobileCustInfoMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MobileMemberService {
    final private MobileCustInfoMapper mobileCustInfo;

    public Boolean login(MobileMemberController.LoginRequest loginRequest){
        String deviceId = mobileCustInfo.selectDeviceIdByCustInfo(loginRequest.getUserid());

        if (loginRequest.getDeviceId().equals(deviceId)){
            return true;
        }

        return false;
    }

    public CustInfoDTO getCustInfoByCustId(String custId){
        return mobileCustInfo.selectUserIdByCustInfo(custId);
    }

    public void modifyCustInfoByDeviceId(String userId, String deviceId){
        mobileCustInfo.updateDeviceIdByCustInfo(deviceId, userId);
    }
}
