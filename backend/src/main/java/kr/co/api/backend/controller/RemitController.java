/*
 * 날짜 : 2025/11/20
 * 이름 : 김대현
 * 내용 : 디비 불러오기 수정
 * */

package kr.co.api.backend.controller;

import kr.co.api.backend.dto.CustAcctDTO;
import kr.co.api.backend.dto.CustFrgnAcctDTO;
import kr.co.api.backend.dto.FrgnAcctBalanceDTO;
import kr.co.api.backend.dto.FrgnRemtTranDTO;
import kr.co.api.backend.jwt.CustomUserDetails;
import kr.co.api.backend.service.MypageService;
import kr.co.api.backend.service.RemitService;
import kr.co.api.backend.service.TermsDbService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/remit")
@RequiredArgsConstructor
public class RemitController {
    private final MypageService mypageService;
    private final TermsDbService termsDbService;

    private final RemitService remitService;

    @GetMapping("/info")
    public String info(){
        return "remit/info";
    }

    @GetMapping("/en_transfer_1")
    public String en_transfer_1(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {

        int termLocation = 3; // 3번: 외화송금

        model.addAttribute("termsList",
                termsDbService.getTermsByLocation(termLocation)
        );


        return  "remit/en_transfer_1";
    }

    @GetMapping("/en_transfer_2")
    public String en_transfer_2(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        String userCode = userDetails.getUsername();
        List<CustAcctDTO> custAcctDTOList = mypageService.findAllAcct(userCode);
        CustFrgnAcctDTO custFrgnAcctDTO = mypageService.findFrgnAcct(userCode);

        List<FrgnAcctBalanceDTO> frgnAcctBalanceDTOList = mypageService.getAllFrgnAcctBal(custFrgnAcctDTO.getFrgnAcctNo());

        // 1. 자식 통장 잔액 전달 (통화 : 잔액)
        Map<String, Double> currencyAcctBal = new HashMap<>();
        // 2. 자식 통장 계좌번호 전달 (통화 : 자식계좌번호)
        Map<String, String> currencyAcctNo = new HashMap<>();

        for(FrgnAcctBalanceDTO dto : frgnAcctBalanceDTOList){
            // DTO의 balCurrency(통화)를 Key로 사용
            currencyAcctBal.put(dto.getBalCurrency(), dto.getBalBalance());

            // DTO의 balNo(자식 계좌번호)를 Value로 저장
            currencyAcctNo.put(dto.getBalCurrency(), dto.getBalNo());
        }

        model.addAttribute("currencyAcctBal", currencyAcctBal);
        model.addAttribute("currencyAcctNo", currencyAcctNo);

        // 외화 / 원화 계좌 리스트 보내기
        model.addAttribute("custFrgnAcctDTO", custFrgnAcctDTO);
        model.addAttribute("custAcctDTOList", custAcctDTOList);

        // 외화 이체 내역 테이블 전달(정보 이동용)
        FrgnRemtTranDTO frgnRemtTranDTO = new FrgnRemtTranDTO();
        model.addAttribute("frgnRemtTranDTO", frgnRemtTranDTO);
        return  "remit/en_transfer_2";
    }

    /**
     * 외화 계좌 비밀번호 검증 API
     * 요청 URL: /flobank/remit/checkEnAcctPw
     */
    @PostMapping("/checkEnAcctPw")
    @ResponseBody
    public ResponseEntity<Map<String, Boolean>> checkEnAcctPw(@RequestBody Map<String, String> requestData) {

        String acctNo = requestData.get("acctNo"); // 계좌번호
        String acctPw = requestData.get("acctPw"); // 사용자가 입력한 비밀번호
        String acctType = requestData.get("acctType"); // 계좌타입 (KRW / FRGN)

        // TODO: 서비스 로직 구현 (DB 조회 및 비밀번호 비교)
        boolean isCorrect = remitService.checkEnAcctPw(acctNo, acctPw, acctType);

        Map<String, Boolean> response = new HashMap<>();
        response.put("isPwCorrect", isCorrect);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/en_transfer_3")
    public String en_transfer_3(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        return  "remit/en_transfer_3";
    }

    @PostMapping("en_transfer_3")
    public String enTransfer3Post(@ModelAttribute FrgnRemtTranDTO frgnRemtTranDTO, Model model, @AuthenticationPrincipal CustomUserDetails userDetails) {
        if(frgnRemtTranDTO.getRemtCustName() == null){
            frgnRemtTranDTO.setRemtCustName(userDetails.getCustName());
        }

        frgnRemtTranDTO.setRemtEsignYn("Y");

        if (frgnRemtTranDTO.getRemtAcctNo().contains("-10-")) {
            CustFrgnAcctDTO krwAcct = new CustFrgnAcctDTO();
            krwAcct.setFrgnAcctNo(frgnRemtTranDTO.getRemtAcctNo());
            krwAcct.setFrgnAcctName("원화 입출금통장");
            model.addAttribute("custFrgnAcctDTO", krwAcct);
        } else {
            CustFrgnAcctDTO custFrgnAcctDTO = remitService.getParAcctNo(frgnRemtTranDTO.getRemtAcctNo());
            model.addAttribute("custFrgnAcctDTO", custFrgnAcctDTO);
        }

        if("Y".equals(frgnRemtTranDTO.getRemtEsignYn())){
            model.addAttribute("state", "정상");
        }else {
            model.addAttribute("state", "실패");
        }
        model.addAttribute("frgnRemtTranDTO", frgnRemtTranDTO);

        // 1. 송금 통화(Target Currency) 설정 (받는 돈 기준)
        String targetSymbol = "";
        String targetName = "";
        double defaultForeignFee = 0.0;

        switch (frgnRemtTranDTO.getRemtCurrency()) {
            case "USD": targetName = "(미국 달러)"; targetSymbol = "$"; defaultForeignFee = 3.34; break;
            case "JPY": targetName = "(일본 엔화)"; targetSymbol = "¥"; defaultForeignFee = 526.33; break;
            case "EUR": targetName = "(유럽 유로)"; targetSymbol = "€"; defaultForeignFee = 2.89; break;
            case "CNH": targetName = "(중국 위안화)"; targetSymbol = "¥"; defaultForeignFee = 23.72; break;
            case "GBP": targetName = "(영국 파운드)"; targetSymbol = "£"; defaultForeignFee = 2.55; break;
            case "AUD": targetName = "(호주 달러)"; targetSymbol = "$"; defaultForeignFee = 5.14; break;
            default: break;
        }

        // 송금 금액 표시는 항상 해당 외화 기준
        model.addAttribute("targetCurrencyName", targetName);
        model.addAttribute("targetCurrencySymbol", targetSymbol);

        // 2. 출금 계좌 타입에 따른 로직 분리 (원화 vs 외화)
        if(frgnRemtTranDTO.getRemtAcctNo().contains("-10-")){
            // [원화 계좌 출금]
            // 수수료 및 출금액은 '원화(₩)'로 표시
            frgnRemtTranDTO.setRemtFee(BigDecimal.valueOf(4900)); // 원화 고정 수수료

            // 예상 출금 금액 계산 (송금액 * 환율 + 수수료)
            // (주의: 화면에서 넘어온 remtAppliedRate가 있어야 정확한 계산 가능)
            BigDecimal withdrawAmount = frgnRemtTranDTO.getRemtAmount()
                    .multiply(frgnRemtTranDTO.getRemtAppliedRate())
                    .setScale(0, RoundingMode.FLOOR);

            BigDecimal totalAmount = withdrawAmount.add(frgnRemtTranDTO.getRemtFee());

            model.addAttribute("feeCurrencySymbol", "₩");
            model.addAttribute("withdrawalAmount", withdrawAmount);
            model.addAttribute("totalWithdrawalAmount", totalAmount);
            model.addAttribute("isKrwAccount", true);

        } else {
            // [외화 계좌 출금]
            // 수수료 및 출금액은 '해당 외화'로 표시

            frgnRemtTranDTO.setRemtFee(BigDecimal.valueOf(defaultForeignFee));
            BigDecimal totalAmount = frgnRemtTranDTO.getRemtAmount().add(frgnRemtTranDTO.getRemtFee());

            model.addAttribute("feeCurrencySymbol", targetSymbol);
            model.addAttribute("withdrawalAmount", frgnRemtTranDTO.getRemtAmount());
            model.addAttribute("totalWithdrawalAmount", totalAmount);
            model.addAttribute("isKrwAccount", false);
        }

        log.info("frgnRemtTranDTO = {}", frgnRemtTranDTO);

        return "remit/en_transfer_3";
    }

    @PostMapping("/en_transfer_4")
    public String en_transfer_4(@ModelAttribute FrgnRemtTranDTO frgnRemtTranDTO, Model model) {

        frgnRemtTranDTO.setRemtEsignYn("Y");
        boolean check = remitService.saveFrgnTran(frgnRemtTranDTO);

        if (frgnRemtTranDTO.getRemtAcctNo().contains("-10-")) {
            CustFrgnAcctDTO krwAcct = new CustFrgnAcctDTO();
            krwAcct.setFrgnAcctNo(frgnRemtTranDTO.getRemtAcctNo());
            krwAcct.setFrgnAcctName("원화 입출금통장");
            model.addAttribute("custFrgnAcctDTO", krwAcct);
        } else {
            CustFrgnAcctDTO custFrgnAcctDTO = remitService.getParAcctNo(frgnRemtTranDTO.getRemtAcctNo());
            model.addAttribute("custFrgnAcctDTO", custFrgnAcctDTO);
        }

        // 1. 송금 통화 정보 설정
        String targetSymbol = "";
        String targetName = "";
        switch (frgnRemtTranDTO.getRemtCurrency()) {
            case "USD": targetName = "(미국 달러)"; targetSymbol = "$"; break;
            case "JPY": targetName = "(일본 엔화)"; targetSymbol = "¥"; break;
            case "EUR": targetName = "(유럽 유로)"; targetSymbol = "€"; break;
            case "CNH": targetName = "(중국 위안화)"; targetSymbol = "¥"; break;
            case "GBP": targetName = "(영국 파운드)"; targetSymbol = "£"; break;
            case "AUD": targetName = "(호주 달러)"; targetSymbol = "$"; break;
        }
        model.addAttribute("targetCurrencyName", targetName);
        model.addAttribute("targetCurrencySymbol", targetSymbol);

        // 2. 출금/수수료 통화 정보 설정
        if(frgnRemtTranDTO.getRemtAcctNo().contains("-10-")){
            model.addAttribute("feeCurrencySymbol", "₩");
            model.addAttribute("isKrwAccount", true);
            // 원화 환산 출금액 (수수료 제외한 순수 환전금액)
            BigDecimal withdrawAmount = frgnRemtTranDTO.getRemtAmount()
                    .multiply(frgnRemtTranDTO.getRemtAppliedRate())
                    .setScale(0, RoundingMode.FLOOR);
            model.addAttribute("withdrawalAmount", withdrawAmount);
        } else {
            model.addAttribute("feeCurrencySymbol", targetSymbol);
            model.addAttribute("isKrwAccount", false);
            model.addAttribute("withdrawalAmount", frgnRemtTranDTO.getRemtAmount());
        }

        if(check){
            model.addAttribute("state", "정상");
        }else{
            model.addAttribute("state", "실패");
        }
        model.addAttribute("frgnRemtTranDTO", frgnRemtTranDTO);
        log.info("frgnRemtTranDTO = {}", frgnRemtTranDTO);
        return "remit/en_transfer_4";
    }
}
