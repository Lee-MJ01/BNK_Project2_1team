package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.CustFrgnAcctDTO;
import kr.co.api.flobankapi.dto.FrgnAcctBalanceDTO;
import kr.co.api.flobankapi.mapper.FrgnAcctMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FrgnAcctService {
    private final FrgnAcctMapper frgnAcctMapper;

    // custCode로 모체 외환 계좌 찾기
    public CustFrgnAcctDTO getFrgnAcctByCode(String custCode){
        return frgnAcctMapper.selectFrgnAcctByCustCode(custCode);
    }

    // 계좌번호로 모체 외환 계좌 찾기
    public CustFrgnAcctDTO getFrgnAcctByAcctNo(String acctNo){
        return frgnAcctMapper.selectFrgnAcctByAcctNo(acctNo);
    }

    // 모체 외화 계좌번호로 자식 계좌 리스트 불러오기
    public List<FrgnAcctBalanceDTO> getSubFrgnAcctAll(String acctNo){
        return  frgnAcctMapper.selectSubFrgnAcctAll(acctNo);
    }
}
