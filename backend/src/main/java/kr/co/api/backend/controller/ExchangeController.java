/*
* 날짜 : 2025/11/20
* 이름 : 김대현
* 내용 : 디비 불러오기 수정
* */


package kr.co.api.backend.controller;

import kr.co.api.backend.dto.*;
import kr.co.api.backend.service.ExchangeService;
import kr.co.api.backend.service.FrgnAcctService;
import kr.co.api.backend.service.RateService;
import kr.co.api.backend.service.TermsDbService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/exchange")
@RequiredArgsConstructor
public class ExchangeController {

    private final ExchangeService exchangeService;
    private final TermsDbService termsDbService;
    private final RateService rateService;
    private final FrgnAcctService frgnAcctService;


    // 환전하기
    @ResponseBody
    @GetMapping("/calculate")
    public BigDecimal calculateExchange(@RequestParam String date,
                                        @RequestParam String currency,
                                        @RequestParam BigDecimal amount) {
        // 예: 20231025 날짜의 USD 환율로 1,000,000원을 환전
        return exchangeService.calculateExchange(date, currency, amount);
    }

    @GetMapping("/benefit")
    public String benefit(Model model){
        model.addAttribute("activeItem","benefit");
        return "exchange/benefit";
    }

    @GetMapping("/info1")
    public String info1(Model model){
        model.addAttribute("activeItem","info1");
        return "exchange/info1";
    }

    @GetMapping("/info2")
    public String info2(Model model){
        model.addAttribute("activeItem","info2");
        return "exchange/info2";
    }

    @GetMapping("/info3")
    public String info3(Model model){
        model.addAttribute("activeItem","info3");
        return "exchange/info3";
    }

    @GetMapping("/api/rate")
    @ResponseBody
    public ResponseEntity<?> getCurrentRate(@RequestParam String currency) {
        Map<String, Object> response = new HashMap<>();

        try {
            // ✅ RateService를 통해 Redis에 있는 데이터를 뒤져서 환율을 가져옴
            Map<String, Double> rateData = rateService.getCurrencyRate(currency);

            if (rateData == null) {
                response.put("status", "error");
                response.put("message", "현재 환율 정보를 불러올 수 없습니다. (휴일이거나 데이터 없음)");
                // 실제 서비스에선 '최근 영업일' 데이터를 가져오는 로직을 Service에 추가해야 함
            } else {
                response.put("status", "success");
                response.put("currency", currency);

                // Service에서 가져온 데이터를 응답에 담음
                response.put("rate", rateData.get("rate")); // 매매기준율
                response.put("tts", rateData.get("tts"));   // 전신환매도율 (보내실 때)
                response.put("ttb", rateData.get("ttb"));   // 전신환매입율 (받으실 때) 추가
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("환율 조회 API 에러", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    //환전하기 약관 불러오기
    @GetMapping("/step1")
    public String step1(Model model){
        int termLocation = 2; // 2번: 환전하기

        model.addAttribute("termsList",
                termsDbService.getTermsByLocation(termLocation)
        );

        return "exchange/step1";
    }

    // 계좌비밀번호 일치하는지 비교
    @ResponseBody
    @PostMapping("/passcheck")
    public ResponseEntity<?> checkPassword(@RequestBody Map<String, String> request) {
        String acctNo = request.get("acctNo");
        String acctPw = request.get("acctPw");
        String mode = request.get("mode");

        Map<String, Object> response = new HashMap<>();

        try {
            // 서비스에서 비밀번호 검증 수행
            boolean isValid = exchangeService.checkAccountPassword(acctNo, acctPw, mode);

            if (isValid) {
                response.put("status", "success");
            } else {
                response.put("status", "fail");
                response.put("message", "계좌 비밀번호가 일치하지 않습니다.");
            }
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("비밀번호 확인 중 오류", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/step2")
    public String step2(@AuthenticationPrincipal UserDetails user, Model model){
        String userCode = user.getUsername();

        // 계좌 리스트
        List<CustAcctDTO> custAcctDTOList = exchangeService.getAllKoAcct(userCode);
        model.addAttribute("custAcctDTOList",custAcctDTOList);

        // 외화 계좌
        CustFrgnAcctDTO custFrgnAcctDTO = frgnAcctService.getFrgnAcctByCode(userCode);
        model.addAttribute("custFrgnAcctDTO",custFrgnAcctDTO);

        // 자식 외화 계좌 리스트
        List<FrgnAcctBalanceDTO> frgnAcctBalanceDTOList = frgnAcctService.getSubFrgnAcctAll(custFrgnAcctDTO.getFrgnAcctNo());
        model.addAttribute("frgnAcctBalanceDTOList",frgnAcctBalanceDTOList);

        // 쿠폰 리스트
        List<CouponDTO> couponDTOList = exchangeService.getCoupons(userCode);
        model.addAttribute("couponDTOList",couponDTOList);

        return "exchange/step2";
    }

    // [API] 환전 신청 처리 (최종 DB 저장)
    @ResponseBody
    @PostMapping("/process")
    public ResponseEntity<?> processExchange(@RequestBody Map<String, Object> reqData) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 1. DTO 객체 생성 및 매핑
            FrgnExchTranDTO transDTO = new FrgnExchTranDTO();

            // 2. 공통 데이터 세팅
            transDTO.setExchAcctNo((String) reqData.get("exchAcctNo"));
            transDTO.setExchAmount(new BigDecimal(String.valueOf(reqData.get("exchAmount"))));
            transDTO.setExchAppliedRate(new BigDecimal(String.valueOf(reqData.get("exchAppliedRate"))));
            if (reqData.get("exchFee") != null) {
                transDTO.setExchFee(new BigDecimal(String.valueOf(reqData.get("exchFee"))));
            }
            transDTO.setExchAddr((String) reqData.get("exchAddr"));
            transDTO.setExchExpDy((String) reqData.get("exchExpDy"));
            transDTO.setExchEsignYn((String) reqData.get("exchEsignYn"));

            // 3. 날짜 세팅 (신청일시, 서명일시)
            String nowStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            transDTO.setExchReqDt(nowStr);
            if("Y".equals(transDTO.getExchEsignYn())) {
                transDTO.setExchEsignDt(nowStr);
            }

            // 4. [중요] 거래 유형(BUY/SELL)에 따른 통화 코드(From/To) 설정 로직
            // JS에서는 'exchToCurrency'에 무조건 외화 코드를 담아 보냄
            String exchType = (String) reqData.get("exchType");
            String foreignCurrency = (String) reqData.get("exchToCurrency");

            if ("BUY".equals(exchType)) {
                // 살 때: 내 돈(KRW) -> 외화(USD)
                transDTO.setExchFromCurrency("KRW");
                transDTO.setExchToCurrency(foreignCurrency);
            } else {
                // 팔 때: 내 외화(USD) -> 원화(KRW)
                transDTO.setExchFromCurrency(foreignCurrency);
                transDTO.setExchToCurrency("KRW");
            }

            // 쿠폰 번호 매핑
            if (reqData.get("couponNo") != null) {
                transDTO.setCouponNo(Long.parseLong(String.valueOf(reqData.get("couponNo"))));
            }

            // 5. 서비스 호출 (DB 저장)
            exchangeService.processExchange(transDTO);

            response.put("status", "success");
            response.put("message", "환전 신청이 완료되었습니다.");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("환전 신청 처리 중 에러", e);
            response.put("status", "error");
            response.put("message", "환전 처리 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/step3")
    public String step3(){


        return "exchange/step3";
    }
}
