package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.CustAcctDTO;
import kr.co.api.flobankapi.dto.CustFrgnAcctDTO;
import kr.co.api.flobankapi.dto.FrgnRemtTranDTO;
import kr.co.api.flobankapi.mapper.MypageMapper;
import kr.co.api.flobankapi.mapper.RemitMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Slf4j
@RequiredArgsConstructor
@Service
public class RemitService {
    private final RemitMapper remitMapper;
    private final MypageMapper mypageMapper;
    private final FrgnAcctService frgnAcctService;
    private final PasswordEncoder passwordEncoder;

    // 외화 이체
    @Transactional
    public boolean saveFrgnTran(FrgnRemtTranDTO frgnRemtTranDTO){
        try {
            // 이체 내역 추가
            remitMapper.insertFrgnRemtTran(frgnRemtTranDTO);

            // 계좌 잔액 처리
            if(frgnRemtTranDTO.getRemtAcctNo().contains("-10-")){
                // [수정] 원화 계좌인 경우: (외화금액 * 환율) + 수수료(원화)

                // 1. 송금액(외화) * 환율 = 필요한 원화 원금 (원 단위 소수점 절사)
                BigDecimal krwPrincipal = frgnRemtTranDTO.getRemtAmount()
                        .multiply(frgnRemtTranDTO.getRemtAppliedRate())
                        .setScale(0, RoundingMode.FLOOR);

                // 2. 총 출금액 = 원화 원금 + 수수료(원화)
                BigDecimal totalDeductAmount = krwPrincipal.add(frgnRemtTranDTO.getRemtFee());

                // 3. 원화 계좌 차감
                // (Mapper가 BigDecimal을 처리하도록 되어있거나, 필요하다면 .intValue() 사용)
                mypageMapper.updateMinusAcct(totalDeductAmount, frgnRemtTranDTO.getRemtAcctNo());

            } else {
                // [수정] 외화 계좌인 경우: 외화금액 + 수수료(외화)
                // 소수점 계산이 필요하므로 setScale 없이 더하기만 수행
                BigDecimal totalDeductAmount = frgnRemtTranDTO.getRemtAmount()
                        .add(frgnRemtTranDTO.getRemtFee());

                // 외화 계좌 차감
                remitMapper.updateMinusBal(totalDeductAmount, frgnRemtTranDTO.getRemtAcctNo());
            }

        } catch (Exception e){
            e.printStackTrace();
            return false;
        }

        return true;
    }

    // 계좌 비밀번호 비교
    public boolean checkEnAcctPw(String acctNo, String acctPw, String acctType) {
        if ("KRW".equals(acctType)) {
            CustAcctDTO custAcctDTO = mypageMapper.selectCustAcct(acctNo);
            return passwordEncoder.matches(acctPw, custAcctDTO.getAcctPw());
        }else{
            CustFrgnAcctDTO custFrgnAcctDTO = frgnAcctService.getFrgnAcctByAcctNo(acctNo);
            log.info("계좌 비밀번호 custFrgnAcctDTO = {}",  custFrgnAcctDTO);
            return passwordEncoder.matches(acctPw, custFrgnAcctDTO.getFrgnAcctPw());
        }
    }

    // 모체 계좌번호 가져오기
    public CustFrgnAcctDTO getParAcctNo(String balNo) {
        return remitMapper.selectParAcctNo(balNo);
    }
}
