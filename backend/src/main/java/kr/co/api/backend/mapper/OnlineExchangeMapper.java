package kr.co.api.backend.mapper;
import kr.co.api.backend.dto.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OnlineExchangeMapper {

    String selectCustNameByCustCode(@Param("custCode") String custCode);


    // OnlineExchangeMapper.java
    String selectCustCodeByUserId(@Param("custId") String custId);

    int insertCustTranHist(
            @Param("acctNo") String acctNo,
            @Param("custName") String custName,
            @Param("tranType") int tranType,   // 1:입금, 2:출금
            @Param("amount") Long amount,
            @Param("recAcctNo") String recAcctNo,
            @Param("memo") String memo
    );


    /* =========================
       1. 환율 조회
       ========================= */
    RateDTO selectLatestRate(@Param("currency") String currency);


    /* =========================
       2. 원화 계좌 조회 (FOR UPDATE)
       ========================= */
    CustAcctDTO selectKrwAcctForUpdate(@Param("custCode") String custCode);


    /* =========================
       3. 외화 자식 계좌 조회 (FOR UPDATE)
       ========================= */
    FrgnAcctBalanceDTO selectFrgnBalanceForUpdate(
            @Param("balNo") String balNo
    );


    /* =========================
       4. 원화 계좌 잔액 UPDATE
       ========================= */
    int updateKrwAcctBalance(
            @Param("acctNo") String acctNo,
            @Param("balance") Long balance
    );


    /* =========================
       5. 외화 자식 계좌 잔액 UPDATE
       ========================= */
    int updateFrgnBalance(
            @Param("balNo") String balNo,
            @Param("balance") Long balance
    );


    /* =========================
       6. 온라인 환전 INSERT
       ========================= */
    int insertOnlineExchange(FrgnExchOnlineDTO dto);


    // 내 원화 계좌
    CustAcctDTO selectMyKrwAccount(@Param("custCode") String custCode);

    // 내 외화 모계좌
    FrgnAcctDTO selectMyFrgnAccount(@Param("custCode") String custCode);

    // 통화별 외화 자식 계좌
    FrgnAcctBalanceDTO selectMyFrgnBalance(
            @Param("frgnAcctNo") String frgnAcctNo,
            @Param("currency") String currency
    );




}


