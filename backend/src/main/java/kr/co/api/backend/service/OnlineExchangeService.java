package kr.co.api.backend.service;

import kr.co.api.backend.dto.*;
import kr.co.api.backend.mapper.OnlineExchangeMapper;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OnlineExchangeService {


    private final OnlineExchangeMapper onlineExchangeMapper;







    /**
     * 온라인 환전 처리
     * (로그인 사용자 기준, 트랜잭션 보장)
     */
    @Transactional
    public void processOnlineExchange(FrgnExchOnlineDTO dto, String userId) {

        // 0. 로그인 userId → custCode 조회
        String custCode = onlineExchangeMapper.selectCustCodeByUserId(userId);

        if (custCode == null) {
            throw new IllegalStateException("고객 정보를 찾을 수 없습니다.");
        }

        // DTO에 고객 코드 세팅 (필수)
        dto.setExchCustCode(custCode);


        String custName = onlineExchangeMapper.selectCustNameByCustCode(custCode);

        if (custName == null) {
            throw new IllegalStateException("고객 이름을 조회할 수 없습니다.");
        }

        /* =========================
           1. 환율 조회
           ========================= */
        RateDTO rate = onlineExchangeMapper
                .selectLatestRate(dto.getExchToCurrency());

        if (rate == null) {
            throw new IllegalStateException("환율 정보를 조회할 수 없습니다.");
        }

        /* =========================
           2. 원화 계좌 잠금 조회
           ========================= */
        CustAcctDTO krwAcct =
                onlineExchangeMapper.selectKrwAcctForUpdate(
                        dto.getExchKrwAcctNo()
                );

        if (krwAcct == null) {
            throw new IllegalStateException("원화 계좌를 찾을 수 없습니다.");
        }

        /* =========================
           3. 외화 자식 계좌 잠금 조회
           ========================= */
        FrgnAcctBalanceDTO frgnBalance =
                onlineExchangeMapper.selectFrgnBalanceForUpdate(
                        dto.getExchFrgnBalNo()
                );

        if (frgnBalance == null) {
            throw new IllegalStateException("외화 계좌를 찾을 수 없습니다.");
        }

        /* =========================
           4. 환전 처리
           ========================= */
        if ("B".equals(dto.getExchType())) {
            // =====================
            // 외화 매수 (KRW → 외화)
            // =====================
            Long krwAmount = dto.getExchKrwAmount();
            Long currentKrwBalance = krwAcct.getAcctBalance();

            if (currentKrwBalance < krwAmount) {
                throw new IllegalStateException("원화 잔액이 부족합니다.");
            }

            double rateValue = rate.getRhistBaseRate();
            long foreignAmount = (long) (krwAmount / rateValue);

            // 원화 차감
            onlineExchangeMapper.updateKrwAcctBalance(
                    krwAcct.getAcctNo(),
                    currentKrwBalance - krwAmount
            );

            // 외화 증가
            onlineExchangeMapper.updateFrgnBalance(
                    frgnBalance.getBalNo(),
                    frgnBalance.getBalBalance() + foreignAmount
            );

            dto.setExchFrgnAmount(foreignAmount);
            dto.setExchAppliedRate(rateValue);

        } else if ("S".equals(dto.getExchType())) {
            // =====================
            // 외화 매도 (외화 → KRW)
            // =====================
            Long foreignAmount = dto.getExchFrgnAmount();
            Long currentForeignBalance = frgnBalance.getBalBalance();

            if (currentForeignBalance < foreignAmount) {
                throw new IllegalStateException("외화 잔액이 부족합니다.");
            }

            double rateValue = rate.getRhistBaseRate();
            long krwAmount = (long) (foreignAmount * rateValue);

            // 외화 차감
            onlineExchangeMapper.updateFrgnBalance(
                    frgnBalance.getBalNo(),
                    currentForeignBalance - foreignAmount
            );

            // 원화 증가
            onlineExchangeMapper.updateKrwAcctBalance(
                    krwAcct.getAcctNo(),
                    krwAcct.getAcctBalance() + krwAmount
            );

            dto.setExchKrwAmount(krwAmount);
            dto.setExchAppliedRate(rateValue);

        } else {
            throw new IllegalArgumentException("잘못된 환전 유형입니다.");
        }

        // =========================
        // 4-1. 계좌이체 이력 저장
        // =========================
        if ("B".equals(dto.getExchType())) {

            // 원화 출금
            onlineExchangeMapper.insertCustTranHist(
                    krwAcct.getAcctNo(),
                    custName,
                    2,
                    dto.getExchKrwAmount(),
                    dto.getExchFrgnAcctNo(),
                    "외화 환전 출금"
            );

            // 외화 입금
            onlineExchangeMapper.insertCustTranHist(
                    dto.getExchFrgnAcctNo(),
                    custName,
                    1,
                    dto.getExchFrgnAmount(),
                    krwAcct.getAcctNo(),
                    "외화 환전 입금"
            );

        } else if ("S".equals(dto.getExchType())) {

            // 외화 출금
            onlineExchangeMapper.insertCustTranHist(
                    dto.getExchFrgnAcctNo(),
                    custName,
                    2,
                    dto.getExchFrgnAmount(),
                    krwAcct.getAcctNo(),
                    "외화 환전 출금"
            );

            // 원화 입금
            onlineExchangeMapper.insertCustTranHist(
                    krwAcct.getAcctNo(),
                    custName,
                    1,
                    dto.getExchKrwAmount(),
                    dto.getExchFrgnAcctNo(),
                    "외화 환전 입금"
            );
        }



        /* =========================
           5. 환전 이력 저장
           ========================= */
        dto.setExchStatus(1);
        dto.setExchReqDt(LocalDate.now());

        onlineExchangeMapper.insertOnlineExchange(dto);
    }


    @Transactional(readOnly = true)
    public Map<String, Object> getMyExchangeAccounts(String userId, String currency) {

        String custCode = onlineExchangeMapper.selectCustCodeByUserId(userId);
        if (custCode == null) throw new IllegalStateException("고객 정보를 찾을 수 없습니다.");

        CustAcctDTO krwAcct = onlineExchangeMapper.selectMyKrwAccount(custCode);
        FrgnAcctDTO frgnAcct = onlineExchangeMapper.selectMyFrgnAccount(custCode);

        long krwBalance = (krwAcct != null && krwAcct.getAcctBalance() != null)
                ? krwAcct.getAcctBalance() : 0L;

        FrgnAcctBalanceDTO frgnBalDto = null;
        long frgnBalance = 0L;

        if (frgnAcct != null && frgnAcct.getFrgnAcctNo() != null) {
            frgnBalDto = onlineExchangeMapper.selectMyFrgnBalance(frgnAcct.getFrgnAcctNo(), currency);

            if (frgnBalDto != null && frgnBalDto.getBalBalance() != null) {
                frgnBalance = frgnBalDto.getBalBalance();
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("krwAcctNo", krwAcct != null ? krwAcct.getAcctNo() : null);
        result.put("krwBalance", krwBalance);

        result.put("frgnAcctNo", frgnAcct != null ? frgnAcct.getFrgnAcctNo() : null);
        result.put("frgnBalNo", frgnBalDto != null ? frgnBalDto.getBalNo() : null);
        result.put("frgnBalance", frgnBalance);
        result.put("currency", currency);

        return result;
    }




}
