package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.CustFrgnAcctDTO;
import kr.co.api.flobankapi.dto.FrgnRemtTranDTO;
import org.apache.ibatis.annotations.Mapper;

import java.math.BigDecimal;

@Mapper
public interface RemitMapper {
    void insertFrgnRemtTran(FrgnRemtTranDTO frgnRemtTranDTO);

    void updateMinusBal(BigDecimal amount, String acctNo);
    CustFrgnAcctDTO selectParAcctNo(String balNo);
}
