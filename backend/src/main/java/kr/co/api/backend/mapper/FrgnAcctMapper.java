package kr.co.api.backend.mapper;


import kr.co.api.backend.dto.CustFrgnAcctDTO;
import kr.co.api.backend.dto.CustTranHistDTO;
import kr.co.api.backend.dto.FrgnAcctBalanceDTO;
import org.apache.ibatis.annotations.Mapper;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface FrgnAcctMapper {
    // 고객 번호로 모체 외화 계좌 가져오기
    CustFrgnAcctDTO selectFrgnAcctByCustCode(String userCode);

    // 계좌번호로 모체 외화 계좌 가져오기
    CustFrgnAcctDTO selectFrgnAcctByAcctNo(String acctNo);

    // 자식 외화 계좌 리스트 가져오기
    List<FrgnAcctBalanceDTO> selectSubFrgnAcctAll(String acctNo);

    // 외화 자식 계좌 출금
    void updateFrgnAcctBal(BigDecimal amount, String acctNo, String currency);

    // 거래 내역
    void insertTranHist(CustTranHistDTO custTranHistDTO);

}
