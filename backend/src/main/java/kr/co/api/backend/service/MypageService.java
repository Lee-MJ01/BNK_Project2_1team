package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.*;
import kr.co.api.flobankapi.mapper.DepositMapper;
import kr.co.api.flobankapi.mapper.ExtAcctMapper;
import kr.co.api.flobankapi.mapper.MemberMapper;
import kr.co.api.flobankapi.mapper.MypageMapper;
import kr.co.api.flobankapi.util.AesUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MypageService {
    private final MemberMapper memberMapper;
    private final MypageMapper mypageMapper;
    private final PasswordEncoder passwordEncoder;
    private final ExtAcctMapper extAcctMapper;

    public void saveAcct(CustAcctDTO custAcctDTO) { // 계좌 생성
        // 계좌 비밀번호 암호화 => 단방향
        String endPw = passwordEncoder.encode(custAcctDTO.getAcctPw());
        custAcctDTO.setAcctPw(endPw);

        // 이미 있는 입출금통장 개수 들고오기
        int cnt = findCntAcct(custAcctDTO.getAcctCustCode());

        // 기본 이름 설정("FLO 입출금통장 + (n+1)")
        custAcctDTO.setAcctName("FLO 입출금통장" + (cnt + 1));

        mypageMapper.insertAcct(custAcctDTO);
    }

    // 외화 입출금계좌 생성
    @Transactional
    public void saveFrgnAcct(CustFrgnAcctDTO custFrgnAcctDTO) {

        // 계좌 비밀번호 암호화 = > 단방향
        String endPw = passwordEncoder.encode(custFrgnAcctDTO.getFrgnAcctPw());
        custFrgnAcctDTO.setFrgnAcctPw(endPw);

        // 기본 외화 통장 이름 설정
        String name = "FLO 외화통장";
        custFrgnAcctDTO.setFrgnAcctName(name);

        mypageMapper.insertFrgnAcct(custFrgnAcctDTO);

        // 생성된 외화 부모 계좌 들고오기
        CustFrgnAcctDTO frgnAcctDTO = mypageMapper.selectFrgnAcct(custFrgnAcctDTO.getFrgnAcctCustCode());
        // 자식 통장 만들기
        String[] currency = {"USD", "JPY", "EUR", "CNH", "GBP", "AUD"};
        List<FrgnAcctBalanceDTO> frgnAcctBalanceList = new ArrayList<>();
        for(String c : currency){
            FrgnAcctBalanceDTO frgnAcctBalance = new FrgnAcctBalanceDTO();
            frgnAcctBalance.setBalCurrency(c);
            frgnAcctBalance.setBalFrgnAcctNo(frgnAcctDTO.getFrgnAcctNo());

            frgnAcctBalanceList.add(frgnAcctBalance);
        }
        mypageMapper.insertAllFrgnAcctBal(frgnAcctBalanceList);

    }

    // 외화 입출금 통장 이미 있는지 확인
    public int checkEnAcct(String custCode) {
        return mypageMapper.selectCheckCntEnAcct(custCode);
    }

    // 고객 보유 전체 계좌 확인
    public List<CustAcctDTO> findAllAcct(String custCode) {
        return mypageMapper.selectAllKoAcct(custCode);
    }

    // 고객 외환 계좌 확인
    public CustFrgnAcctDTO findFrgnAcct(String custCode) {
        return mypageMapper.selectFrgnAcct(custCode);
    }

    // 원화 계좌 이름 바꾸기
    public void modifyAcctName(String name, String acctNo) {
        mypageMapper.updateAcctName(name, acctNo);
    }

    // 외화 계좌 이름 바꾸기
    public void modifyFrgnAcctName(String name, String acctNo) {
        mypageMapper.updateFrgnAcctName(name, acctNo);
    }

    // 원화 계좌 단건 조회
    public CustAcctDTO findCustAcct(String acctNo) {
        return mypageMapper.selectCustAcct(acctNo);
    }

    // 원화 입출금 계좌 개수 확인
    public Integer findCntAcct(String custCode) {
        return  mypageMapper.selectCntAcct(custCode);
    }

    // 국내 외부 은행에 존재하는 계좌번호인지 조회 및 정보 들고오기
    public ExtAcctDTO findExtAcct(String acctNo, String bkCode) {
        return extAcctMapper.selectExtAcct(acctNo, bkCode);
    }

    // 원화 -> 원환 입금, 출금
    @Transactional
    public void processCustAcctBal(CustTranHistDTO custTranHistDTO){
        BigDecimal amount = custTranHistDTO.getTranAmount();
        String acctNo = custTranHistDTO.getTranAcctNo();
        // 출금 실행
        mypageMapper.updateMinusAcct(amount, acctNo);

        // 원화 -> 원화이기에 고정 KRW
        custTranHistDTO.setTranCurrency("KRW");

        // 출금을 플로뱅크로 했다면 입금 로직 실행
        if("888".equals(custTranHistDTO.getTranRecBkCode())){
            String recAcctNo = custTranHistDTO.getTranRecAcctNo();
            // 입급 실행
            mypageMapper.updatePlusAcct(amount, recAcctNo);

            // 출금 이체 내역 삽입
            mypageMapper.insertTranHist(custTranHistDTO);

            // 입금 이체 내역 삽입
            CustTranHistDTO tranHist =  new CustTranHistDTO();
            tranHist.setTranAcctNo(custTranHistDTO.getTranRecAcctNo());
            tranHist.setTranAmount(amount);
            tranHist.setTranType(1);
            tranHist.setTranRecAcctNo(acctNo);
            tranHist.setTranRecName(custTranHistDTO.getTranCustName());
            tranHist.setTranRecBkCode("888");
            tranHist.setTranCurrency("KRW");
            tranHist.setTranEsignYn(custTranHistDTO.getTranEsignYn());
            tranHist.setTranCustName(custTranHistDTO.getTranRecName());

            mypageMapper.insertTranHist(tranHist);

        }else{
            // 출금 이체 내역 삽입
            mypageMapper.insertTranHist(custTranHistDTO);
        }



    }

    // 외화 자식 계좌 조회
    public List<FrgnAcctBalanceDTO> getAllFrgnAcctBal(String frgnAcctNo) {
        return mypageMapper.selectAllFrgnAcctBal(frgnAcctNo);
    }

    public CustInfoDTO getCustInfo(String userCode) {
        // 1. DB에서 고객 정보 조회 (MypageMapper 하나만 사용)
        CustInfoDTO custInfo = mypageMapper.selectCustInfoByCode(userCode);

        if (custInfo == null) {
            return null;
        }

        // 2. 이메일 복호화 시도
        if (custInfo.getCustEmail() != null) {
            try {
                String decryptedEmail = AesUtil.decrypt(custInfo.getCustEmail());
                custInfo.setCustEmail(decryptedEmail);
            } catch (Exception e) {
                // 복호화 실패 시(암호화 안 된 평문일 경우 등) 로그만 남기고 원래 값 유지
            }
        }

        // 3. 휴대폰 번호 복호화 시도
        if (custInfo.getCustHp() != null) {
            try {
                String decryptedHp = AesUtil.decrypt(custInfo.getCustHp());
                custInfo.setCustHp(decryptedHp); // 복호화 성공 시 덮어쓰기
            } catch (Exception e) {
                // 복호화 실패 시 원래 값 유지
            }
        }



        return custInfo;
    }

    public boolean checkKoAcct(String custCode) {

        LocalDate latestRegDt = mypageMapper.selectCheckKoAcct(custCode);

        // 1. 개설 이력이 없으면 -> 즉시 개설 가능
        if (latestRegDt == null) {
            return true;
        }

        // 2. 개설 이력이 있으면 -> 1개월(30일)이 지났는지 확인
        LocalDate today = LocalDate.now();
        long daysPassed = ChronoUnit.DAYS.between(latestRegDt, today);

        // 30일(1개월) 미만이면 false(개설 불가), 이상이면 true(개설 가능)
        return daysPassed >= 30;
    }

    public int checkCntKoAcct(String custCode) {
        return mypageMapper.selectCheckCntKoAcct(custCode);
    }


    // 비밀번호 검증
    public boolean checkPassword(String userCode, String rawPassword) {
        // 1. DB에서 고객 정보 조회
        CustInfoDTO custInfo = mypageMapper.selectCustInfoByCode(userCode);

        if (custInfo == null) {
            return false;
        }

        String dbPw = custInfo.getCustPw();

        // [디버깅용 로그] 콘솔에서 이 값이 어떻게 찍히는지 꼭 확인해보세요!

        // 2. 암호화된 비밀번호 비교 (정석 방법)
        if (passwordEncoder.matches(rawPassword, dbPw)) {

            return true;
        }

        // 3. [테스트용] 혹시 DB에 그냥 생으로(평문) 저장되어 있나요? 그럼 이걸로 통과!
        if (rawPassword.equals(dbPw)) {
            return true;
        }
        return false;
    }


    // 회원 정보 수정
    public void modifyUserInfo(String userCode, Map<String, String> data) {

        // 1. 업데이트할 정보를 담을 DTO 생성
        CustInfoDTO updateDto = new CustInfoDTO();
        updateDto.setCustCode(userCode); // 누구를 업데이트할지 식별

        updateDto.setCustEmail(data.get("email"));
        updateDto.setCustHp(data.get("hp"));
        updateDto.setCustZip(data.get("zipcode"));
        updateDto.setCustAddr1(data.get("addr1"));
        updateDto.setCustAddr2(data.get("addr2"));

        // 2. 비밀번호 변경 요청이 있는 경우 (값이 존재하면)
        String newPw = data.get("newPassword");
        if (newPw != null && !newPw.trim().isEmpty()) {
            // 암호화 수행
            String encodedPw = passwordEncoder.encode(newPw);
            updateDto.setCustPw(encodedPw);
        }

        // 3. DB 업데이트 실행
        mypageMapper.updateCustInfo(updateDto);
    }


    // 계좌 거래내역 조회 (현재 잔액 기준으로 과거 잔액 역산)
    public Map<String, Object> getAcctDetailWithHistory(String acctNo) {

        Map<String, Object> result = new HashMap<>();

        CustAcctDTO account = mypageMapper.selectCustAcct(acctNo);
        List<CustTranHistDTO> historyList = mypageMapper.selectTranHist(acctNo);

        Integer calculatorBalance = account.getAcctBalance();

        for (CustTranHistDTO hist : historyList) {

            // --------------------------
            // 1) 환전 거래 처리 (REC_ACCT_NO = NULL)
            // --------------------------
            if (hist.getTranRecAcctNo() == null) {

                hist.setTranType(3);              // 환전
                hist.setTranRecName("환전");

                if (hist.getTranMemo() == null) {
                    hist.setTranMemo("환전 거래");
                }

                // 잔액 변화 없음
                hist.setTranBalance(calculatorBalance);

                continue;
            }

            // --------------------------
            // 2) 금액(BigDecimal) → int 변환
            // --------------------------
            BigDecimal amtBD = hist.getTranAmount();
            int amount = (amtBD != null) ? amtBD.intValue() : 0;

            // --------------------------
            // 3) 타입 null-safe
            // --------------------------
            Integer type = hist.getTranType();

            // 현재 시점의 잔액 기록
            hist.setTranBalance(calculatorBalance);

            // --------------------------
            // 4) 잔액 역산
            // --------------------------
            if (type != null && type == 1) {          // 입금
                calculatorBalance -= amount;
            }
            else if (type != null && type == 2) {     // 출금
                calculatorBalance += amount;
            }
        }

        result.put("account", account);
        result.put("history", historyList);

        return result;
    }






    // 이체 전 계좌 비밀번호 확인
    public boolean checkAcctPw(String acctNo, String inputPw) {
        // 계좌번호로 계좌 정보 들고오기
        CustAcctDTO custAcctDTO = findCustAcct(acctNo);

        // 계좌 비밀번호 일치하는지 확인
        return passwordEncoder.matches(inputPw, custAcctDTO.getAcctPw());

    }

    public List<CouponDTO> getCouponList(String custCode) {
        return mypageMapper.selectCouponList(custCode);
    }


    public List<MypageDpstDTO> getDpstAcctHdrList(String dpstHdrCustCode) {
        return mypageMapper.selectDpstAccts(dpstHdrCustCode);
    }

    public List<DpstAcctDtlDTO> getDpstAcctHistList(String dpstHdrCustCode) {
        return mypageMapper.selectDpstAcctDtls(dpstHdrCustCode);
    }

    public DpstAcctHdrDTO getDpstAcctHdr(String dpstHdrAcctNo) {
        return mypageMapper.selectDpstAcctHdr(dpstHdrAcctNo);
    }

    public Double getKrwAcctBal(String dpstHdrAcctNo) {
        return mypageMapper.selectAcctBal(dpstHdrAcctNo);
    }

    public FrgnAcctBalanceDTO getFrgnAcctBal(String dpstHdrAcctNo) {
        return mypageMapper.selectFrgnAcctBal(dpstHdrAcctNo);
    }

    public DpstAcctHdrDTO getDpstAcctHdrAndBal(String dpstHdrAcctNo, String dpstHdrCurrency) {
        if ("KRW".equals(dpstHdrCurrency)){
            return mypageMapper.selectDpstKrwAcctHdr(dpstHdrAcctNo);
        }else {
            return mypageMapper.selectDpstFrgnAcctHdr(dpstHdrAcctNo, dpstHdrCurrency);
        }
    }
    private final DepositMapper depositMapper;
    public FrgnAcctBalanceDTO getBalAcctByBalNo(String balNo){
        FrgnAcctBalanceDTO dto = depositMapper.selectFrgnAcctBalance(balNo);
        dto.setBalNo(balNo);
        return dto;
    }

    public void addPayFrgnToFrgn(FrgnAcctBalanceDTO balAcct,
                                 DpstAcctHdrDTO dpstAcctHdrDTO,
                                 CustTranHistDTO custTranHistDTO,
                                 DpstAcctDtlDTO dpstDtlDTO){
        // 외화계좌 잔액 변화
        balAcct.setBalBalance(balAcct.getBalBalance() - custTranHistDTO.getTranAmount().doubleValue());
        // 예금계좌 추납카운트, 잔액 변화
        dpstAcctHdrDTO.setDpstHdrAddPayCnt(dpstAcctHdrDTO.getDpstHdrAddPayCnt() + 1);
        dpstAcctHdrDTO.setDpstHdrBalance(dpstAcctHdrDTO.getDpstHdrBalance().add(custTranHistDTO.getDpstDtlAmount()));
        // 예금계좌 거래내역
        dpstDtlDTO.setDpstDtlType(1);
        dpstDtlDTO.setDpstDtlAmount(custTranHistDTO.getDpstDtlAmount());
        dpstDtlDTO.setDpstDtlHdrNo(dpstAcctHdrDTO.getDpstHdrAcctNo());

        // 전자서명 임의로 y로 세팅
        dpstDtlDTO.setDpstDtlEsignYn("Y");
        dpstDtlDTO.setDpstDtlAppliedRate(BigDecimal.valueOf(0));

        mypageMapper.insertDpstCustTranHist(custTranHistDTO);
        mypageMapper.insertDpstAcctDtl(dpstDtlDTO);
        mypageMapper.updateDpstAcctHdr(dpstAcctHdrDTO);
        mypageMapper.updateFrgnAcctBal(balAcct);
    }

    public void addPayKrwToFrgn(CustAcctDTO custAcct,
                                 DpstAcctHdrDTO dpstAcctHdrDTO,
                                 CustTranHistDTO custTranHistDTO,
                                 DpstAcctDtlDTO dpstDtlDTO){
        // 원화계좌 잔액 변화
        custAcct.setAcctBalance(custAcct.getAcctBalance() - custTranHistDTO.getTranAmount().intValue());
        // 예금계좌 추납카운트, 잔액 변화
        dpstAcctHdrDTO.setDpstHdrAddPayCnt(dpstAcctHdrDTO.getDpstHdrAddPayCnt() + 1);
        dpstAcctHdrDTO.setDpstHdrBalance(dpstAcctHdrDTO.getDpstHdrBalance().add(custTranHistDTO.getDpstDtlAmount()));
        // 예금계좌 거래내역
        dpstDtlDTO.setDpstDtlType(1);
        dpstDtlDTO.setDpstDtlAmount(custTranHistDTO.getDpstDtlAmount());
        dpstDtlDTO.setDpstDtlHdrNo(dpstAcctHdrDTO.getDpstHdrAcctNo());

        // 전자서명 임의로 y로 세팅
        dpstDtlDTO.setDpstDtlEsignYn("Y");
        dpstDtlDTO.setDpstDtlAppliedRate(BigDecimal.valueOf(0));
        custTranHistDTO.setTranEsignYn("Y");

        mypageMapper.insertDpstCustTranHist(custTranHistDTO);
        mypageMapper.insertDpstAcctDtl(dpstDtlDTO);
        mypageMapper.updateDpstAcctHdr(dpstAcctHdrDTO);
        mypageMapper.updateKrwAcctBal(custAcct);
    }

    public BigDecimal calculateCompoundInterest(
            DpstAcctHdrDTO dpstAcct, List<DpstAcctDtlDTO> histList) {

        LocalDate startDate = LocalDate.parse(dpstAcct.getDpstHdrStartDy(), DateTimeFormatter.ofPattern("yyyyMMdd"));
        LocalDate finDate = LocalDate.parse(dpstAcct.getDpstHdrFinDy(), DateTimeFormatter.ofPattern("yyyyMMdd"));
        LocalDate cancelDate = LocalDate.now();

        long contractDays = ChronoUnit.DAYS.between(startDate, finDate);
        long passedDays = ChronoUnit.DAYS.between(startDate, cancelDate);

        BigDecimal baseRate = dpstAcct.getDpstHdrInterest();
        BigDecimal finalRate;

        boolean isMaturity = !cancelDate.isBefore(finDate);

        if (isMaturity) {
            finalRate = baseRate; // 만기 → 기본금리
        } else {
            finalRate = calculateEarlyTerminationRate(baseRate, passedDays, contractDays); // 중도 → 감액금리
        }

        BigDecimal totalInterest = BigDecimal.ZERO;
        BigDecimal hundred = new BigDecimal("100");

        for (DpstAcctDtlDTO h : histList) {
            LocalDate depositDate = LocalDate.from(h.getDpstTranDt());
            long days = ChronoUnit.DAYS.between(depositDate, cancelDate);

            if (days <= 0) continue; // 해지일 이후 입금제외

            BigDecimal principal = new BigDecimal(String.valueOf(h.getDpstDtlAmount()));
            log.info("principal: " + principal);
            BigDecimal multiplier = BigDecimal.ONE
                    .add(finalRate.divide(hundred, 10, RoundingMode.HALF_UP)
                            .divide(BigDecimal.valueOf(365), 10, RoundingMode.HALF_UP))  // 하루 이율로 변환
                    .pow((int) days)
                    .subtract(BigDecimal.ONE);
            log.info("multiplier: " + multiplier);

            BigDecimal interest = principal.multiply(multiplier);
            log.info("interest: " + interest);
            totalInterest = totalInterest.add(interest);
            log.info("totalInterest: " + totalInterest);
        }

        return totalInterest.setScale(2, RoundingMode.HALF_UP); // 재귀 호출 X
    }


    public BigDecimal calculateEarlyTerminationRate(BigDecimal baseRate, long passedDays, long contractDays) {
        BigDecimal passedRatio = BigDecimal.valueOf(passedDays)
                .divide(BigDecimal.valueOf(contractDays), 10, RoundingMode.HALF_UP); // 경과율

        BigDecimal rateFactor;
        BigDecimal minRate;

        if (passedRatio.compareTo(new BigDecimal("0.10")) < 0) {
            rateFactor = new BigDecimal("0.10");
            minRate = new BigDecimal("0.0010"); // 연 0.10%
        } else if (passedRatio.compareTo(new BigDecimal("0.30")) < 0) {
            rateFactor = new BigDecimal("0.30");
            minRate = new BigDecimal("0.0030");
        } else if (passedRatio.compareTo(new BigDecimal("0.80")) < 0) {
            rateFactor = new BigDecimal("0.50");
            minRate = new BigDecimal("0.0050");
        } else {
            rateFactor = new BigDecimal("0.90");
            minRate = new BigDecimal("0.0050");
        }

        BigDecimal midRate = baseRate
                .divide(new BigDecimal("100"), 10, RoundingMode.HALF_UP) // % 변환
                .multiply(rateFactor)
                .multiply(passedRatio)                                   // 경과율 반영
                .setScale(10, RoundingMode.HALF_UP);

        if (midRate.compareTo(minRate) < 0) {
            midRate = minRate;
        }

        return midRate; // 연이율 반환
    }

    public List<DpstAcctDtlDTO> getDpstDtlHistList(String dpstDtlHdrNo) {
        return mypageMapper.selectDpstAcctDtlHist(dpstDtlHdrNo);
    }

    public CustInfoDTO getRawCustInfo(String custCode){
        return mypageMapper.getRawCustInfo(custCode);
    }

    public FrgnAcctBalanceDTO getBalBalanceByAcctHdrNo(String dpstHdrAcctNo) {
        return mypageMapper.getBalBalanceByAcctHdrNo(dpstHdrAcctNo);
    }

    public void updateBalBalance(FrgnAcctBalanceDTO balDTO) {
        mypageMapper.updateBalBalance(balDTO);
    }

    public void updateHdrStatus(DpstAcctHdrDTO dpstAcct){
        mypageMapper.updateHdrStatus(dpstAcct);
    }

}



