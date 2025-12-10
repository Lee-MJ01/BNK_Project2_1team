package kr.co.api.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.api.flobankapi.dto.*;
import kr.co.api.flobankapi.jwt.CustomUserDetails;
import kr.co.api.flobankapi.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExchangeService {

    private final RateService rateService;
    private final ObjectMapper objectMapper; // JSON 파싱용 (Spring Boot 기본 내장)
    private final MypageMapper mypageMapper;
    private final ExchangeMapper exchangeMapper;
    private final PasswordEncoder passwordEncoder;
    private final CustAcctMapper  custAcctMapper;
    private final FrgnAcctMapper frgnAcctMapper;
    private final CouponMapper couponMapper;

    public BigDecimal calculateExchange(String date, String targetCurrency, BigDecimal krwAmount) {
        try {
            // 1. Redis 또는 API에서 환율 JSON 데이터 가져오기
            String jsonResponse = rateService.getRate(date);

            if (jsonResponse == null) {
                throw new RuntimeException("환율 데이터를 가져올 수 없습니다.");
            }

            // 2. JSON 문자열을 DTO 리스트로 변환
            List<RateInfoDTO> rateList = objectMapper.readValue(jsonResponse, new TypeReference<List<RateInfoDTO>>() {});

            // 3. 리스트에서 내가 원하는 통화(예: USD) 찾기
            RateInfoDTO targetRateInfo = rateList.stream()
                    .filter(rate -> rate.getCurUnit().equals(targetCurrency))
                    .findFirst()
                    .orElseThrow(() -> new IllegalArgumentException("해당 통화의 환율 정보를 찾을 수 없습니다: " + targetCurrency));

            // 4. 환율 문자열(예: "1,350.50")에서 쉼표 제거 후 숫자로 변환
            String rateStr = targetRateInfo.getDealBasR().replace(",", "");
            BigDecimal exchangeRate = new BigDecimal(rateStr);

            // 5. 환전 계산 (원화 금액 / 매매기준율)
            // 소수점 2자리까지 반올림 처리
            return krwAmount.divide(exchangeRate, 2, RoundingMode.HALF_UP);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("환전 계산 중 오류 발생: " + e.getMessage());
        }
    }

    // 고객 보유 전체 원화 계좌 확인
    public List<CustAcctDTO> getAllKoAcct(String custCode) {

        return mypageMapper.selectAllKoAcct(custCode);
    }

    // 고객 보유 전체 쿠폰 확인
    public List<CouponDTO> getCoupons(String custCode) {
        return exchangeMapper.selectAllCoupon(custCode);
    }

    // 환전 신청했을 때 환전 테이블 삽입, 계좌 잔액 업데이트, 계좌 이체 내역 테이블 삽입, 쿠폰 상태 업데이트
    @Transactional
    public void processExchange(FrgnExchTranDTO transDTO) {

        // 1. 환전 내역 INSERT
        exchangeMapper.insertExchange(transDTO);

        // 2. 사용자 이름
        String custName = getAuthenticatedUserName();

        // 3. 로직 분기
        if ("KRW".equals(transDTO.getExchFromCurrency())) {
            // [BUY] 원화 -> 외화

            // 원화 출금액 계산 (절사)
            BigDecimal withdrawKrw = transDTO.getExchAmount()
                    .multiply(transDTO.getExchAppliedRate())
                    .setScale(0, RoundingMode.FLOOR);

            // 원화 계좌 잔액 차감
            custAcctMapper.updateAcctBal(withdrawKrw, transDTO.getExchAcctNo());

            // 원화 계좌 거래내역 (출금)
            insertTransactionHistory(
                    transDTO.getExchAcctNo(),
                    custName,
                    "환전(" + transDTO.getExchToCurrency() + ")",
                    withdrawKrw,
                    2,      // 출금
                    "KRW",  // 통화
                    "",     // 상대계좌 (없음)
                    "888"   // 상대은행 (플로은행)
            );

        } else {
            // [SELL] 외화 -> 원화

            // RecAcctNo에 저장할 값
            String depositAcctNo = transDTO.getExchAddr().replace("즉시입금:", "").trim();

            // 외화 출금액
            BigDecimal withdrawForeign = transDTO.getExchAmount();

            // 원화 입금액 (절사)
            BigDecimal depositKrw = withdrawForeign
                    .multiply(transDTO.getExchAppliedRate())
                    .setScale(0, RoundingMode.FLOOR);

            // 외화 계좌 잔액 차감
            frgnAcctMapper.updateFrgnAcctBal(
                    withdrawForeign,
                    transDTO.getExchAcctNo(),
                    transDTO.getExchFromCurrency()
            );

            // 2. 외화 계좌 거래내역 (출금) 기록
            insertTransactionHistory(
                    transDTO.getExchAcctNo(),                   // 외화 계좌번호 (출금 주체)
                    custName,
                    "환전(" + transDTO.getExchFromCurrency() + "→KRW)",
                    withdrawForeign,                            // 외화 금액
                    2,                                          // 출금
                    transDTO.getExchFromCurrency(),             // 통화
                    depositAcctNo,                              // ★ 상대계좌 (입금받은 원화계좌)
                    "888"                                       // ★ 상대은행코드
            );

            // 원화 계좌 입금
            mypageMapper.updatePlusAcct(depositKrw, depositAcctNo);

            // 원화 계좌 거래내역 (입금) 기록
            // 여기서는 돈이 들어온 출처(외화계좌)를 상대계좌로 적어주면 좋습니다.
            insertTransactionHistory(
                    depositAcctNo,
                    custName,
                    "환전입금(" + transDTO.getExchFromCurrency() + ")",
                    depositKrw,
                    1,      // 입금
                    "KRW",  // 통화
                    transDTO.getExchAcctNo(), // 상대계좌 (돈이 나간 외화계좌)
                    "888"
            );
        }

        // 4. 쿠폰 사용 처리
        if (transDTO.getCouponNo() != null && transDTO.getCouponNo() > 0) {
            couponMapper.updateCouponStatus(transDTO.getCouponNo());
        }
    }

    // [Helper] 거래내역 기록 공통 메소드
    private void insertTransactionHistory(String acctNo, String custName, String summary, BigDecimal amount, int type, String currency, String recAcctNo, String recBkCode) {
        CustTranHistDTO histDTO = new CustTranHistDTO();
        histDTO.setTranAcctNo(acctNo);
        histDTO.setTranCustName(custName);
        histDTO.setTranRecName(summary);   // 적요
        histDTO.setTranType(type);         // 1:입금, 2:출금

        histDTO.setTranAmount(amount);     // 금액 (BigDecimal)
        histDTO.setTranCurrency(currency); // 통화 (KRW, USD...)

        // 잔액은 무시 (null로 들어감 -> DB에서 nullable이어야 함. 아니면 0으로 세팅)
        histDTO.setTranBalance(0);

        // 값 세팅
        histDTO.setTranRecAcctNo(recAcctNo != null ? recAcctNo : "");
        histDTO.setTranRecBkCode(recBkCode != null ? recBkCode : "888");

        // NULL 처리 (MyBatis jdbcType 필수)
        histDTO.setTranEsignYn("Y");

        mypageMapper.insertTranHist(histDTO);
    }

    // [Helper] 인증된 사용자 이름 가져오기
    private String getAuthenticatedUserName() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            return ((CustomUserDetails) authentication.getPrincipal()).getCustName();
        }
        return "Unknown";
    }

    // 환전하기 전 계좌 비밀번호 일치하는지 확인
    public boolean checkAccountPassword(String acctNo, String acctPass, String mode) {

        if("BUY".equals(mode)){ // 원화 -> 외화
            CustAcctDTO custAcctDTO = mypageMapper.selectCustAcct(acctNo);
            if (custAcctDTO == null) {
                return false;
            }
            return passwordEncoder.matches(acctPass, custAcctDTO.getAcctPw());
        }
        else{                  // 외화 -> 원화
            CustFrgnAcctDTO custFrgnAcctDTO = frgnAcctMapper.selectFrgnAcctByAcctNo(acctNo);
            if (custFrgnAcctDTO == null) {
                return false;
            }
            return passwordEncoder.matches(acctPass, custFrgnAcctDTO.getFrgnAcctPw());
        }
    }

}
